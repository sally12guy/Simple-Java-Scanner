%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#define MAX_BUFFER 256
int position,line,tail,top=0;
char* table[MAX_BUFFER];
char* tmp_table[30][30];
char tmp_inwhere_2[30];
char tmp_type[30];
char tmp_inwhere[30][30];
int key=0;//for define a id
int key_positive=0;//for define operator or sign bit 
int func_key=0;//for define whether func_"call"(not func define) or not
int parentheses_key=0;//for define ")"=1 and if ")"follow"{" means it isn't a func_"call" but a func define
int define_key=0;//for define a func if the id isn't exsisted 
int where_key=0;
int start_line=0;// for record the line where commemt start
int constructor_key=0;//if in first "{" and name is equal to class name means constructor
int control_key=0;//if in control flow can't define type
int def_in_control=0;//if in control flow define type
int for_key=0;
char buf[256];
struct id_table{
	char name[256];
	char inwhere[30];
};
static struct id_table tables[100];
void creat();
int lookup(char* id);
int insert(char* id);
void dump();
int inserts(char* s,char* in);
int lookups(char* s,char* in);
%}
whitespace [ \t]+
fraction 0|[0-9]*
num [0-9]
integer [+-]?0|[+-]?[1-9][0-9]*
float {integer}"."{fraction}
xfloat ({integer}|{float})[Ee][+-]({integer})
ch [a-zA-Z_$]
id [a-zA-Z_$]+[a-zA-Z_0-9_$]*
xid [0-9]+[a-zA-Z_0-9_$]*
symbol [\,\'\:\;\(\)\{\}\[\]]
operator "++"|"--"|"<="|">="|"=="|"!="|"+"|"-"|"*"|"/"|"%"|"="|"<"|">"|"&&"|"||"|"!"
str \"(\\['"abfnrtv\\]|[^\\"])*\"
xstr ["].*["]
comment [/][*]([^*]|[*]*[^/])*[*]+[/]
keyword "main"|"print"|"break"|"case"|"catch"|"const"|"continue"|"default"|"do"|"else"|"extends"|"false"|"final"|"finally"|"if"|"implements"|"new"|"print"|"private"|"protected"|"public"|"return"|"static"|"switch"|"this"|"true"|"try"|"while"
define_keyword "boolean"|"byte"|"char"|"class"|"double"|"float"|"int"|"long"|"void"|"short"|"string"|"for"
eol \r\n|\n
%x COMMENT
%x COM

%%

{keyword}	{
		if(strcmp(yytext,"print")==0 || strcmp(yytext,"while")==0 || strcmp(yytext,"if")==0 || strcmp(yytext,"switch")==0)
			control_key=1;
		if(strcmp(yytext,"for")==0)
			for_key=1;
		if(strcmp(yytext,"main")==0){
			strcpy(tmp_inwhere_2,yytext);
			inserts(yytext,tmp_inwhere[where_key]);
			define_key=1;
			func_key=0;	
		}
		else
			func_key=1;
		printf("Line: %d,1st char: %d, \"%s\" is a \"reserved word\".\n", line, position, yytext); 
		position += yyleng;
		key=0;
	}	
{define_keyword}	{
		printf("Line: %d,1st char: %d, \"%s\" is a \"reserved word\".\n", line, position, yytext);
		if(control_key==1)
			def_in_control=1;
		key=1;
		position += yyleng;
	}
"//"	{	
			memset(buf,0,sizeof(buf));
			strcat(buf,yytext);
			BEGIN COM;
		}

<COM>[^\r\n]	{
						strcat(buf,yytext);
				}

<COM>"\n"	{
				printf("Line: %d,1st char: %d, \"%s\" is a \"comment\".\n",line, position, buf);
				line++;
				position=1;	
				BEGIN INITIAL;
			}
"/*"		{
			memset(buf,0,sizeof(buf));
			strcat(buf,yytext);
			start_line=line;
			BEGIN COMMENT;
		}
<COMMENT>"*/"	{
			strcat(buf,yytext);
			printf("Line: %d,1st char: %d, \"%s\" is a \"comment\".\n",start_line, position, buf);
			BEGIN INITIAL;
		}

<COMMENT>"\n"	{
			line++;
			strcat(buf,yytext);
			
		}
<COMMENT>.	{	
			strcat(buf,yytext);
			}
			
{str}+	{
			printf("Line: %d,1st char: %d, %s is a \"string\".\n", line, position + 1, yytext);
			//printf("      Original: %s\n", yytext);
	  		position += yyleng;
	  		key=0;
		}

{xstr}	{
			printf("Line: %d,1st char: %d, %s is an error \"string\".\n", line, position, yytext);
			position += yyleng;
			key=0;
		}

{eol}	{
			line++;
			position=1;
			key=0;
		}

{integer}	{
				//printf("In integer: \n");
				
				char tmp[256];
				memset(tmp,0,sizeof(tmp));
				strcpy(tmp,yytext);
				if(key_positive==1){
					if(tmp[0]=='+'||tmp[0]=='-'){	
						//printf("%d %s\n",key_positive,yytext);
						printf("Line: %d,1st char: %d, \"%c\" is an \"operator\".\n", line, position, tmp[0]); 
						tmp[0]='0';
						int t=atoi(tmp);
						printf("Line: %d,1st char: %d, \"%d\" is an \"Interger\".\n", line, position+1, t); 
					}
				
				}
				else{
					printf("Line: %d,1st char: %d, \"%s\" is an \"Interger\".\n", line, position, yytext);
				}
				key_positive=1;
				position += yyleng;
				key=0;
		}


{float}	{
			/* float and science num */
			printf("Line: %d,1st char: %d, \"%s\" is a \"real\".\n", line, position, yytext); 
			position += yyleng;
			key=0;
		}

{xfloat}	{
				printf("Line: %d,1st char: %d, \"%s\" is a \"real\".\n", line, position, yytext); 
				position += yyleng;
				key=0;
			}

{symbol}	{
				/* Symbol */
				printf("Line: %d,1st char: %d, \"%s\" is a \"symbol\".\n", line, position, yytext); 
				if(define_key || constructor_key){
					if(yytext[0]=='{'){
						if(!parentheses_key){
							strcpy(tmp_inwhere[++where_key],tmp_inwhere_2);		//push
						}
						else {
							if(constructor_key==1){
								strcpy(tmp_inwhere[++where_key],tmp_inwhere_2);
								//printf("kkkkkk%d%s\n",where_key,tmp_inwhere_2);
							}
							parentheses_key=0;
						}
						//printf("aaaaaaa%d%s\n",where_key,tmp_inwhere_2);	
					}	
					else if(yytext[0]=='(' && func_key==0){
						parentheses_key=0;
						strcpy(tmp_inwhere[++where_key],tmp_inwhere_2);	//push
						//printf("eee%d%s\n",where_key,tmp_inwhere_2);
					}
					else if(yytext[0]=='(' && func_key==1){
						parentheses_key=0;
						//strcpy(tmp_inwhere[++where_key],tmp_inwhere_2);	//push
						//printf("gggg%d%s\n",where_key,tmp_inwhere_2);
					}
					else if(yytext[0]=='}'){
						define_key=0;
						where_key--;					//pop
						//printf("cccccc%d%s\n",where_key,tmp_inwhere_2);
					}
					else if(yytext[0]==')'){
						if(func_key==1){
							func_key=0;
							parentheses_key=0;
						}
						else
							parentheses_key++;
						if(def_in_control==1){
							def_in_control=0;
							printf("can't define type in control flow'\n");
						}
					}
					else {
						if(parentheses_key==1){
							func_key=0;
							define_key=0;
							if(control_key==0)
							    where_key--;		//pop
							else
							    control_key=0;
							//printf("bbbbb%d%s\n",where_key,tmp_inwhere_2);
						}

					}
				}
				else{
					if(yytext[0]=='}'){
						if(where_key>0)
							where_key--;					//pop
						if(where_key!=0)
							parentheses_key++; 
						else
							parentheses_key=0;
						//printf("ddddd%d%s\n",where_key,tmp_inwhere_2);
					}
				}
				position += yyleng;
				key=0;
			}	

{operator}	{
				//printf("In operator: \n");
				/* Operators */
				printf("Line: %d,1st char: %d, \"%s\" is an \"operator\".\n", line, position, yytext); 
			 	position += yyleng;
			 	key=0;
			 	key_positive=0;
				//printf("		%d",key_positive);
			}

{id}		{
				/* IDs */
				if(key==1){
					int p=lookups(yytext,tmp_inwhere[where_key]);
					if(p==-1){
						tail = insert(yytext); 
						inserts(yytext,tmp_inwhere[where_key]);
						printf("Line: %d,1st char: %d, \"%s\" is an \"ID\".\n", line, position, yytext);
						define_key=1;
						strcpy(tmp_inwhere_2,yytext);
					}
					else{
						printf("Line: %d,1st char: %d, identifier \"%s\" already existed\n",line,position,yytext);  
					}
					func_key=0;
					position += yyleng;
					key=0;
				}
				else if(key==0){
					int p = lookup(yytext);
					if(p!=-1){							
						printf("Line: %d,1st char: %d, \"%s\" is an \"ID\".\n", line, position, yytext);		
						func_key=1;
						//define_key=1;
						if(where_key==1){
							constructor_key=1;
							strcpy(tmp_inwhere_2,"constructor");	
						}
					}										
					else
						printf("Line: %d,1st char: %d, identifier \"%s\" is undefined\n",line,position,yytext);  
					position += yyleng;
				}
				key_positive=0;
			}
		
{xid}	{
			/* Error id format */
			printf("Line: %d,1st char: %d, \"%s\" is an error \"ID\".\n", line, position, yytext);
			//printf("      ERROR on \"%s\" : You have invaild ID name.\n", yytext);
			position += yyleng;
			key=0;
		}
 
.	{
		/* ignore bad characters */
		position++;
		//printf("aaaaaaaaaaaa\n"); 
	}
{whitespace}	{
					position += yyleng;
				}
%%

int main()
{
	strcpy(tmp_inwhere[0],"GLOBAL");
	position = 1; /* char position in line */
	line = 1; /* line number counter */
	tail = -1; /* the last index in hash table */
	
	creat(); /* create hash table for id */
	yylex(); /* run lex match program */
	dump(); /* print hash table */
	return 0;
}

void creat()
{
	int i;
	for( i = 0; i<MAX_BUFFER; i++ )
		table[i] = NULL;

	return ;
}

int lookup(char *id){
	int index = 0;
	/* find the index of id in table */
	while(table[index] != NULL){
		if( !strcmp(table[index], id) )
			return index;
		index++;
	}
	return -1;
}

int insert(char *id){
	int index = tail+1;
	table[index] = (char*)malloc(sizeof(char)* MAX_BUFFER);
	strcpy(table[index],id);
	return index;
}

void dump(){
	printf("The symbol table contains : \n");
	/*int i = 0;
	for(i=0;i<=tail;i++)
		printf("%s\n", table[i]);*/
	int i=1;
	for(i;i<=top;i++){
		printf("%s\tbelong to :%s\n",tables[i].name,tables[i].inwhere);
	}
	return;
}
int inserts(char* s,char* in){
	top++;
	strcpy(tables[top].name,s);	
	strcpy(tables[top].inwhere,in);
}
int lookups(char* s,char* in){//for define a id
	int i=top;
	for(i;i>=0;--i){
		if(!strcmp(tables[i].name,s)&&!strcmp(tables[i].inwhere,in)){
			return i;
		}
	}
	return -1;
}
