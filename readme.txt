Lex 版本:
$ flex --version
flex 2.6.4

作業平台:
$ uname --all
CYGWIN_NT-10.0 DESKTOP-H8M0GBD 3.0.5(0.338/5/3) 2019-03-31 11:17 x86_64 Cygwin

執行方式:
$ make
flex B053040044.l
gcc lex.yy.c -lfl
$ ./a.out < test1.java
$ ./a.out < test2.java
$ ./a.out < test3.java

如何處理這份規格書上的問題
上網找lex的語法教學，想Java語法格式，想regular expression

你/妳寫這個作業所遇到的問題
雖然大部分功能都正常，但還是有許多小bug沒處理(就不透露了)，ex:symbol在function call ,function define,control flow,for while等不同情形需要不同的處理
如果要做到功能完整無誤不太可能
%s印char會出現個code會神奇的卡住。
