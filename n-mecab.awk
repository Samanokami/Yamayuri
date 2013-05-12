{
	FS=OFS=","
}
{
	sentence = $0
	command = "echo " $0 "| mecab"
	while(command | getline){
		if($0 != "EOS"){
			sub(/\t/,",")
			w_tail += length($1)
			#形態素の先頭からの区切り位置

			w_array1[w_tail] = length($1)
			#形態素の字数

			w_array2[w_tail] = $2
			#形態素の品詞情報
		}
	}

			n = 6
			for(position=1;position<=(length(sentence)-n+1);position++){
				gram_tail = position + n - 1
				#gramの最後尾が先頭から何文字目か
				print substr(sentence,position,n)

				if(w_array2[gram_tail] != ""){
					if(n<=w_array1[gram_tail]){
						print w_array2[gram_tail]
					}else{
						for(item=gram_tail-n+1;item<=gram_tail;item++){
							if(w_array2[item]!=""){
								print w_array2[item]
							}
						}
					}
				}else{
					for(item=gram_tail-n+1;item<=gram_tail;item++){
						if(w_array2[item]!=""){
							print w_array2[item]
						}
					}
					while(w_array2[gram_tail]==""){
						gram_tail++
					}
					print w_array2[gram_tail]
				}
			}
	print sentence
	print ""
	position = 1

	w_tail = ""
	delete w_array1
	delete w_array2
}
