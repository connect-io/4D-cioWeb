Case of 
	: (Form event code:C388=Sur clic:K2:4)
		
		Case of 
			: (Picture size:C356(Form:C1466.imageSortNom)=Picture size:C356(Storage:C1525.automation.image["sort"]))
				Form:C1466.imageSortNom:=Storage:C1525.automation.image["sort-asc"]
				
				Form:C1466.personneCollection:=Form:C1466.personneCollection.orderBy("nom asc")
			: (Picture size:C356(Form:C1466.imageSortNom)=Picture size:C356(Storage:C1525.automation.image["sort-asc"]))
				Form:C1466.imageSortNom:=Storage:C1525.automation.image["sort-desc"]
				
				Form:C1466.personneCollection:=Form:C1466.personneCollection.orderBy("nom desc")
			Else 
				Form:C1466.imageSortNom:=Storage:C1525.automation.image["sort"]
				
				Form:C1466.personneCollection:=Form:C1466.personneCollection.orderBy("UID asc")
		End case 
		
	: (Form event code:C388=Sur survol:K2:35)
		SET CURSOR:C469(9000)
End case 