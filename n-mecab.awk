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
	#解析対象のテキストファイルは一文ごとに改行したもの
	#テキストファイルから一行ずつ読み込み
	#MeCabに放り込む
	#MeCabの解析結果が続く限り、一行ずつ読み込み
	#EOSが来たら、何もしない

			n = 4
			#グラムの設定

			for(position=1;position<=(length(sentence)-n+1);position++){
			#文字列の先頭から、最後のgramの先頭の文字まで繰り返す
				gram_tail = position + n - 1
				#gramの最後尾が先頭から何文字目か

				if(w_array2[gram_tail] != ""){
				#gramの最後尾と対応する形態素情報が空要素じゃない
				#つまりgramの最後尾が形態素の最後尾と一致する場合
					if(n<=w_array1[gram_tail]){
					#gram数が形態素の文字数より短い場合
					#gramは一つの形態素から構成されている
						print substr(sentence,position,n),w_array2[gram_tail]
						#gramの単純出力と対応する形態素情報の出力
					}else{
					#gram数が形態素の文字数より長い場合
					#gramは複数の形態素から構成されている
						pre_item = gram_tail-n+1
						for(item=gram_tail-n+1;item<=gram_tail;item++){
						#gramの先頭から最後尾まで
						#gramの先頭の初期値はposition、もしくはpre_itemの初期値
							if(w_array2[item]!=""){
								kind = kind w_array2[item] "-"
								#形態素情報を数珠つなぎ
								keyword = keyword substr(sentence,pre_item,item-pre_item+1) "-"
								#形態素を数珠つなぎ
								pre_item = item + 1
								#次の形態素の先頭
							}
						}
						sub(/-$/,"",kind)
						sub(/-$/,"",keyword)
						#数珠つなぎの最後の区切り記号ハイフンを削る
						print keyword,kind

						kind = ""
						keyword = ""
						pre_item = ""
						#変数の初期化
					}
				}else{
					pre_item = gram_tail-n+1
					for(item=gram_tail-n+1;item<=gram_tail;item++){
						if(w_array2[item]!=""){
							kind = kind w_array2[item] "-"
							keyword = keyword substr(sentence,pre_item,item-pre_item+1) "-"

							key_length += item-pre_item+1
							#これまで何文字処理したかの合計
							pre_item = item + 1
						}
					}
					while(w_array2[gram_tail]==""){
					#gramの最後尾から、形態素の最後尾、つまり区切り位置までインクリメント
						gram_tail++
					}
					kind = kind w_array2[gram_tail]
					keyword = keyword substr(sentence,pre_item,n-key_length)
					#含まれる最後の形態素（gramには途中まで）の追加
					#処理済みの文字数を控除
					print keyword,kind

					kind = ""
					key_length = ""
					keyword = ""
					pre_item = ""
					#変数の初期化
				}
			}
	
	position = 1
	w_tail = ""
	delete w_array1
	delete w_array2
	#変数、配列の初期化
}
