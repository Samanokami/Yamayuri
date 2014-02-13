#Unidicで形態素解析したデータを、直接、N-gramと品詞に分割する
#Unidicの出力は全てデフォルトのまま
@include "functions_morph.awk"	#絶対パス、もしくは処理ファイルからの相対パスを指定する。
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
	#ファイルの処理順をソートする
	for(item=1;item<=ARGC-1;item++){#ファイル名を入力順にファイル名配列に格納
		file_name_array[item] = ARGV[item]
	}
	PROCINFO["sorted_in"] = "@val_str_asc";
	asort(file_name_array)#ソート
	for(item=1;item<=ARGC-1;item++){#書き戻し
		ARGV[item] = file_name_array[item]
	}
	FS="\t"

	print "結果を保存しますか？"
	print "追記する:1 上書き保存する:2 保存しない:3"
	getline answer2 <"-"
	while(answer2!=""&&answer2!=1&&answer2!=2&&answer2!=3){#例外処理
		print "正しい数字を選択してください"
		getline answer2 <"-"
	}
	if(answer2==""){
		answer2=3
	}else if(answer2==1||answer2==2){
		print "どのファイルに保存しますか？"
		getline output_file_name <"-"#ファイル名指定
		while(output_file_name==""){#空白ならもう一度
			getline output_file_name <"-"
		}
	}


	print "グラムの単位"
	print "文字:1 書字形:2 語彙素:3"
	getline unit <"-"
	while(unit!=""&&unit!=1&&unit!=2&&unit!=3){#例外処理
		print "正しい数字を選択してください"
		getline unit <"-"
	}
	if(unit==""){
		unit = 1
	}

	sid=0

	print "項目の区切記号"
	set_separator(",")
	OFS = val
	pOFS = pval

	print "グラムの区切記号"
	set_separator("/")
	if(val==OFS){#グラムの区切り記号と項目の区切り記号に同じものが指定された場合
		gram_sep = "/"#一時的にスラッシュ記号を使用
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
	#グラムと品詞情報の区切り子の設定
	#何も入力されなかった場合はスラッシュを設定

	print "原文:1 読み:2"
	getline mode <"-"
	while(mode!=""&&mode!=1&&mode!=2){#適切な値が入力されているかどうか
		print "正しい数字を選択してください"
		getline mode <"-"
	}
	if(mode==""){#何も入力されなかった場合は原文モードを設定
		mode = 1
	}

	set_gram()
	if(min==""){
		if(max==""){#いずれの値にも入力されなかった場合は1~10gramを設定
			min = 1
			max = 10
		}else{
			min = max
		}
	}else if(max==""){#一方の値のみ入力された場合は同値を設定
		max = min
	}
	#0,0gramだった場合は品詞をカウント

	while(min>max){#適切な値が入力されているかどうか
		print "最小値は最大値より小さいものを設定してください"
		set_gram()
	}

	if(answer2==1){
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

	print#データ本体との改行
}

{
	if($2 == "B"){
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
	sentence[sid][1] = one_sentence
	sentence[sid][2] = pre_file_name
	for(stid = 1;stid<=sid;stid++){
		for(n=min;n<=max;n++){
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
			}else if(unit==2||unit==3){#単語、形態素単位の場合
				num = 0#一文あたりの語数の初期化
				for(item=1;item<=length(sentence[stid][1]);item++){
					if(w_array2[stid,item]!=""){
						num++
						#語数は先に加算
						part_array[stid,num] =w_array2[stid,item]
						morpheme[stid,num] = substr(sentence[stid][1],item-w_array1[stid,item]+1,w_array1[stid,item])
						#stid,item は現在の語末の位置
						#品詞情報用の配列、単語・形態素用の配列にそれぞれ格納
					}
				}
				for(s_pos=1;s_pos<=num-n+1;s_pos++){#グラム全体の移動
					#グラムの始点
					for(pos=s_pos;pos<=s_pos+n-1;pos++){#グラムの中の移動
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

	for(name=1;name<=ARGC-1;name++){#ファイル名をつないでヘッダをつくる
		files = files ARGV[name] OFS
	}
	sub(OFS"$","",files)
	if(answer2==1){#追記だったらヘッダを出力しない
	}else if(answer2==2){#新規or上書きだったらヘッダを出力
		print "N","グラム","品詞情報",files,"合計値","該当数" > output_file_name
	}else if(answer2==3){#標準出力なら語数とヘッダを出力
		print "N","グラム","品詞情報",files,"合計値","該当数"
	}

	num_gram = 1
	PROCINFO["sorted_in"]="@ind_str_asc";
	for(item in s_array){
		material =  item SUBSEP s_array[item]
		split(material,item_array,SUBSEP)#s_array はソート済みなので、last_array もソート済み
		last_array[num_gram][1] = item_array[1]	#Nの値
		last_array[num_gram][2] = item_array[2]	#グラム、OFS、品詞情報
		last_array[num_gram][3] = item_array[3]	#ファイル名
		last_array[num_gram][4] = item_array[4]	#出現頻度
		num_gram ++
	}
	num_gram = num_gram - 1
	for(count=1;count<=num_gram;count++){
		val1 = last_array[count][2]	#グラム、OFS、品詞情報
		val2 = last_array[count][3]	#ファイル名
		val3 = last_array[count][4]	#出現頻度
		val4 = last_array[count][1]	#Nの値

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
