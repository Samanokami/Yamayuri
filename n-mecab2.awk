#Unidicで形態素解析したデータを、直接、N-gramと品詞に分割する
function joint(){
	pre_item = gram_tail-n+1
	for(item=gram_tail-n+1;item<=gram_tail;item++){
	#gramの先頭から最後尾まで
	#gramの先頭の初期値はposition、もしくはpre_itemの初期値
		if(w_array2[stid,item]!=""){
			part = part w_array2[stid,item] part_sep
			#形態素情報を数珠つなぎ
			keyword = keyword substr(sentence[stid],pre_item,item-pre_item+1) gram_sep
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
function input(mode){
	#原文ママ、もしくはカナモードの選択
	if(mode==1){
		val = $3
	}else if(mode==2){
		if($4!=""){
			val = $4
		}else{
		#ヨミ出現形では記号が空白
		#出現形を利用する
			val = $3
		}
	}
	one_sentence = one_sentence val
	w_tail += length(val)
	#形態素の先頭からの区切り位置

	w_array1[sid,w_tail] = length(val)
	#形態素の字数

	w_array2[sid,w_tail] = $7
	#形態素の品詞情報
}

BEGIN{
	FS="\t"
	OFS=","

	print "Set Gram Unit"
	print "Mora:1 Word:2"
	getline unit <"-"
	if(unit==""){
		unit = 1
	}

	sid=0
	print "Set Mora Separator"
	getline gram_sep <"-"
	if(gram_sep==""){
		gram_sep = "/"
	}
	print "Set Morpheme Separator"
	getline part_sep <"-"
	if(part_sep==""){
		part_sep = "/"
	}
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
	}else if(max=""){
		max = min
	}
	#いずれの値にも入力されなかった場合は1~10gramを設定
	#一方の値のみ入力された場合は同値を設定
	while(min>max){
		print "Error!"
		print "Small to Large"
		set_gram()
	}
	#適切な値が入力されているかどうか

	if(mode==1){
		print "Text Mode"
	}else{
		print "Kana Mode"
	}
	print "Mora Separator:" gram_sep
	print "Morpheme Separator:" part_sep
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
		input(mode)
		
	}else if($2 =="I"){
		input(mode)
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
							print substr(sentence[stid],position,n),w_array2[stid,gram_tail]
							#gramの単純出力と対応する形態素情報の出力
						}else{
						#gram数が形態素の文字数より長い場合
						#gramは複数の形態素から構成されている
							joint()
							sub(part_sep"$","",part)
							sub(gram_sep"$","",keyword)
							#数珠つなぎの最後の区切り記号を削る
							print keyword,part
							initialize()
							}
					}else{
						joint()
						while(w_array2[stid,gram_tail]==""){
						#gramの最後尾から、形態素の最後尾、つまり区切り位置までインクリメント
							gram_tail++
						}
						part = part w_array2[stid,gram_tail]
						keyword = keyword substr(sentence[stid],pre_item,n-key_length)
						#含まれる最後の形態素（gramには途中まで）の追加
						#処理済みの文字数を控除
						print keyword,part
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
					initialize()
				}
				delete part_array
				delete morpheme
			}
		}
	}
}
