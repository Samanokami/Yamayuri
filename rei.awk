BEGIN{
	FS = OFS = ","
}
{
	if(NR==1){
		all_words = $1
	}else if($1==1){
		word = $2 "-" $3
		for(num=4;num<=NF;num++){
			count[word,num-3] = $num
		}
		num_of_file = NF - 4
	}else if($1>1){
		span = ($1 - 1) / 2
		split($2,node,"/")
		split($3,part,"/")
		for(num_word=1;num_word<=$1;num_word++){
			node[num_word] = node[num_word] "-" part[num_word]
		}

		for(num_gram=1;num_gram<=span;num_gram++){
			for(num_file=1;num_file<=num_of_file;num_file++){
				pre[$1,node[span+1],node[num_gram],num_file] += $(num_file+3)
			}
		}

		for(num_gram=span+2;num_gram<=$1;num_gram++){
			for(num_file=1;num_file<=num_of_file;num_file++){
				bef[$1,node[span+1],node[num_gram],num_file] += $(num_file+3)
			}
		}
	}
}
END{
	#print num_of_file
	file_count = 1 
	print "************************************************************************"
	print "前方共起"
	PROCINFO["sorted_in"] = "@ind_str_asc";
	for(item in pre){
		#print item
		app_freq = pre[item]	#共起頻度
		split(item,sub_arr,SUBSEP)
		node_freq = count[sub_arr[2],sub_arr[4]]	#中心語頻度
		other_freq = count[sub_arr[3],sub_arr[4]]	#共起語頻度
		#print node_freq,other_freq,app_freq

		if(app_freq!=0&&node_freq!=0&&other_freq!=0){
			T1 = app_freq - (node_freq*other_freq)/all_words
			T = T1/sqrt(app_freq)
			MI = log((app_freq*all_words)/(node_freq*other_freq))
		}else{
			MI = T = "-"
		}
		score = score MI OFS T OFS

		if(pre_gram!=sub_arr[1]){
			print "------------------------------------------------------------------------"
			print "スパン：" sub_arr[1]
		}
		if(pre_word!=sub_arr[2]){
			print sub_arr[2]	#中心語の表示
		}

		if(file_count==num_of_file){
			sub(/,$/,"",score)
			print "\t" sub_arr[3],score
			file_count = 1
			score = ""
		}else{
			file_count ++
		}

		pre_gram = sub_arr[1]
		pre_word = sub_arr[2]
		delete sub_arr
	}

	print "************************************************************************"
	print "後方共起"
	PROCINFO["sorted_in"] = "@ind_str_asc";
	for(item in bef){
		#print item
		app_freq = bef[item]
		split(item,sub_arr,SUBSEP)
		node_freq = count[sub_arr[2],sub_arr[4]]
		other_freq = count[sub_arr[3],sub_arr[4]]
		#print app_freq,node_freq,other_freq
		
		if(app_freq!=0&&node_freq!=0&&other_freq!=0){
			T1 = (app_freq - (node_freq*other_freq)/all_words)
			T = T1/sqrt(app_freq)
			MI = log((app_freq*all_words)/(node_freq*other_freq))
		}else{
			MI = T = "-"
		}
		score = score MI OFS T OFS

		if(pre_gram!=sub_arr[1]){
			print "------------------------------------------------------------------------"
			print "スパン：" sub_arr[1]
		}
		if(pre_word!=sub_arr[2]){
			print sub_arr[2]
		}

		if(file_count==num_of_file){
			sub(/,$/,"",score)
			print "\t" sub_arr[3],score
			file_count = 1
			score = ""
		}else{
			file_count ++
		}

		pre_gram = sub_arr[1]
		pre_word = sub_arr[2]
		delete sub_arr
	}
}
