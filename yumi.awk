function chain(){
	while(val2!=ARGV[f_name]){
		output = output OFS "0"
		f_name ++
	}
	output = output OFS val3
	pre_val1 = val1
	f_name ++
}
function file_output(){
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
		sub(",$","",last_output)
		if(answer2==1){
			print last_output
		}else{
			print last_output >> output_file_name
		}
		last_output = ""
		output = ""
	}
}
BEGINFILE{
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
	OFS = ","
	print "結果を保存しますか？"
	print "メモ書きだから、保存しなくても良いのよ。:1 ええ、保存しておいて頂戴。:2"
	getline answer2 <"-"
	while(answer2!=""&&answer2!=1&&answer2!=2){
		print "お姉さま、私、何か変なことを聞いてしまいましたか・・・。"
		getline answer2 <"-"
	}
	while(answer2==""){
		print "お姉さま？"
		getline answer2 <"-"
	}
	if(answer2==1){
		print "わかりました。"
	}else if(answer2==2){
		print "どのファイルに保存しますか？"
		getline output_file_name <"-"
		while(output_file_name==""){
			print "お姉さま？"
			getline output_file_name <"-"
		}
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
		exit
	}else{
		for(item=1;item<=ARGC-1;item++){
			file_name_array[item] = ARGV[item]
		}
		PROCINFO["sorted_in"] = "@ind_str_asc";
		asort(file_name_array)
		for(item=1;item<=ARGC-1;item++){
			ARGV[item] = file_name_array[item]
		}
	}
}
{
	if(ARGC!=1){
		s_array[$0,FILENAME]++
	}
}
END{
	if(ARGC==1&&answer1==1){
		if(answer2==1){
			print "キーワード",direct_file_name
		}else{
			print "キーワード",direct_file_name >> output_file_name
		}
		PROCINFO["sorted_in"]="@ind_str_asc"
		for(item in s_array){
			if(item!=exit_word){
				if(answer2==1){
					print item,s_array[item]
				}else{
					print item,s_array[item] >> output_file_name
				}
			}
		}
		exit
	}

	if(ARGC!=1&&answer1==1){
	for(name=1;name<=ARGC-1;name++){
		files = files ARGV[name] OFS
	}
	sub(OFS"$","",files)
	if(answer2==1){
		print "キーワード",files
	}else{
		print "キーワード",files >> output_file_name
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
	}
}
