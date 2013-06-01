#Unidicで形態素解析したデータを、直接、N-gramと品詞に分割する

function joint(){
	pre_item = gram_tail-n+1
	for(item=gram_tail-n+1;item<=gram_tail;item++){
	#gramの先頭から最後尾まで
	#gramの先頭の初期値はposition、もしくはpre_itemの初期値
		if(w_array2[stid,item]!=""){
			kind = kind w_array2[stid,item] "+"
			#形態素情報を数珠つなぎ
			keyword = keyword substr(sentence[stid],pre_item,item-pre_item+1) "+"
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
	keyword = ""
	key_length = ""
	pre_item = ""
	w_tail = ""
	#変数の初期化
}

BEGIN{
	FS="\t"
	OFS=","
	sid=0
	print "Please set Minimum Gram"
	getline min <"-"
	print "Please set Maximum Gram"
	getline max <"-"
}
{
	if($2 == "B"){
		sentence[sid] = one_sentence
		one_sentence = ""
		sid ++
		
		one_sentence = $3
		w_tail = length($3)
		#形態素の先頭からの区切り位置

		w_array1[sid,w_tail] = length($3)
		#形態素の字数

		w_array2[sid,w_tail] = $7
		#形態素の品詞情報
	}else if($2 =="I"){
		one_sentence = one_sentence $3
		w_tail += length($3)
		#形態素の先頭からの区切り位置

		w_array1[sid,w_tail] = length($3)
		#形態素の字数

		w_array2[sid,w_tail] = $7
		#形態素の品詞情報
	}
}

END{
	sentence[sid] = one_sentence
	for(n=min;n<=max;n++){
		for(stid = 1;stid<=sid;stid++){
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
						sub(/+$/,"",kind)
						sub(/+$/,"",keyword)
						#数珠つなぎの最後の区切り記号ハイフンを削る
						print keyword,kind
						initialize()
						}
				}else{
					joint()
					while(w_array2[stid,gram_tail]==""){
					#gramの最後尾から、形態素の最後尾、つまり区切り位置までインクリメント
						gram_tail++
					}
					kind = kind w_array2[stid,gram_tail]
					keyword = keyword substr(sentence[stid],pre_item,n-key_length)
					#含まれる最後の形態素（gramには途中まで）の追加
					#処理済みの文字数を控除
					print keyword,kind
					initialize()
					#position = 1
					#変数：positionは絶対に初期化してはいけない
					#初期化すると大変なことになる
				}
			}
		}
	}
}
