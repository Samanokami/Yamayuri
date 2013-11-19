function levenshtein(pair1,pair2){
	for(ch1=0;ch1<=length(pair1);ch1++){arr[ch1,0]=ch1}
	for(ch2=0;ch2<=length(pair2);ch2++){arr[0,ch2]=ch2}
	for(ch1=1;ch1<=length(pair1);ch1++){
		for(ch2=1;ch2<=length(pair2);ch2++){
			if(substr(pair1,ch1,1)==substr(pair2,ch2,1)){
				score = 0
			}else{
				score = 1
			}
			ins = arr[ch1-1,ch2] + 1
			del = arr[ch1,ch2-1] + 1
			tra = arr[ch1-1,ch2-1] + score
			if(ins>=del){
				if(del>=tra){
					arr[ch1,ch2] = tra
				}else{
					arr[ch1,ch2] = del
				}
			}else{
				if(ins>=tra){
					arr[ch1,ch2] = tra
				}else{
					arr[ch1,ch2] = ins
				}
			}
		}
	}
	return arr[length(pair1),length(pair2)]
}

function jarowinkler(pair1,pair2){
	m = t = l = 0
	bt = 0.7
	p = 0.1

	if(length(pair1)>=length(pair2)){
		long_word = pair1
		short_word = pair2
	}else{
		long_word = pair2
		short_word = pair1
	}
	cover = int(length(long_word)/2)-1
	for(item1=1;item1<=length(short_word);item1++){
		for(item2=item1-cover;item2<=item1+cover;item2++){
			if((item2>=1)&&(substr(short_word,item1,1)==substr(long_word,item2,1))){
				m++
			}
		}
		if((substr(short_word,item1,1)==substr(long_word,item1+1,1))&&(substr(short_word,item1+1,1)==substr(long_word,item1,1))){
			t++
		}
	}
	
	for(item=1;item<=4;item++){
		if(substr(short_word,item,1)==substr(long_word,item,1)){
			l++
		}else{
			break
		}
	}
	if(m==0){
		dj = 0
	}else{
		dj = (m/length(short_word) + m/length(long_word) + (m-t)/m)/3
	}

	if(dj<bt){
		dw = dj
	}else{
		dw = dj + (l*p*(1-dj))
	}
	return dw
}

BEGIN{
	copy_filename = ARGV[1]	#copy_filename は本来のファイル名からフォルダ名と拡張子を削ったもの
	sub(/.*\//,"",copy_filename)
	sub(/\..*$/,"",copy_filename)
	
	command="./usr/bin/nkf.exe -wLu " ARGV[1] " > " copy_filename "_uni.txt"	#文字コード変換
	system(command)
	close(command)
	ARGV[1] = copy_filename "_uni.txt"	#処理ファイルを切り替える
}
{
	if($1!=""){	#空行の排除
		gsub(/　/,"",$1)
		string[$1]++	#単語をインデックスとして出現回数を配列に格納
	}
}
END{
	PROCINFO["sorted_in"] = "@ind_str_asc"
	for(item in string){
		header = header "," item
		
	}
	sub(/^,/,"",header)
	print header > "temp.csv"	#ヘッダーの出力
	print header > "temp3.csv"	#ヘッダーの出力
	
	PROCINFO["sorted_in"] = "@ind_str_asc"
	for(item1 in string){
		pair1 = item1	#比較対象の片方
		PROCINFO["sorted_in"] = "@ind_str_asc"
		for(item2 in string){
			pair2 = item2	#比較対象の片方
			result = result "," levenshtein(pair1,pair2) + 1	#レーベンシュタイン関数
			result2 = result2 ","  jarowinkler(pair1,pair2) + 1	#ジャロウィンクラー関数
		}
		sub(/,/,"",result)
		sub(/,/,"",result2)
		print result >> "temp.csv"
		print result2 >> "temp3.csv"
		result = ""
		result2 = ""
	}
	

	command="./usr/bin/nkf.exe -sLw temp.csv > temp2.csv"	#処理対象ファイルの文字コードをSJISに変更
	system(command)
	close(command)
	
	command="./usr/bin/nkf.exe -sLw temp3.csv > temp4.csv"	#処理対象ファイルの文字コードをSJISに変更
	system(command)
	close(command)
	
	output_filename = copy_filename
	
	command = "cp template.r copy.r"	#Rスクリプトをコピー
	system(command)
	close(command)
	
	command = "cp template2.r copy3.r"	#Rスクリプトをコピー
	system(command)
	close(command)
	
	command = "ls html/levenshtein"
	while(command|getline){
		files = files "," $0
	}
	sub(/,/,"",files)
	if(files!~output_filename){
		command="mkdir ./html/levenshtein/" output_filename			
		system(command)
		close(command)
	}
	
	command = "ls html/jarowinkler"
	while(command|getline){
		files = files "," $0
	}
	sub(/,/,"",files)
	if(files!~output_filename){
		command="mkdir ./html/jarowinkler/" output_filename			
		system(command)
		close(command)
	}

	print "writeWebGL(width=1000,height=1000,dir='./html/levenshtein/" output_filename "/',filename='./html/levenshtein/" output_filename "/" output_filename ".html')" >> "copy.r"	#Rスクリプトにhtmlへの書き出し命令を追記

	print "writeWebGL(width=1000,height=1000,dir='./html/jarowinkler/" output_filename "/',filename='./html/jarowinkler/" output_filename "/" output_filename ".html')" >> "copy3.r"	#Rスクリプトにhtmlへの書き出し命令を追記

	command="./usr/bin/nkf.exe -sLw copy.r > copy2.r"	#Rスクリプトの文字コードを変更
	system(command)
	close(command)

	command="./usr/bin/nkf.exe -sLw copy3.r > copy4.r"	#Rスクリプトの文字コードを変更
	system(command)
	close(command)

	command = "./R-Portable/app/R-Portable/bin/Rscript.exe --vanilla copy2.r"	#Rスクリプトを実行
	system(command)
	close(command)

	command = "./R-Portable/app/R-Portable/bin/Rscript.exe --vanilla copy4.r"	#Rスクリプトを実行
	system(command)
	close(command)

	command = "rm copy.r copy2.r copy3.r copy4.r temp.csv temp2.csv temp3.csv temp4.csv " copy_filename "_uni.txt"	#一時ファイルの削除
	system(command)
	close(command)

	command="./usr/bin/nkf.exe -wLu ./html/levenshtein/" output_filename "/" output_filename ".html > ./html/levenshtein/" output_filename "/" output_filename "_2.html"	#html出力ファイルの文字コードをUTF8に変更
	system(command)
	close(command)
	
	command="./usr/bin/nkf.exe -wLu ./html/jarowinkler/" output_filename "/" output_filename ".html > ./html/jarowinkler/" output_filename "/" output_filename "_2.html"	#html出力ファイルの文字コードをUTF8に変更
	system(command)
	close(command)
	
	num = 1
	target = 2
	PROCINFO["sorted_in"] = "@ind_str_asc"
	for(item in string){	#htmlファイルのテキストをRが与えた連番から本来の単語に書き換え
		command = "gawk '{sub(/\"V" num "\"/,\"\\\"" item "\\\"\",$0);print $0}' ./html/levenshtein/" output_filename "/" output_filename "_" target ".html > ./html/levenshtein/" output_filename "/" output_filename "_" target+1 ".html"
		system(command)
		close(command)
		
		command = "gawk '{sub(/\"V" num "\"/,\"\\\"" item "\\\"\",$0);print $0}' ./html/jarowinkler/" output_filename "/" output_filename "_" target ".html > ./html/jarowinkler/" output_filename "/" output_filename "_" target+1 ".html"
		system(command)
		close(command)
		
		command= "rm ./html/levenshtein/" output_filename "/" output_filename "_" target ".html"
		system(command)
		close(command)
		
		command= "rm ./html/jarowinkler/" output_filename "/" output_filename "_" target ".html"
		system(command)
		close(command)
		
		num++
		target++
	}

	command="./usr/bin/nkf.exe -sLw ./html/levenshtein/" output_filename "/" output_filename "_" target ".html > ./html/levenshtein/" output_filename "/" output_filename ".html"	#ファイル名の連番を削除
	system(command)
	close(command)
	
	command="./usr/bin/nkf.exe -sLw ./html/jarowinkler/" output_filename "/" output_filename "_" target ".html > ./html/jarowinkler/" output_filename "/" output_filename ".html"	#ファイル名の連番を削除
	system(command)
	close(command)
	
	command="rm ./html/levenshtein/" output_filename "/" output_filename "_" target ".html"	#残ったファイルの削除
	system(command)
	close(command)
	
	command="rm ./html/jarowinkler/" output_filename "/" output_filename "_" target ".html"	#残ったファイルの削除
	system(command)
	close(command)
	
#	command = "cygstart ./html/levenshtein/" output_filename "/" output_filename ".html"
#	system(command)
#	close(command)

#	command = "cygstart ./html/jarowinkler/" output_filename "/" output_filename ".html"
#	system(command)
#	close(command)

	print "<!DOCTYPEhtml>" > "./html/index2.html"
	print "<html>" >> "./html/index2.html"
	print "\t<head>" >> "./html/index2.html"
#	print "\t\t<metacharset='utf-8'/>" >> "./html/index2.html"
	print "\t\t<title>一覧</title>" >> "./html/index2.html"
	print "\t\t<style>" >> "./html/index2.html"
	print "\t\t</style>" >> "./html/index2.html"
	print "\t</head>" >> "./html/index2.html"
	print "\t<body>" >> "./html/index2.html"
	print "\t\t<h1>レーベンシュタイン距離</h1>" >> "./html/index2.html"
	files = ""
	command = "ls ./html/levenshtein"
	while(command|getline){
		if($0!~/index/){
			print "\t\t<a href='./levenshtein/" $0 "/" $0 ".html' target='_blank'>" $0 "</a>" >> "./html/index2.html"
		}
	}
	print "\t\t<h1>ジャロ＝ウィンクラー距離</h1>" >> "./html/index2.html"
	files = ""
	command = "ls ./html/jarowinkler"
	while(command|getline){
		if($0!~/index/){
			print "\t\t<a href='./jarowinkler/" $0 "/" $0 ".html' target='_blank'>" $0 "</a>" >> "./html/index2.html"
		}
	}

	print "\t</body>" >> "./html/index2.html"
	print "</html>" >> "./html/index2.html"

	command="./usr/bin/nkf.exe -sLw ./html/index2.html > ./html/index.html"	#最後にhtmlファイルの文字コードを変更
	system(command)
	close(command)
	
	command = "rm ./html/index2.html"	#残ったhtmlファイルを削除
	system(command)
	close(command)
	#print "http:// scvlweb01.cc.ag.aoyama.ac.jp/user/a1510051"
}
