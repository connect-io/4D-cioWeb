Case of 
	: (Form event code:C388=Sur clic:K2:4)
		
		Case of 
			: (Picture size:C356(Form:C1466.imageSortVille)=Picture size:C356(Storage:C1525.automation.image["sort"]))
				Form:C1466.imageSortVille:=Storage:C1525.automation.image["sort-asc"]
				
				Form:C1466.personneCollection:=Form:C1466.personneCollection.orderBy("ville asc")
			: (Picture size:C356(Form:C1466.imageSortVille)=Picture size:C356(Storage:C1525.automation.image["sort-asc"]))
				Form:C1466.imageSortVille:=Storage:C1525.automation.image["sort-desc"]
				
				Form:C1466.personneCollection:=Form:C1466.personneCollection.orderBy("ville desc")
			Else 
				Form:C1466.imageSortVille:=Storage:C1525.automation.image["sort"]
				
				Form:C1466.personneCollection:=Form:C1466.personneCollection.orderBy("UID asc")
		End case 
		
	: (Form event code:C388=Sur survol:K2:35)
		SET CURSOR:C469(9000)
End case 