#MeCab+Unidicの組み合わせでN-gramを作成
#Unidicの出力は全てデフォルトのまま
function joint(){
	pre_item = gram_tail-n+1
	for(item=gram_tail-n+1;item<=gram_tail;item++){
	#gramの先頭から最後尾まで
	#gramの先頭の初期値はposition、もしくはpre_itemの初期値
		if(w_array2[item]!=""){
			part = part w_array2[item] part_sep
			#形態素情報を数珠つなぎ
			keyword = keyword substr(sentence,pre_item,item-pre_item+1) gram_sep
			#形態素を数珠つなぎ
			key_length += item-pre_item+1
			#これまで何文字処理したかの合計
			pre_item = item + 1
			#次の形態素の先頭
		}
	}
}
function initialize(){
	part = ""
	key_length = ""
	keyword = ""
	pre_item = ""
	#変数の初期化
}
function set_gram(){
	print "Nの最小値"
	getline min <"-"
	print "Nの最大値"
	getline max <"-"
}
function gram_unit(){
	if(unit==1||unit==2){
	#文字単位or単語単位
		kanji_val = $1
		kana_val = $2
	}else if(unit==3){
	#語彙素形単位
		kanji_val = $4
		kana_val = $3
	}
}
function set_mode(){
	#原文ママ、もしくはカナモードの選択
	if(mode==1){
		val = kanji_val
	}else if(mode==2){
		if(kana_val!=""){
			val = kana_val
		}else{
		#ヨミ出現形では記号が空白
		#出現形を利用する
			val = kanji_val
		}
	}
}
function input(){
	sentence = sentence val

	w_tail += length(val)
	#形態素の先頭からの区切り位置

	w_array1[w_tail] = length(val)
	#形態素の字数

	w_array2[w_tail] = $5
	#形態素の品詞情報
}

function file_output(){
	if(output!=""){
		temp = 1
		while(temp<=length(ARGV)-2){
			output = output OFS "0"
			temp++
		}

		split(output,output_array,OFS)

		for(output_num=1;output_num<=ARGC+1;output_num++){
			last_output = last_output output_array[output_num] OFS
		}

		for(output_num=2;output_num<=ARGC+1;output_num++){
			sum += output_array[output_num]
		}
		#sub(",$","",last_output)
		last_output = last_output sum

		if(temp_gram_sep==OFS){
			gsub("/",OFS,last_output)
		}

		if(temp_part_sep==OFS){
			gsub("*",OFS,last_output)
		}

		if(answer2==1){
			print last_output >> output_file_name
		}else if(answer2==2){
			print last_output > output_file_name
		}else if(answer2==3){
			print last_output
		}

		last_output = ""
		output = ""
		sum = ""
	}
}

function set_separator(init){
	print "タブ:1 改行:2 任意の記号:3"
	getline val <"-"
	while(val!=""&&val!=1&&val!=2&&val!=3){
		print "適切な値を入力してください。"
		getline val <"-"
	}
	if(val==""){
		val = init
		pval = init
	}else if(val==1){
		val = "\t"
		pval = "\\t"
	}else if(val==2){
		val = "\n"
		pval = "\\n"
	}else if(val==3){
		print "記号を入力してください"
		getline val <"-"
		if(val==""){
			val = ","
		}
		pval = val
	}
}

function chain(){
	while(val2!=ARGV[f_name]){
		output = output OFS "0"
		f_name ++
	}
	output = output OFS val3
	pre_val1 = val1
	f_name ++
}

BEGINFILE{
	if(ERRNO){
		print FILENAME "が見つかりません。"
		print "このまま続けますか？"
		print "続ける:1 確認する:2"
		getline answer1 <"-"
		while(answer1!=1&&answer1!=2){
			getline answer1 <"-"
		}
		if(answer1==2){
			exit
		}
		nextfile
	}
}

BEGIN{
	for(item=1;item<=ARGC-1;item++){
		file_name_array[item] = ARGV[item]
	}
	PROCINFO["sorted_in"] = "@val_str_asc";
	asort(file_name_array)
	for(item=1;item<=ARGC-1;item++){
		ARGV[item] = file_name_array[item]
	}
	FS="\t"

	print "結果を保存しますか？"
	print "追記する:1 上書き保存する:2 保存しない:3"
	getline answer2 <"-"
	while(answer2!=""&&answer2!=1&&answer2!=2&&answer2!=3){
		print "正しい数字を選択してください"
		getline answer2 <"-"
	}
	if(answer2==""){
		answer2=3
	}else if(answer2==1||answer2==2){
		print "どのファイルに保存しますか？"
		getline output_file_name <"-"
		while(output_file_name==""){
			getline output_file_name <"-"
		}
	}


	print "グラムの単位"
	print "文字:1 書字形:2 語彙素:3"
	getline unit <"-"
	while(unit!=""&&unit!=1&&unit!=2&&unit!=3){
		print "正しい数字を選択してください"
		getline unit <"-"
	}
	if(unit==""){
		unit = 1
	}

	print "項目の区切記号"
	set_separator(",")
	OFS = val
	pOFS = pval

	print "グラムの区切記号"
	set_separator("/")
	if(val==OFS){
		gram_sep = "/"
		temp_gram_sep = val
	}else{
		gram_sep = val
	}
	pgram_sep = pval

	print "品詞の区切記号"
	set_separator("/")
	if(val==OFS){
		part_sep = "*"
		temp_part_sep = val
	}else{
		part_sep = val
	}
	ppart_sep = pval
	#区切り子の設定
	#何も入力されなかった場合はスラッシュを設定

	print "原文:1 or 読み:2"
	getline mode <"-"
	while(mode!=""&&mode!=1&&mode!=2){
	#適切な値が入力されているかどうか
		print "正しい数字を選択してください"
		getline mode <"-"
	}
	if(mode==""){
		mode = 1
	}
	#何も入力されなかった場合はテキストモードを設定

	set_gram()
	if(min==""){
		if(max==""){
			min = 1
			max = 10
		}else{
			min = max
		}
	}else if(max==""){
		max = min
	}
	#いずれの値にも入力されなかった場合は1~10gramを設定
	#一方の値のみ入力された場合は同値を設定

	while(min > max){
		print "最小値は最大値より小さいものを設定してください"
		set_gram()
	}
	#適切な値が入力されているかどうか

	if(answer1==1){
		print "追記"
	}else if(answer2==2){
		print "上書き"
	}else if(answer2==3){
		print "保存しない"
	}

	if(unit==1){
		print "文字"
	}else if(unit==2){
		print "書字形"
	}else{
		print "語彙素"
	}

	if(mode==1){
		print "原文"
	}else{
		print "読み"
	}

	print "項目の区切記号:" pOFS
	print "グラムの区切記号:" pgram_sep
	print "品詞の区切記号:" ppart_sep

	if(min<max){
		print min "gram から " max "gram まで"
	}else{
		print min "gram"
	}
	#設定値の表示
	print
	#データ本体との改行
}

{
#	command1 = "uname"
#	if(command1 | getline=="Darwin"){
		#command = "echo " $0 "|nkf --ic=UTF-8-MAC -wLu|mecab"
#	}else{
		command = "echo " $0 "|mecab"
#	}
#	close(command1)
	while(command | getline){
		if($0 !~/EOS/){
			gram_unit()
			set_mode()
			input()
		}
	}
	close(command)
	#解析対象のテキストファイルは一文ごとに改行したもの
	#テキストファイルから一行ずつ読み込み
	#MeCabに放り込む
	#MeCabの解析結果が続く限り、一行ずつ読み込み
	#EOSが来たら、何もしない

	for(n=min;n<=max;n++){
		if(unit==1){
			for(position=1;position<=(length(sentence)-n+1);position++){
			#文字列の先頭から、最後のgramの先頭の文字まで繰り返す
				gram_tail = position + n - 1
				#gramの最後尾が先頭から何文字目か
				if(w_array2[gram_tail] != ""){
				#gramの最後尾と対応する形態素情報が空要素じゃない
				#つまりgramの最後尾が形態素の最後尾と一致する場合
				#8gramで「イトは精神分析家」
					if(n<=w_array1[gram_tail]){
					#gram数が形態素の文字数より短い場合
					#gramは一つの形態素から構成されている
					#3gramで「フロイト」
						#print substr(sentence,position,n),w_array2[gram_tail]
						#gramの単純出力と対応する形態素情報の出力
						arr_item = substr(sentence,position,n) OFS w_array2[gram_tail]
						s_array[arr_item,FILENAME]++
					}else{
					#gram数が形態素の文字数より長い場合
					#gramは複数の形態素から構成されている
					#5gramで「フロイトは」
						joint()
						sub(part_sep"$","",part)
						sub(gram_sep"$","",keyword)
						#数珠つなぎの最後の区切り記号を削る
					#	print keyword,part
						arr_item = keyword OFS part
						s_array[arr_item,FILENAME]++
						initialize()
					}
				}else{
					#6gramで「イトは精神分」
					joint()
					while(w_array2[gram_tail]==""){
					#gramの最後尾から、形態素の最後尾、つまり区切り位置までインクリメント
						gram_tail++
					}
					part = part w_array2[gram_tail]
					keyword = keyword substr(sentence,pre_item,n-key_length)
					#含まれる最後の形態素（gramには途中まで）の追加
					#処理済みの文字数を控除
					#print keyword,part
					arr_item = keyword OFS part
					s_array[arr_item,FILENAME]++
					initialize()
				}
			}
		}else if(unit==2||unit==3){
			#単語、形態素単位の場合
			num = 0
			#一文あたりの語数の初期化
			for(item=1;item<=w_tail;item++){
				#文頭から文末まで

				if(w_array2[item]!=""){
					num++
					#語数は先に加算
					part_array[num] =w_array2[item]
					morpheme[num] = substr(sentence,item-w_array1[item]+1,w_array1[item])
					#品詞情報用の配列、単語・形態素用の配列にそれぞれ格納
				}
			}
			for(s_pos=1;s_pos<=num-n+1;s_pos++){
				#グラムの始点
				for(pos=s_pos;pos<=s_pos+n-1;pos++){
					keyword = keyword morpheme[pos] gram_sep
					part = part part_array[pos] part_sep 
					#一語ずつ数珠つなぎ
				}
				sub(part_sep"$","",part)
				sub(gram_sep"$","",keyword)
				#print keyword,part
				arr_item = keyword OFS part
				s_array[arr_item,FILENAME]++
				initialize()
			}
			delete part_array
			delete morpheme
		}
	}
	w_tail = ""
	sentence = ""
	delete w_array1
	delete w_array2
	#配列の初期化
}
END{
	if(answer1==2){
		exit
	}

	for(name=1;name<=ARGC-1;name++){
		files = files ARGV[name] OFS
	}
	sub(OFS"$","",files)
	if(answer2==1){
		#print "グラム","品詞情報",files,"合計値" >> output_file_name
	}else if(answer2==2){
		print "グラム","品詞情報",files,"合計値" > output_file_name
	}else if(answer2==3){
		print "グラム","品詞情報",files,"合計値"
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
