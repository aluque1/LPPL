grammar practica3;


options{
    language = Java;
    output   = AST;  
}


@members{
    int cnt   = -1;
    int lineas =  1;
    String codigo_aux = "";
}


entrada returns [String codigo]
	: ec1 = ecuacion 
		{
		$codigo = $ec1.codigo;
		}
	( ec2 = ecuacion
		{
		$codigo += $ec2.codigo;
		}
	)*
		{
      	$codigo += "L" + lineas + " : (HALT, NULL, NULL, NULL)\n";
       	System.out.print($codigo);
       	}
    ;
      

programa returns [String codigo, int lineas]
	: 	
		{
		$lineas = 0;
		$codigo = "";
		}
	( ec = ecuacion 
		{
		$codigo += $ec.codigo;
		$lineas += $ec.lineas;
		}
	)+
	;
ecuacion returns [String codigo, int lineas]
    : Id '=' exp = expresion ';' 
    	{
    	$codigo = $exp.codigo;
		if ($exp.lineas == 0)
			$codigo += "L" + lineas + " : (ASSIGN, " + $Id.text + ", " + $exp.resultado +  ", NULL)\n";
		else    	
			$codigo += "L" + lineas + " : (ASSIGN, " + $Id.text + ", t" + cnt + ", NULL)\n";
		$lineas = 1 + $exp.lineas;
		++lineas;
		}
	| 'if' 
		{
		int aux = lineas;
		lineas+=2;
		}
	'(' ex1 = expresion c = Comp ex2 = expresion ')' 
		{
		lineas -= $ex1.lineas + $ex2.lineas;
		}
	'then' '{' en1 = programa '}' 'else' 
		{
		++lineas;
		}
	'{' en2 = programa '}'
		{
		$codigo = "L" + aux + " : (IF_TRUE," + $ex1.text + $c.text + $ex2.text + ", GOTO, " + "L" + (aux + 2) + ")\n";
		$codigo += "L" + (aux+1) + " : (IF_FALSE," + $ex1.text + $c.text + $ex2.text + ", GOTO, " + "L" + (aux + 3 + $en1.lineas) + ")\n";
		$codigo += $en1.codigo;
		$codigo += "L" + (aux+$en1.lineas+2) + " : (IF_TRUE, NULL, GOTO, L" + (aux+4+$en1.lineas+$en2.lineas) + ")\n";
		$codigo += $en2.codigo;
		$codigo += "L" + (aux+$en1.lineas+$en2.lineas+3) + " : (IF_TRUE, NULL, GOTO, L" + (aux+4+$en1.lineas+$en2.lineas) + ")\n";
		lineas++;
		$lineas = 4 + $en1.lineas + $en2.lineas;
		}
	| 'while' 
		{
		int linea_aux = lineas;
		lineas++;
		}
	'(' exp1=expresion c=Comp exp2=expresion ')'
		{
		linea_aux -= ($exp1.lineas + $exp2.lineas);
		}
	'do' '{' b = programa '}'
		{
		$codigo = "L" + (linea_aux) + " : (IF_FALSE, " + $exp1.text + $c.text + $exp2.text + ", GOTO, L" + (linea_aux + 1 + $b.lineas) +  ")\n";
		$codigo += $b.codigo;
		lineas++;
		}
	| 'for' 
		{
		int linea_aux = lineas;
		}
	'(' Id '=' exp1=expresion ';'
		{
		$codigo = $exp1.codigo;
		if ($exp1.lineas == 0)
			$codigo += "L" + lineas + " : (ASSIGN, " + $Id.text + ", " + $exp1.resultado +  ", NULL)\n";
		else    	
			$codigo += "L" + lineas + " : (ASSIGN, " + $Id.text + ", t" + cnt + ", NULL)\n";
		$lineas = 1 + $exp1.lineas;
		++lineas;
		}
	exp2=expresion c=Comp exp3=expresion ';'
		{
		$codigo += "L" + (lineas) + " : (IF_FALSE, " + $exp2.text + $c.text + $exp3.text + ", GOTO, L" + (linea_aux + 7 + $b.lineas + $i.lineas) +  ")\n";
		lineas++;
		}
	 i=inc ')'
	 	{
	 	if ($i.codigo == "++")
                {
                	cnt++ ;
                        $codigo += "L" + lineas + " : (ADD, t" + cnt + ", " + $i.resultado + ", " + 1 + ")\n" ;
                        lineas++;
                        $codigo += "L" + lineas + " : (ASSIGN, " + $i.resultado + ", t" + cnt + ", NULL)\n";
                        lineas++;
                }
                else if ($i.codigo == "--")
                {
                        cnt++;
                        $codigo += "L" + lineas + " : (SUB, t" + cnt + "," + $i.resultado + "," + 1 + ")\n" ;
                	lineas++;
                	$codigo += "L" + lineas + " : (ASSIGN, " + $i.resultado + ", t" + cnt + ", NULL)\n";
                        lineas++;
                }
	 	}
	'{' b=programa '}'
		{
		$codigo += $b.codigo;
		$codigo += "L" + (lineas) + " : (IF_TRUE, NULL, GOTO, L" + (linea_aux + 2) +  ")\n";;
		lineas++;
		}
	;

inc returns [String codigo, String resultado, int lineas]
	: m1 = termino
		{
		$resultado = $m1.resultado;
		}
	( '++'
		{
		$codigo = "++";
		}
	| '--'
		{
		$codigo = "--";
		})
	;

expresion returns [String codigo, String resultado, int lineas]
	: m1 = termino 
		{ 
		String aux = $m1.resultado;
		$codigo = $m1.codigo;
		$resultado = $m1.resultado;
		$lineas = $m1.lineas;
		}
	( '+' m2=termino 
		{
		cnt++;
		$codigo += $m2.codigo;
		$codigo += "L" + lineas + " : (ADD, t" + cnt + "," + aux + "," + $m2.resultado + ")\n";
		aux = "t" + cnt;
		++lineas;
		$lineas = $lineas + 1 + $m2.lineas;
		$resultado =  "t" + cnt;
		}
	|	'-' m2=termino 
		{
		cnt++;
		$codigo += $m2.codigo;
		$codigo += "L" + lineas + " : (SUB, t" + cnt + "," + aux + "," + $m2.resultado + ")\n";
		aux = "t" + cnt;
		++lineas;
		$lineas = $lineas + 1 + $m2.lineas;
		$resultado =  "t" + cnt;
		}

	)*
	;

termino returns [String codigo, String resultado, int lineas]
	: m1 = factor 
		{ 
		String aux = $m1.resultado;
		$codigo = $m1.codigo;
		$lineas = $m1.lineas;
		$resultado = $m1.resultado;
		}
	( '*' m2=factor 
		{
		cnt++;
		$codigo += $m2.codigo;
		$codigo += "L" + lineas + " : (MULT, t" + cnt + "," + aux + "," + $m2.resultado + ")\n";
		aux = "t" + cnt;
		++lineas;
		$lineas = $lineas + 1 + $m2.lineas;
		$resultado =  "t" + cnt;
		}
	| '/' m2=factor 
		{
		cnt++;
		$codigo += $m2.codigo;
		$codigo += "L" + lineas + " : (DIV, t" + cnt + "," + aux + "," + $m2.resultado + ")\n";
		aux = "t" + cnt;
		++lineas;
		$lineas = $lineas + 1 + $m2.lineas;
		$resultado =  "t" + cnt;
		}
	)*
	;


factor returns [String codigo, String resultado, int lineas]
	: '(' exp = expresion ')' 
		{
		$lineas = $exp.lineas;
		$codigo = $exp.codigo;
		$resultado = $exp.resultado;
		}
	|	n = dato 
		{
		$lineas = $n.lineas;
		$codigo = $n.codigo;
		$resultado = $n.resultado;
		}
	;

dato returns [String codigo, String resultado, int lineas]
	: Number 
		{
		$lineas = 0;
		$codigo = "";
		$resultado = $Number.text;
		}
	| Id 
		{ 
		$lineas = 0;
		$codigo = "";
		$resultado = $Id.text;
		}
	| '-' Number 
		{
		$lineas = 1;
		cnt++;
		$codigo = "L" + lineas + " : (NEG, t" + cnt + "," + $Number.text + ", NULL)\n";
		++lineas;
		$resultado = "t" + cnt;
		}
	| '-' Id 
		{
		$lineas = 1;
		cnt++;
		$codigo = "L" + lineas + " : (NEG, t" + cnt + "," + $Id.text + ", NULL)\n";
		++lineas;
		$resultado = "t" + cnt;
		}
	;
	
	
Id 
	:	('a'..'z'|'A'..'Z')+ 
	; 
   
	
Number
	:	('0'..'9')+ ('.' ('0'..'9')+)? 
	;

Comp 
	: ('>' | '<' | '>=' | '<=' | '==' | '!=')
	;


/* Ignoramos todos los caracteres de espacios en blanco. */


WS
    :   (' ' | '\t' | '\r'| '\n')    { $channel=HIDDEN; }
    ;

