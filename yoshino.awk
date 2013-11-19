#Unidicで形態素解析したデータを、直接、N-gramと品詞に分割する
function joint(){
	pre_item = gram_tail-n+1
	for(item=gram_tail-n+1;item<=gram_tail;item++){
	#gramの先頭から最後尾まで
	#gramの先頭の初期値はposition、もしくはpre_itemの初期値
		if(w_array2[stid,item]!=""){
			part = part w_array2[stid,item] part_sep
			#形態素情報を数珠つなぎ
			keyword = keyword substr(sentence[stid][1],pre_item,item-pre_item+1) gram_sep
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
	keyword = ""
	key_length = ""
	pre_item = ""
	w_tail = ""
	#変数の初期化
}

function set_gram(){
	print "Nの最小値"
	getline min <"-"
	print "Nの最大値"
	getline max <"-"
}

function set_span(){
	print "スパンの最小値"
	getline min <"-"
	print "スパンの最大値"
	getline max <"-"
}
function conv_s2n(item){
	item = item * 2 + 1
	return item
}
function gram_unit(){
	if(unit==1||unit==2){
	#文字単位or書字形単位
		kanji_val = $3
		kana_val = $4
	}else if(unit==3){
	#語彙素形単位
		kanji_val = $6
		kana_val = $5
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
	one_sentence = one_sentence val

	w_tail += length(val)
	#形態素の先頭からの区切り位置

	w_array1[sid,w_tail] = length(val)
	#形態素の字数

	w_array2[sid,w_tail] = $7
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
		for(output_num=1;output_num<=ARGC+2;output_num++){
			last_output = last_output output_array[output_num] OFS
		}
		#sub(",$","",last_output)
		for(output_num=2;output_num<=ARGC+2;output_num++){
			sum += output_array[output_num]
		}
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
		print "正しい数字を選択してください"
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
			print "正しい数字を選択してください"
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
	PROCINFO["sorted_in"] = "@ind_str_asc";
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
	print "書字形:1 語彙素:2"
	getline unit <"-"
	while(unit!=""&&unit!=2&&unit!=3){
		print "正しい数字を選択してください"
		getline unit <"-"
	}
	if(unit==""){
		unit = 2
	}
	unit ++

	sid=0

	OFS = ","	#項目の区切
	pOFS = ","

	gram_sep = "/"	#単語の区切
	pgram_sep = "/"

	part_sep = "/"	#品詞情報の区切
	ppart_sep = "/"

	print "原文:1 読み:2"
	getline mode <"-"
	while(mode!=""&&mode!=1&&mode!=2){	#適切な値が入力されているかどうか
		print "正しい数字を選択してください"
		getline mode <"-"
	}
	if(mode==""){
		mode = 1	#何も入力されなかった場合はテキストモードを設定
	}

	set_span()
	if(min==""){
		if(max==""){	#いずれの値にも入力されなかった場合は1~10スパンを設定
			min = 1
			max = 10
		}else{
			min = max
		}
	}else if(max==""){
		max = min
	}
	#一方の値のみ入力された場合は同値を設定

	while(min>max){	#適切な値が入力されているかどうか
		print "最小値は最大値より小さいものを設定してください"
		set_span()
	}

	pmin = min
	pmax = max
	min = min * 2 + 1
	max = max * 2 + 1

	#設定値の表示
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
		print "スパン " pmin " から " pmax " まで"
	}else{
		print "スパン " pmin 
	}
	print	#データ本体との改行
}

{
	number_of_words ++	#総語数
	if($2 == "B"){	#文頭の場合
		sentence[sid][1] = one_sentence
		sentence[sid][2] = pre_file_name
		one_sentence = ""
		w_tail = ""
		sid ++
		gram_unit()
		set_mode()
		input()

	}else if($2 =="I"){
		gram_unit()
		set_mode()
		input()
		pre_file_name = FILENAME
	}
}

END{
	if(answer1==2){
		exit
	}
	sentence[sid][1] = one_sentence	#ファイル最終行の処理
	sentence[sid][2] = pre_file_name	#ファイル最終行の処理
	for(stid = 1;stid<=sid;stid++){
		if(answer2==2||answer2==3){
			for(n=1;n<=1;n+=2){
				if(unit==1){
					for(position=1;position<=(length(sentence[stid][1])-n+1);position++){
					#文字列の先頭から、最後のgramの先頭の文字まで繰り返す
						gram_tail = position + n - 1
						#gramの最後尾が先頭から何文字目か
	
						if(w_array2[stid,gram_tail] != ""){
						#gramの最後尾と対応する形態素情報が空要素じゃない
						#つまりgramの最後尾が形態素の最後尾と一致する場合
							if(n<=w_array1[stid,gram_tail]){
							#gram数が形態素の文字数より短い場合
							#gramは一つの形態素から構成されている
								#print substr(sentence[stid],position,n),w_array2[stid,gram_tail]
								#gramの単純出力と対応する形態素情報の出力
	
								arr_item = n SUBSEP substr(sentence[stid][1],position,n) OFS w_array2[stid,gram_tail] SUBSEP sentence[stid][2]
								s_array[arr_item]++
	
							}else{
							#gram数が形態素の文字数より長い場合
							#gramは複数の形態素から構成されている
								joint()
								#joint2()
								sub(part_sep"$","",part)
								sub(gram_sep"$","",keyword)
								#数珠つなぎの最後の区切り記号を削る
								#print keyword,part
	
								arr_item = n SUBSEP keyword OFS part SUBSEP sentence[stid][2]
								s_array[arr_item]++
	
								initialize()
							}
						}else{
							joint()
							#joint2()
							while(w_array2[stid,gram_tail]==""){
							#gramの最後尾から、形態素の最後尾、つまり区切り位置までインクリメント
								gram_tail++
							}
							part = part w_array2[stid,gram_tail]
							keyword = keyword substr(sentence[stid][1],pre_item,n-key_length)
							#含まれる最後の形態素（gramには途中まで）の追加
							#処理済みの文字数を控除
							#print keyword,part
	
							arr_item = n SUBSEP keyword OFS part SUBSEP sentence[stid][2]
							s_array[arr_item]++
	
							initialize()
							#position = 1
							#変数：positionは絶対に初期化してはいけない
							#初期化すると大変なことになる
						}
					}
				}else if(unit==2||unit==3){
					num = 0
					for(item=1;item<=length(sentence[stid][1]);item++){
						if(w_array2[stid,item]!=""){
							num++
							#語数は先に加算
							part_array[stid,num] =w_array2[stid,item]
							morpheme[stid,num] = substr(sentence[stid][1],item-w_array1[stid,item]+1,w_array1[stid,item])
							#品詞情報用の配列、単語・形態素用の配列にそれぞれ格納
						}
					}
					for(s_pos=1;s_pos<=num-n+1;s_pos++){
						#グラムの始点
						for(pos=s_pos;pos<=s_pos+n-1;pos++){
							keyword = keyword morpheme[stid,pos] gram_sep
							part = part part_array[stid,pos] part_sep 
							#一語ずつ数珠つなぎ
						}
						sub(part_sep"$","",part)
						sub(gram_sep"$","",keyword)
						#print keyword,part
	
						arr_item = n SUBSEP keyword OFS part SUBSEP sentence[stid][2]
						s_array[arr_item]++
						initialize()
					}
					delete part_array
					delete morpheme
				}
			}
		}

		for(n=min;n<=max;n+=2){
			if(unit==1){
				for(position=1;position<=(length(sentence[stid][1])-n+1);position++){
				#文字列の先頭から、最後のgramの先頭の文字まで繰り返す
					gram_tail = position + n - 1
					#gramの最後尾が先頭から何文字目か

					if(w_array2[stid,gram_tail] != ""){
					#gramの最後尾と対応する形態素情報が空要素じゃない
					#つまりgramの最後尾が形態素の最後尾と一致する場合
						if(n<=w_array1[stid,gram_tail]){
						#gram数が形態素の文字数より短い場合
						#gramは一つの形態素から構成されている
							#print substr(sentence[stid],position,n),w_array2[stid,gram_tail]
							#gramの単純出力と対応する形態素情報の出力

							arr_item = n SUBSEP substr(sentence[stid][1],position,n) OFS w_array2[stid,gram_tail] SUBSEP sentence[stid][2]
							s_array[arr_item]++

						}else{
						#gram数が形態素の文字数より長い場合
						#gramは複数の形態素から構成されている
							joint()
							#joint2()
							sub(part_sep"$","",part)
							sub(gram_sep"$","",keyword)
							#数珠つなぎの最後の区切り記号を削る
							#print keyword,part

							arr_item = n SUBSEP keyword OFS part SUBSEP sentence[stid][2]
							s_array[arr_item]++

							initialize()
							}
					}else{
						joint()
						#joint2()
						while(w_array2[stid,gram_tail]==""){
						#gramの最後尾から、形態素の最後尾、つまり区切り位置までインクリメント
							gram_tail++
						}
						part = part w_array2[stid,gram_tail]
						keyword = keyword substr(sentence[stid][1],pre_item,n-key_length)
						#含まれる最後の形態素（gramには途中まで）の追加
						#処理済みの文字数を控除
						#print keyword,part

						arr_item = n SUBSEP keyword OFS part SUBSEP sentence[stid][2]
						s_array[arr_item]++

						initialize()
						#position = 1
						#変数：positionは絶対に初期化してはいけない
						#初期化すると大変なことになる
					}
				}
			}else if(unit==2||unit==3){
				num = 0
				for(item=1;item<=length(sentence[stid][1]);item++){
					if(w_array2[stid,item]!=""){
						num++
						#語数は先に加算
						part_array[stid,num] =w_array2[stid,item]
						morpheme[stid,num] = substr(sentence[stid][1],item-w_array1[stid,item]+1,w_array1[stid,item])
						#品詞情報用の配列、単語・形態素用の配列にそれぞれ格納
					}
				}
				for(s_pos=1;s_pos<=num-n+1;s_pos++){
					#グラムの始点
					for(pos=s_pos;pos<=s_pos+n-1;pos++){
						keyword = keyword morpheme[stid,pos] gram_sep
						part = part part_array[stid,pos] part_sep 
						#一語ずつ数珠つなぎ
					}
					sub(part_sep"$","",part)
					sub(gram_sep"$","",keyword)
					#print keyword,part

					arr_item = n SUBSEP keyword OFS part SUBSEP sentence[stid][2]
					s_array[arr_item]++
					initialize()
				}
				delete part_array
				delete morpheme
			}
		}
	}

	for(name=1;name<=ARGC-1;name++){
		files = files ARGV[name] OFS
	}
	sub(OFS"$","",files)
	if(answer2==1){
		#print NR >> output_file_name
	}else if(answer2==2){
		print NR > output_file_name
		print files > output_file_name
	}else if(answer2==3){
		print NR
		print files
	}

	num_gram = 1
	PROCINFO["sorted_in"]="@ind_str_asc";
	for(item in s_array){
		material =  item SUBSEP s_array[item]
		split(material,item_array,SUBSEP)
		last_array[num_gram][1] = item_array[2]
		last_array[num_gram][2] = item_array[3]
		last_array[num_gram][3] = item_array[4]
		last_array[num_gram][4] = item_array[1]
		num_gram ++
	}
	num_gram = num_gram - 1
	for(count=1;count<=num_gram;count++){
		val1 = last_array[count][1]
		val2 = last_array[count][2]
		val3 = last_array[count][3]
		val4 = last_array[count][4]

		if(val1==pre_val1){
			chain()
		}else{
			file_output()
			f_name = 1
			output = val4 OFS val1
			chain()
		}
	}
	file_output()
}
