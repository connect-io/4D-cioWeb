//%attributes = {"shared":true,"preemptive":"capable"}
/*------------------------------------------------------------------------------
Méthode : cwEMailConfigLoad

Precharge toutes les e-mails de l'application web.

Historique
10/11/20 - Grégory Fromain <gregory@connect-io.fr> - Reécriture du code du composant plume.
13/04/21 - Rémy Scanu remy@connect-io.fr> - Adaptation à une utilisation client/serveur
-----------------------------------------------------------------------------*/
var $1 : Object  // Permet de définir des variables global (globalVar)

var $configFile_o : 4D:C1709.File
var $modelFolder_o : 4D:C1709.Folder
var $model_o; $mjmlReponse_o; $mjmlContenu_o : Object

ASSERT:C1129(String:C10(Storage:C1525.param.folderPath.source_t)#""; \
"cwEMailConfigLoad : Merci d'indiquez le chemin du dossier du fichier de config des email dans le storage du composant : Storage.param.folderPath.source_t")

If (Application type:C494#4D mode distant:K5:5)
	// Chemin du fichier de config dans la base hôte.
	$configFile_o:=File:C1566(Storage:C1525.param.folderPath.source_t+"email.jsonc"; fk chemin plateforme:K87:2)
	
	If (Application type:C494=4D Server:K5:6)  // Si on est en mode 4D Serveur, on va copier le fichier dans le dossier Ressources de la base hôte pour que les clients puissent le récupérer
		$configFile_o.copyTo(Folder:C1567(Get 4D folder:C485(Dossier Resources courant:K5:16; *)+"TEMP"+Séparateur dossier:K24:12; fk chemin plateforme:K87:2))
	End if 
	
Else 
	$configFile_o:=File:C1566(Get 4D folder:C485(Dossier Resources courant:K5:16; *)+"TEMP"+Séparateur dossier:K24:12+"email.jsonc"; fk chemin plateforme:K87:2)
End if 

If (Not:C34($configFile_o.exists))  // Si le fichier de config n'existe pas, on le crée.
	Folder:C1567(fk dossier ressources:K87:11).folder("modelEMail").file("email.jsonc").copyTo(Folder:C1567(Storage:C1525.param.folderPath.source_t; fk chemin plateforme:K87:2))
End if 

// Chargement de la configuration des eMails.
Use (Storage:C1525)
	Storage:C1525.eMail:=cwToolObjectFromFile($configFile_o; ck shared:K85:29)
	
	// On stocke les variables communes à tout les mails.
	If (Count parameters:C259=1)
		
		Use (Storage:C1525.eMail)
			Storage:C1525.eMail.globalVar:=OB Copy:C1225($1; ck shared:K85:29)
		End use 
		
	End if 
	
	Use (Storage:C1525.eMail)  // chargement complet du dossier des models.
		Storage:C1525.eMail.modelPath:=Convert path system to POSIX:C1106(Storage:C1525.param.folderPath.source_t)+Storage:C1525.eMail.modelPath
	End use 
	
End use 

$modelFolder_o:=Folder:C1567(Storage:C1525.eMail.modelPath)

If (Not:C34($modelFolder_o.exists))
	$modelFolder_o.create()
End if 

// On boucle tout les modeles
For each ($model_o; Storage:C1525.eMail.model)
	
	If (Not:C34($modelFolder_o.file($model_o.source).exists))  // Si le modéle n'existe pas, on l'importe
		
		If (Folder:C1567(fk dossier ressources:K87:11).folder("modelEMail").file($model_o.source).exists)  // On vérifie si le document existe dans notre composant
			Folder:C1567(fk dossier ressources:K87:11).folder("modelEMail").file($model_o.source).copyTo($modelFolder_o.file($model_o.source).parent)
		Else   // Si ce n'est pas possible on lance une alerte.
			
			If (Application type:C494#4D mode distant:K5:5)
				ALERT:C41("Il manque la source du modèle "+$model_o.name+" pour le composant cioWeb.")
			End if 
			
		End if 
		
	End if 
	
	If (String:C10($model_o.layout)#"")  // si le modèle a un layout
		
		If (Not:C34($modelFolder_o.file($model_o.layout).exists))  // On verifie si le layout est deja chargé sur la base hôte
			
			If (Folder:C1567(fk dossier ressources:K87:11).folder("modelEMail").file($model_o.layout).exists)  // On verifie si le layout est disponible dans le composant
				Folder:C1567(fk dossier ressources:K87:11).folder("modelEMail").file($model_o.layout).copyTo($modelFolder_o.file($model_o.layout).parent)
			Else   // Si ce n'est pas possible on lance une alerte.
				
				If (Application type:C494#4D mode distant:K5:5)
					ALERT:C41("Il manque le layout du modèle "+$model_o.name+" pour le composant cioWeb.")
				End if 
				
			End if 
			
		End if 
		
	End if 
	
End for each 

// Utilisation de l'API MJML
If (Storage:C1525.eMail.mjml#Null:C1517)
	$mjmlReponse_o:=New object:C1471()
	
	HTTP AUTHENTICATE:C1161(Storage:C1525.eMail.mjml.applicationID; Storage:C1525.eMail.mjml.secretKey; 1)
	
	// On parcourt les modèles
	For each ($model_o; Storage:C1525.eMail.model)
		
		// Si il existe un layout
		If (String:C10($model_o.layout)#"")
			
			// si le modèle a un layout au format mjml
			If ($modelFolder_o.file($model_o.layout).extension=".mjml")
				$name_t:=$modelFolder_o.file($model_o.layout).name+".html"
				
				If ((Not:C34($modelFolder_o.file($model_o.layout).parent.file($name_t).exists)) | ($modelFolder_o.file($model_o.layout).parent.file($name_t).modificationTime<$modelFolder_o.file($model_o.layout).modificationTime))
					$mjmlContenu_o:=New object:C1471("mjml"; $modelFolder_o.file($model_o.layout).getText())
					$resultat_i:=HTTP Request:C1158(HTTP méthode POST:K71:2; Storage:C1525.eMail.mjml.urlAPI; $mjmlContenu_o; $mjmlReponse_o)
					
					If ($resultat_i=200)
						$modelFolder_o.file($model_o.layout).parent.file($name_t).setText($mjmlReponse_o.html)
					Else 
						visiteur_o.notificationError:="Erreur d'importation du mjml, erreur : "+String:C10($resultat_i)
					End if 
					
				End if 
				
				// On change le nom du layout pour qu'il soit en .html
				Use (Storage:C1525.eMail.model)
					$model_o.layout:=Replace string:C233($model_o.layout; ".mjml"; ".html")
				End use 
				
			End if 
			
		End if 
		
		If (String:C10($model_o.source)#"")  // S'il existe une source 
			
			If ($modelFolder_o.file($model_o.source).extension=".mjml")  // Si le modèle a une source au format mjml
				$name_t:=$modelFolder_o.file($model_o.source).name+".html"
				
				If ((Not:C34($modelFolder_o.file($model_o.source).parent.file($name_t).exists)) | ($modelFolder_o.file($model_o.source).parent.file($name_t).modificationTime<$modelFolder_o.file($model_o.source).modificationTime))
					$mjmlContenu_o:=New object:C1471("mjml"; $modelFolder_o.file($model_o.source).getText())
					
					$resultat_i:=HTTP Request:C1158(HTTP méthode POST:K71:2; Storage:C1525.eMail.mjml.urlAPI; $mjmlContenu_o; $mjmlReponse_o)
					
					If ($resultat_i=200)
						$modelFolder_o.file($model_o.source).parent.file($name_t).setText($mjmlReponse_o.html)
					Else 
						visiteur_o.notificationError:="Erreur d'importation du mjml, erreur : "+String:C10($resultat_i)
					End if 
					
				End if 
				
				// On change le nom de la source pour qu'il soit en .html
				Use (Storage:C1525.eMail.model)
					$model_o.source:=Replace string:C233($model_o.source; ".mjml"; ".html")
				End use 
				
			End if 
			
		End if 
		
	End for each 
	
End if 