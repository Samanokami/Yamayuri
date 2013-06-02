#MeCab+Unidicの組み合わせでN-gramを作成
#Unidicの出力は全てデフォルトのまま
function joint(){
	pre_item = gram_tail-n+1
	for(item=gram_tail-n+1;item<=gram_tail;item++){
	#gramの先頭から最後尾まで
	#gramの先頭の初期値はposition、もしくはpre_itemの初期値
		if(w_array2[item]!=""){
			kind = kind w_array2[item] morph_sep
			#形態素情報を数珠つなぎ
			keyword = keyword substr(sentence,pre_item,item-pre_item+1) mora_sep
			#形態素を数珠つなぎ
			key_length += item-pre_item+1
			#これまで何文字処理したかの合計
			pre_item = item + 1
			#次の形態素の先頭
		}
	}
}
function initialize(){
	kind = ""
	key_length = ""
	keyword = ""
	pre_item = ""
	#変数の初期化
}
function set_gram(){
	print "Please set a Minimum Gram"
	getline min <"-"
	print "Please set a Maximum Gram"
	getline max <"-"
}
function input(val){
	#原文ママ、もしくはカナモードの選択
	if(mode==1){
		val = $1
		sentence = sentence val
	}else if(mode==2){
		if($2!=""){
			val = $2
			sentence = sentence val
		}else{
		#ヨミ出現形では記号が空白
		#出現形を利用する
			val = $1
			sentence = sentence $1
		}
	}
	#sub(/\t/,",") 
	w_tail += length(val)
	#形態素の先頭からの区切り位置

	w_array1[w_tail] = length(val)
	#形態素の字数

	w_array2[w_tail] = $5
	#形態素の品詞情報
}
BEGIN{
	FS="\t"
	OFS=","
	print "Set Mora Separator"
	getline mora_sep <"-"
	if(mora_sep==""){
		mora_sep = "/"
	}
	print "Set Morpheme Separator"
	getline morph_sep <"-"
	if(morph_sep==""){
		morph_sep = "/"
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
	}else if(max==""){
		max = min
	}
	#いずれの値にも入力されなかった場合は1~10gramを設定
	#一方の値のみ入力された場合は同値を設定

	while(min > max){
		print "Error!"
		print "Small to Large!"
		set_gram()
	}
	#適切な値が入力されているかどうか

	if(mode==1){
		print "Text Mode"
	}else{
		print "Kana Mode"
	}
	print "Mora Separator:" mora_sep
	print "Morpheme Separator:" morph_sep
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
	command = "echo " $0 "| mecab"
	while(command | getline){
		if($0 !~/EOS/){
			input(val)
		}
	}
	#解析対象のテキストファイルは一文ごとに改行したもの
	#テキストファイルから一行ずつ読み込み
	#MeCabに放り込む
	#MeCabの解析結果が続く限り、一行ずつ読み込み
	#EOSが来たら、何もしない

	for(n=min;n<=max;n++){
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
					print substr(sentence,position,n),w_array2[gram_tail]
					#gramの単純出力と対応する形態素情報の出力
				}else{
				#gram数が形態素の文字数より長い場合
				#gramは複数の形態素から構成されている
				#5gramで「フロイトは」
					joint()
					sub(morph_sep"$","",kind)
					sub(mora_sep"$","",keyword)
					#数珠つなぎの最後の区切り記号を削る
					print keyword,kind
					initialize()
				}
			}else{
				#6gramで「イトは精神分」
				joint()
				while(w_array2[gram_tail]==""){
				#gramの最後尾から、形態素の最後尾、つまり区切り位置までインクリメント
					gram_tail++
				}
				kind = kind w_array2[gram_tail]
				keyword = keyword substr(sentence,pre_item,n-key_length)
				#含まれる最後の形態素（gramには途中まで）の追加
				#処理済みの文字数を控除
				print keyword,kind
				initialize()
			}
		}
		position = 1
		w_tail = ""
	}
	sentence = ""
	delete w_array1
	delete w_array2
	#配列の初期化
}
