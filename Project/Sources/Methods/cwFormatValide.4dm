//%attributes = {}
/* ----------------------------------------------------
Méthode : cwFormatValide

Verifie le format d'une data

Historique
20/02/15 - Grégory Fromain <gregory@connect-io.fr> - Création
26/10/19 - Grégory Fromain <gregory@connect-io.fr> - Maj de la methode
26/10/19 - Grégory Fromain <gregory@connect-io.fr> - Ajout Bool, real et int
----------------------------------------------------*/


If (True:C214)  // Déclarations
	C_TEXT:C284($0)  // $0 = ok, format inconnu, format incorrect
	C_TEXT:C284($1;$formatNom_t)  // $1 = format recherché
	C_TEXT:C284($2;$dataValue_t)  // $2 = valeur de la data
	
	C_TEXT:C284($T_regex)
	C_OBJECT:C1216($format_o)
End if 

$formatNom_t:=$1
$dataValue_t:=$2

$format_o:=New object:C1471()
$format_o.url:="(?:(?:(?:https?|ftp):)?\\/\\/)(?:\\S+(?::\\S*)?@)?(?:(?!(?:10|127)(?:\\.\\d{1,3}){3})(?!(?:169\\.254|192\\.168)(?:\\.\\d{1,3}){2})(?!172\\.(?:1[6-9]|2\\d|3[0-1])(?:\\.\\d{1,3}){2})(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}(?:\\.(?:[1-9"+"]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))|(?:(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)(?:\\.(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)*(?:\\.(?:[a-z\\u00a1-\\uffff]{2,})).?)(?::\\d{2,5})?(?:[/?#]\\S*)?"
$format_o.email:="[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*"
$format_o.int:="\\d+"
$format_o.real:="[0-9]*,?[0-9]+"
$format_o.bool:="(0|1)"

$format_o.date:="?:(?:31(\\/|-|\\.)(?:0?[13578]|1[02]))\\1|(?:(?:29|30)(\\/|-|\\.)(?:0?[13-9]|1[0-2])\\2))(?:(?:1[6-9]|[2-9]\\d)?\\d{2})$|^(?:29(\\/|-|\\.)0?2\\3(?:(?:(?:1[6-9]|[2-9]\\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\\d|2[0"+"-8])(\\/|-|\\.)(?:(?:0?[1-9])|(?:1[0-2]))\\4(?:(?:1[6-9]|[2-9]\\d)?\\d{2}"


Case of 
	: (Count parameters:C259#2)
		$0:="Le nombre de paramêtre est incorrect."
		
	: ($format_o[$formatNom_t]#Null:C1517)
		
		$T_regex:="^("+$format_o[$formatNom_t]+")$"
		If (Match regex:C1019($T_regex;$dataValue_t))
			$0:="ok"
			
		Else 
			$0:="format incorrect"
		End if 
		
	Else 
		
		$0:="format inconnu"
End case 