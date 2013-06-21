#カナ表記のN-gramを作成する
BEGIN{
	FS = "\t"
	OFS = ","
}
{
	sentence = $0
	command = "echo " sentence "|mecab"
	while(command | getline){
		if($0 != "EOS"){
			if($2==""){
				text = text $1
			}else{
				text = text $2
			}
		}
	}
	close(command)

	for(n=1;n<=10;n++){
		for(p=1;p<=(length(text)-n+1);p++){
			print substr(text,p,n),NR
		}
	}
	text = ""
}
