#gawk -f yumi.awk ./txt/*.txt
#output_file_name:./temp/output_file_name
function conv1(){#処理前の結果書き込み用データを一時フォルダに変換出力
	copy = output_file_name
	gsub("./temp/","./save/",copy)
	command = "./usr/bin/nkf.exe -wLu " copy " > " output_file_name
	system(command)
	close(command)
}
function conv2(){#テキストファイルを一時フォルダに変換出力
	for(item=1;item<=ARGC-1;item++){
		copy_file[item] = ARGV[item]
		gsub("./txt/","",copy_file[item])
		command = "./usr/bin/nkf.exe -wLu " ARGV[item] " > ./temp/" copy_file[item]
		system(command)
		close(command)
	}
}
function conv3(){#処理対象のファイルを書き換え
	for(item=1;item<=ARGC-1;item++){
		sub("./txt/","./temp/",ARGV[item])
	}
}
function conv4(){#処理結果を一時フォルダから保存フォルダに変換出力
	copy = output_file_name
	gsub("./temp/","",copy)
	if(answer2==2){
		command = "./usr/bin/nkf.exe -s " output_file_name " >> ./save/" copy
	}else if(answer2==3){
		command = "./usr/bin/nkf.exe -s " output_file_name " > ./save/" copy
	}
	system(command)
	close(command)
	
	command = "date +%s"
	command|getline set_time
	close(command)
	
	stamp_name = "_" set_time "."
	sub(/\./,stamp_name,copy)
	if(answer2==2||answer2==3){
		command = "./usr/bin/nkf.exe -s " output_file_name " >> ./backup/" copy 
	}
	system(command)
	close(command)

	command = "rm -f ./temp/*.*"
	system(command)
	close(command)
}
function chain(){	#ファイル毎の結果をマージする
	while(val2!=ARGV[f_name]){
		output = output OFS "0"
		f_name ++
	}
	output = output OFS val3
	pre_val1 = val1
	f_name ++
}
function file_output(){	#出力のための関数
	if(output!=""){
		temp = 1
		while(temp<=ARGC-2){
			output = output OFS "0"
			temp++
		}
		split(output,output_array,OFS)
		for(output_num=1;output_num<=ARGC;output_num++){
			last_output = last_output output_array[output_num] OFS
		}
		for(output_num=2;output_num<=ARGC;output_num++){
			sum += output_array[output_num]
		}
		last_output = last_output sum 
		if(answer2==1){
			print last_output
		}else if(answer2==2){
			print last_output >> output_file_name
		}else if(answer2==3){
			print last_output > output_file_name
		}
		last_output = ""
		output = ""
		sum = ""
	}
}
BEGINFILE{	#ファイルの存在を確認する
	if(ERRNO){
		print "お姉さま、"FILENAME "が見つかりません。"
		print "このまま続けますか？"
		print "構わないわ、続けて頂戴。:1 確認するわよ。あなたもいらっしゃい。:2"
		getline answer1 <"-"
		while(answer1!=1&&answer1!=2){
			print "お姉さま？"
			getline answer1 <"-"
		}
		if(answer1==2){
			exit
		}
		nextfile
	}
}
BEGIN{
	print "マリア様の庭に集う乙女たちが、今日も天使のような無垢な笑顔で、背の高い門を潜り抜けて行く。"
	command = "sleep 1"
	system(command)
	close(command)
	print "汚れを知らない心身を包むのは深い色の制服。 スカートのプリーツは乱さないように、白いセーラーカラーは翻さないように、 ゆっくりと歩くのが、ここでの嗜み。"
	command = "sleep 1"
	system(command)
	close(command)
	print "私立リリアン女学院。ここは、乙女の園。"
	print ""
	command = "sleep 1"
	system(command)
	close(command)

	OFS = ","
	print "結果を保存しますか？"
	print "ちょっとしたメモだから、保存しなくても良いのよ。:1"
	print "ええ、保存しておいて頂戴。ファイルに書き足してくれるかしら。:2"
	print "そうね、ファイルは上書きしてしまいましょう。:3"
	getline answer2 <"-"
	while(answer2!=""&&answer2!=1&&answer2!=2&&answer2!=3){
		print "お姉さま、私、何か変なことを聞いてしまいましたか・・・。"
		getline answer2 <"-"
	}
	while(answer2==""){
		print "お姉さま？"
		getline answer2 <"-"
	}
	if(answer2==1){
		print "わかりました。"
	}else if(answer2==2||answer2==3){
		print "どのファイルに保存しますか？"
		getline output_file_name <"-"
		while(output_file_name==""){
			print "お姉さま？"
			getline output_file_name <"-"
		}
		output_file_name = "./temp/" output_file_name ".csv"
	}

	if(ARGC==1){
		print "これは何のデータですか？"
		getline direct_file_name <"-"
		if(direct_file_name==""){
			direct_file_name="ひみつのデータ"
			print "お姉さまの秘密ですか。気になります。"
		}else{
			print "わかりました。"
		}
		print "お仕事が終ったときの合言葉を決めておきましょう。"
		getline exit_word <"-"
		while(exit_word==""){
			print "お姉さま、合言葉を決めてくださらないと・・・。"
			getline exit_word <"-"
		}
	
		print "キーワードをどうぞ。"
		print "最後に合言葉を入力してくださいね。"
		while(text!=exit_word){
			getline text <"-"
			s_array[text]++
		}
		print
		if(answer2==1){
			print "キーワード",direct_file_name
		}else if(answer2==2){
			print "キーワード",direct_file_name >> output_file_name
		}else if(answer2==3){
			print "キーワード",direct_file_name > output_file_name
		}
		PROCINFO["sorted_in"]="@ind_str_asc"
		for(item in s_array){
			if(item!=exit_word){
				if(answer2==1){
					print item,s_array[item]
				}else if(answer2==2){
					print item,s_array[item] >> output_file_name
				}else if(answer2==3){
					print item,s_array[item] > output_file_name
				}
			}
		}
		
		if(answer2==2){
			conv1()
		}
		exit
	}else{
		for(item=1;item<=ARGC-1;item++){
			gsub(" ","\\ ",ARGV[item])
			file_name_array[item] = ARGV[item]
		}
		PROCINFO["sorted_in"] = "@val_str_asc";
		asort(file_name_array)
		for(item=1;item<=ARGC-1;item++){
			ARGV[item] = file_name_array[item]
		}
		if(answer2==2){
			conv1()
		}
		conv2()
		conv3()
	}
}
{
	if(ARGC!=1){
		s_array[$0,FILENAME]++
	}
}
END{
	if(ARGC==1||answer1==2){
		conv4()
		print "お姉さま、終わりました！"
		print "まぁ！速いわね。ありがとう。山百合会の仕事にもだいぶ慣れてきたようね。"
		exit
	}
	
	if(ARGC!=1){
		for(name=1;name<=ARGC-1;name++){
			files = files ARGV[name] OFS
		}
		sub(OFS"$","",files)
		gsub("./temp/","",files)
		if(answer2==1){
			print "キーワード",files,"合計値"
		}else if(answer2==2){
			print "キーワード",files,"合計値" >> output_file_name
		}else if(answer2==3){
			print "キーワード",files,"合計値" > output_file_name
		}

		num_gram = 1
		PROCINFO["sorted_in"]="@ind_str_asc";
		for(item in s_array){
			material =  item SUBSEP s_array[item]
			split(material,item_array,SUBSEP)
			last_array[num_gram][1] = item_array[1]
			last_array[num_gram][2] = item_array[2]
			last_array[num_gram][3] = item_array[3]
			num_gram ++
		}
		num_gram = num_gram - 1
		for(count=1;count<=num_gram;count++){
			val1 = last_array[count][1]
			val2 = last_array[count][2]
			val3 = last_array[count][3]
			
			if(val1==pre_val1){
				chain()
			}else{
				file_output()
				f_name = 1
				output = val1
				chain()
			}
		}
		file_output()
		conv4()
		print "お姉さま、終わりました！"
		print "まぁ！速いわね。ありがとう。山百合会の仕事にもだいぶ慣れてきたようね。"

	}
}
