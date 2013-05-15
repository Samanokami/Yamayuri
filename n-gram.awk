#テキストの表記のママのN-gramを作成する。
{
	s = $0
	n = 3

	for(p=1;p<=(length(s)-n+1);p++){
		print substr(s,p,n)
	}
	p = 1
}
