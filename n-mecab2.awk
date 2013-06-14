#Unidicで形態素解析したデータを、直接、N-gramと品詞に分割する
function joint(){
	if(file==2){
		contents = stid "," item
		start = sentence[stid]
	}else{
		contents = item
		start = sentence
	}
	pre_item = gram_tail-n+1
	for(item=gram_tail-n+1;item<=gram_tail;item++){
	#gramの先頭から最後尾まで
	#gramの先頭の初期値はposition、もしくはpre_itemの初期値
		if(w_array2[contents]!=""){
			part = part w_array2[contents] part_sep
			#形態素情報を数珠つなぎ
			keyword = keyword substr(start,pre_item,item-pre_item+1) gram_sep
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
	print "Please set Minimum Gram"
	getline min <"-"
	print "Please set Maximum Gram"
	getline max <"-"
}

function gram_unit(){
	if(unit==1||unit==2){
		kanji_val = $3
		kana_val = $4
	}else if(unit==3){
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

function set_separator(){
	print "Choose Tab:1 New Line:2 Any other:3"
	getline val <"-"
	while(val!=""&&val!=1&&val!=2&&val!=3){
		print "Error!"
		getline val <"-"
	}
	if(val==""){
		val = ","
		pval = ","
	}else if(val==1){
		val = "\t"
		pval = "\\t"
	}else if(val==2){
		val = "\n"
		pval = "\\n"
	}else if(val==3){
		print "Enter Separator"
		getline val <"-"
		if(val==""){
			val = ","
		}
		pval = val
	}
}
BEGIN{
	FS="\t"
	OFS=","

	file = 2

	print "Set Gram Unit"
	print "Mora:1 Word:2 Morph:3"
	getline unit <"-"
	if(unit==""){
		unit = 1
	}

	sid=0
	
	print "Field Separator"
	set_separator()
	OFS = val
	pOFS = pval

	print "Set Gram Separator"
	set_separator()
	gram_sep = val
	pgram_sep = pval

	print "Set Part Separator"
	set_separator()
	part_sep = val
	ppart_sep = pval
	#区切り子の設定
	#何も入力されなかった場合はスラッシュを設定
	
	print "Text:1 or Kana:2"
	getline mode <"-"
	while(mode!=""&&mode!=1&&mode!=2){
	#適切な値が入力されているかどうか
		print "Error!"
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
	#0,0gramだった場合は品詞をカウント
	while(min>max){
		print "Error!"
		print "Small to Large"
		set_gram()
	}
	#適切な値が入力されているかどうか
	
	if(unit==1){
		print "Mora"
	}else if(unit==2){
		print "Word"
	}else{
		print "Morpheme"
	}
	if(mode==1){
		print "Text Mode"
	}else{
		print "Kana Mode"
	}
	print "Field Separator:" pOFS
	print "Mora Separator:" pgram_sep
	print "Morpheme Separator:" ppart_sep
	if(min<max){
		print min "gram to " max "gram"
	}else{
		print min "gram"
	}
	#設定値の表示
	print
	#データ本体との改行
}

{
	if($2 == "B"){
		sentence[sid] = one_sentence
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
	}
}

END{
	sentence[sid] = one_sentence
	for(stid = 1;stid<=sid;stid++){
		for(n=min;n<=max;n++){
			if(unit==1){
				for(position=1;position<=(length(sentence[stid])-n+1);position++){
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
							
							arr_item = substr(sentence[stid],position,n) OFS w_array2[stid,gram_tail]
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
							
							arr_item = keyword OFS part
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
						keyword = keyword substr(sentence[stid],pre_item,n-key_length)
						#含まれる最後の形態素（gramには途中まで）の追加
						#処理済みの文字数を控除
						#print keyword,part
						
						arr_item = keyword OFS part
						s_array[arr_item]++
							
						initialize()
						#position = 1
						#変数：positionは絶対に初期化してはいけない
						#初期化すると大変なことになる
					}
				}
			}else if(unit==2||unit==3){
				num = 0
				for(item=1;item<=length(sentence[stid]);item++){
					if(w_array2[stid,item]!=""){
						num++
						#語数は先に加算
						part_array[stid,num] =w_array2[stid,item]
						morpheme[stid,num] = substr(sentence[stid],item-w_array1[stid,item]+1,w_array1[stid,item])
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
					print keyword,part
					
					arr_item = keyword OFS part
					s_array[arr_item]++
					initialize()
				}
				delete part_array
				delete morpheme
			}
		}
	}

	PROCINFO["sorted_in"]="@ind_str_asc";
	for(s_item in s_array){
		print s_item,s_array[s_item]
	}
}
