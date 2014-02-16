function joint(){#形態素と品詞情報を繋ぐ
	pre_item = gram_tail-n+1
	for(item=gram_tail-n+1;item<=gram_tail;item++){
	#gramの先頭から最後尾まで
	#gramの先頭の初期値はposition、もしくはpre_itemの初期値
		if(w_array2[stid,item]!=""){
			part = part w_array2[stid,item] part_sep
			#品詞情報を数珠つなぎ
			keyword = keyword substr(sentence[stid][1],pre_item,item-pre_item+1) gram_sep
			#形態素を数珠つなぎ
			key_length += item-pre_item+1
			#これまで何文字処理したかの合計
			pre_item = item + 1
			#次の形態素の先頭
		}
	}
}

function initialize(){#変数の初期化
	part = ""
	keyword = ""
	key_length = ""
	pre_item = ""
	w_tail = ""
}

function set_gram(){#採取するグラムのNの値の幅を決める
	print "Nの最小値"
	getline min <"-"
	print "Nの最大値"
	getline max <"-"
}

function set_span(){#スパンの最大値と最小値を定義する
	print "スパンの最小値"
	getline min <"-"
	print "スパンの最大値"
	getline max <"-"
}

function gram_unit(){#読み込み対象の列の切り替え
	if(unit==1||unit==2){#文字単位or書字形単位
		kanji_val = $3
		kana_val = $4
	}else if(unit==3){#語彙素形単位
		kanji_val = $6
		kana_val = $5
	}
}

function set_mode(){#原文ママ、もしくはカナモードの選択
	if(mode==1){
		val = kanji_val
	}else if(mode==2){
		if(kana_val!=""){
			val = kana_val
		}else{#ヨミ出現形では記号が空白なので出現形を利用する
			val = kanji_val
		}
	}
}

function input(){#読み込み
	one_sentence = one_sentence val
	#単語をつないで一文を組み立てる

	w_tail += length(val)
	#形態素の先頭からの区切り位置

	#区切位置をインデックスに使う
	w_array1[sid,w_tail] = length(val)
	#文頭から語末までw_array文字目の形態素の字数

	w_array2[sid,w_tail] = $7
	#文頭から語末までw_array文字目の形態素の品詞情報
}

function file_output(){#出現頻度に0、合計値、該当数を追加し出力する
	if(output!=""){#その gram を含まない処理ファイルの欄に0を代入する
		split(output,output_array,OFS)

		for(output_num=length(output_array)+1;output_num<=ARGC+2;output_num++){	#0を末尾に補う
			output_array[output_num] = 0
		}

		for(output_num=1;output_num<=ARGC+2;output_num++){	#グラム、品詞情報、出現頻度と0を繋ぐ
			last_output = last_output output_array[output_num] OFS
		}

		for(output_num=4;output_num<=ARGC+2;output_num++){
			sum += output_array[output_num]		#合計値を算出
			if(output_array[output_num]!=0){	#該当数を算出
				inclusion_file ++
			}
		}
		last_output = last_output sum OFS inclusion_file

		#指定された区切記号に問題がある場合の回避
		if(temp_gram_sep==OFS){
			gsub("/",OFS,last_output)
		}

		if(temp_part_sep==OFS){
			gsub("*",OFS,last_output)
		}

		#出力先の分岐
		if(answer2==1){
			print last_output >> output_file_name
		}else if(answer2==2){
			print last_output > output_file_name
		}else if(answer2==3){
			print last_output
		}

		#変数・配列の初期化
		last_output = ""
		output = ""
		sum = ""
		inclusion_file = ""
	}
}

function set_separator(init){#区切り記号の選択
	print "タブ:1 改行:2 任意の記号:3"
	getline val <"-"
	while(val!=""&&val!=1&&val!=2&&val!=3){
		print "正しい数字を選択してください"
		getline val <"-"
	}
	#val は区切り記号、pval は表示用（エスケープシーケンス）
	if(val==""){#未入力の場合、デフォルト値
		val = init
		pval = init
	}else if(val==1){
		val = "\t"
		pval = "\\t"
	}else if(val==2){
		val = "\n"
		pval = "\\n"
	}else if(val==3){#任意の記号
		print "記号を入力してください"
		getline val <"-"
		if(val==""){
			val = ","
		}
		pval = val
	}
}

function chain(){#出現頻度をつなぐ
	while(val2!=ARGV[f_name]){#ファイル名が異なる場合、0を繰り返す
		output = output OFS "0"
		f_name ++
	}
	output = output OFS val3
	pre_val1 = val1
	f_name ++
}
