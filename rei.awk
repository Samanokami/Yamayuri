BEGIN{
	FS = OFS = ","
	print "追記:1 新規or上書き保存:2 標準出力:3"
	getline answer1 <"-"
	while(answer1!=1&&answer1!=2&&answer1!=3){
		print "正しい数字を入力してください。"
		getline answer1 <"-"
	}
	if(answer1!=3){
		print "保存先を指定してください"
		getline answer2 <"-"
	}
	print "タブ：1 一覧表：2"
	getline format <"-"
	while(format!=1&&format!=2){
		print "正しい数字を入力してください。"
		getline format <"-"
	}
	print "MI：1 T：2 共起頻度：3"
	getline answer3 <"-"
	while(answer3!=1&&answer3!=2&&answer3!=3){
		print "正しい数字を入力してください。"
		getline answer3 <"-"
	}
	print "前方共起：1 後方共起：2"
	getline answer4 <"-"
	while(answer4!=1&&answer4!=2){
		print "正しい数字を入力してください。"
		getline answer4 <"-"
	}
}
{
	if(NR==1){
		all_words = $1		#一行目の総語数
	}else if(NR==2){
	       files = $0
		num_of_file = NF	#ファイル数
	}else if($1==1){	#単語の出現頻度
		word = $2 "-" $3	#単語と品詞情報の統合
		for(num=4;num<=NF-2;num++){
			count[word,num-3] = $num	#単語と出現頻度の配列
			#count[単語-品詞情報,ファイル番号]
		}
	}else if($1>1){		#共起頻度の一覧
		span = ($1 - 1) / 2
		split($2,node,"/")	#単語の配列
		split($3,part,"/")	#品詞情報の配列
		for(num_word=1;num_word<=$1;num_word++){
			node[num_word] = node[num_word] "-" part[num_word]	#単語と品詞情報の統合
		}

		for(num_gram=1;num_gram<=span;num_gram++){
			for(num_file=1;num_file<=num_of_file;num_file++){
				#pre[$1,node[span+1],node[num_gram],num_file] += $(num_file+3)
				bef[$1,node[span+1],node[num_gram],num_file] += $(num_file+3)
				#bef[Nの値,中心語,前方共起語,ファイル番号] += 共起頻度
			}
		}

		for(num_gram=span+2;num_gram<=$1;num_gram++){
			for(num_file=1;num_file<=num_of_file;num_file++){
				#bef[$1,node[span+1],node[num_gram],num_file] += $(num_file+3)
				aft[$1,node[span+1],node[num_gram],num_file] += $(num_file+3)
				#aft[Nの値,中心語,後方共起語,ファイル番号] += 共起頻度
			}
		}
	}
}
END{
	if(format==2){
		if(answer1==2){
			if(answer3==1||answer3==2){
				print "スパン","中心語","共起語",files,"平均値","該当数" > answer2
			}else{
				print "スパン","中心語","共起語",files,"合計値","平均値","該当数" > answer2
			}
		}
	}

	file_count = 1 
	if(answer4==1){		#前方共起
		PROCINFO["sorted_in"] = "@ind_str_asc";
		for(item in bef){
			app_freq = bef[item]	#共起頻度
			split(item,sub_arr,SUBSEP)	#インデックスを分割
			#sub_arr=[Nの値,中心語,共起語,ファイル番号]
			node_freq = count[sub_arr[2],sub_arr[4]]	#中心語頻度
			other_freq = count[sub_arr[3],sub_arr[4]]	#共起語頻度
			#単語-品詞情報とファイル番号の配列を利用
	
			if(app_freq!=0&&node_freq!=0&&other_freq!=0){
				if(answer3==1){		#MI値を計算
					calc = log((app_freq*all_words)/(node_freq*other_freq))
				}else if(answer3==2){	#T値を計算
					T1 = app_freq - (node_freq*other_freq)/all_words
					calc = T1/sqrt(app_freq)
				}else{
					calc = app_freq
				}

				sum += calc		#合計値
				inclusion_file ++	#該当数
			}else{
				if(answer3==1||answer3==2){
					calc = ""
				}else{
					calc = 0
				}
			}
			#score = score node_freq OFS other_freq OFS app_freq OFS calc OFS
			score = score calc OFS
	
			if(pre_gram!=sub_arr[1]&&format==1){
				if(answer1==1){
					print "------------------------------------------------------------------------" >> answer2
					print "スパン：" (sub_arr[1]-1)/2 >> answer2
				}else if(answer1==2){ 
					print "------------------------------------------------------------------------" > answer2
					print "スパン：" (sub_arr[1]-1)/2 > answer2
				}else{
					print "------------------------------------------------------------------------" 
					print "スパン：" (sub_arr[1]-1)/2
				}
			}
			if(pre_word!=sub_arr[2]&&format==1){
				if(answer1==1){
					print sub_arr[2] >> answer2	#中心語の表示
				}else if(answer1==2){ 
					print sub_arr[2] > answer2	#中心語の表示
				}else{
					print sub_arr[2]	#中心語の表示
				}
			}
	
			if(file_count==num_of_file){
				average = sum/num_of_file	#平均値
				sub(/,$/,"",score)
				if(format==1){
					if(answer1==1){
						if(answer3==1||answer3==2){
							print "\t" sub_arr[3],score,average,inclusion_file >> answer2
						}else{
							print "\t" sub_arr[3],score,sum,average,inclusion_file >> answer2
						}
					}else if(answer1==2){
						if(answer3==1||answer3==2){
							print "\t" sub_arr[3],score,average,inclusion_file > answer2
						}else{
							print "\t" sub_arr[3],score,sum,average,inclusion_file > answer2
						}
					}else{
						if(answer3==1||answer3==2){
							print "\t" sub_arr[3],score,average,inclusion_file
						}else{
							print "\t" sub_arr[3],score,sum,average,inclusion_file
						}
					}
				}else{
					if(answer1==1){
						if(answer3==1||answer3==2){
							print (sub_arr[1]-1)/2,sub_arr[2],sub_arr[3],score,average,inclusion_file >> answer2
						}else{
							print (sub_arr[1]-1)/2,sub_arr[2],sub_arr[3],score,sum,average,inclusion_file >> answer2
						}
					}else if(answer1==2){
						if(answer3==1||answer3==2){
							print (sub_arr[1]-1)/2,sub_arr[2],sub_arr[3],score,average,inclusion_file > answer2
						}else{
							print (sub_arr[1]-1)/2,sub_arr[2],sub_arr[3],score,sum,average,inclusion_file > answer2
						}
					}else{ 
						if(answer3==1||answer3==2){
							print (sub_arr[1]-1)/2,sub_arr[2],sub_arr[3],score,average,inclusion_file
						}else{
							print (sub_arr[1]-1)/2,sub_arr[2],sub_arr[3],score,sum,average,inclusion_file
						}
					}
				}
				file_count = 1
				score = sum = average = inclusion_file = ""
			}else{
				file_count ++
			}
	
			pre_gram = sub_arr[1]
			pre_word = sub_arr[2]
			delete sub_arr
		}
	}else{			#後方共起
		PROCINFO["sorted_in"] = "@ind_str_asc";
		for(item in aft){
			app_freq = aft[item]
			split(item,sub_arr,SUBSEP)
			node_freq = count[sub_arr[2],sub_arr[4]]
			other_freq = count[sub_arr[3],sub_arr[4]]
			
			if(app_freq!=0&&node_freq!=0&&other_freq!=0){
				if(answer3==1){		#MI値を計算
					calc = log((app_freq*all_words)/(node_freq*other_freq))
				}else if(answer3==2){		#T値を計算
					T1 = (app_freq - (node_freq*other_freq)/all_words)
					calc = T1/sqrt(app_freq)
				}else{
					calc = app_freq
				}
				inclusion_file ++
				sum += calc
			}else{
				if(answer3==1||answer3==2){
					calc = ""
				}else{
					calc = 0
				}
			}
			#score = score node_freq OFS other_freq OFS app_freq OFS calc OFS
			score = score calc OFS
	
			if(pre_gram!=sub_arr[1]&&format==1){
				if(answer1==1){
					print "------------------------------------------------------------------------" >> answer2
					print "スパン：" (sub_arr[1]-1)/2 >> answer2
				}else if(answer1==2){
					print "------------------------------------------------------------------------" > answer2
					print "スパン：" (sub_arr[1]-1)/2 > answer2
				}else{
					print "------------------------------------------------------------------------"
					print "スパン：" (sub_arr[1]-1)/2
				}
			}
			if(pre_word!=sub_arr[2]&&format==1){
				if(answer1==1){
					print sub_arr[2] >> answer2
				}else if(answer1==2){
					print sub_arr[2] > answer2
				}else{
					print sub_arr[2]
				}
			}
	
			if(file_count==num_of_file){
				average = sum/num_of_file
				sub(/,$/,"",score)
				if(format==1){
					if(answer1==1){
						if(answer3==1||answer3==2){
							print "\t" sub_arr[3],score,average,inclusion_file >> answer2
						}else{
							print "\t" sub_arr[3],score,sum,average,inclusion_file >> answer2
						}
					}else if(answer1==2){
						if(answer3==1||answer3==2){
							print "\t" sub_arr[3],score,average,inclusion_file > answer2
						}else{
							print "\t" sub_arr[3],score,sum,average,inclusion_file > answer2
						}
					}else{
						if(answer3==1||answer3==2){
							print "\t" sub_arr[3],score,average,inclusion_file
						}else{
							print "\t" sub_arr[3],score,sum,average,inclusion_file
						}
					}
				}else{
					if(answer1==1){
						if(answer3==1||answer3==2){
							print (sub_arr[1]-1)/2,sub_arr[2],sub_arr[3],score,average,inclusion_file >> answer2
						}else{
							print (sub_arr[1]-1)/2,sub_arr[2],sub_arr[3],score,sum,average,inclusion_file >> answer2
						}
					}else if(answer1==2){
						if(answer3==1||answer3==2){
							print (sub_arr[1]-1)/2,sub_arr[2],sub_arr[3],score,average,inclusion_file > answer2
						}else{
							print (sub_arr[1]-1)/2,sub_arr[2],sub_arr[3],score,sum,average,inclusion_file > answer2
						}
					}else{
						if(answer3==1||answer3==2){
							print (sub_arr[1]-1)/2,sub_arr[2],sub_arr[3],score,average,inclusion_file
						}else{
							print (sub_arr[1]-1)/2,sub_arr[2],sub_arr[3],score,sum,average,inclusion_file
						}
					}
				}
				file_count = 1
				score = sum = average = inclusion_file = ""
			}else{
				file_count ++
			}
	
			pre_gram = sub_arr[1]
			pre_word = sub_arr[2]
			delete sub_arr
		}
	}
}
