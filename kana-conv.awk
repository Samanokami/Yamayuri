#カナ表記のN-gramを作成する
BEGIN{
	FS = "\t"
	OFS = ","
}
{
	sentence = $0
	command = "echo " sentence "|mecab"
	while(command | getline){
		print $0
		if($0 != "EOS"){
			#sub(/\t/,",")
			if($2==""){
				text = text $1
			}else{
				text = text $2
			}
		}
	}

	print text
	text = ""
}
