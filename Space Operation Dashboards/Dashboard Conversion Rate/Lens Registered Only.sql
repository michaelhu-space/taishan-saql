q = load "Recipe_Conversion_Rate";


-- register only this month
q_registered_only = filter q by 
		date('CreatedDate_Year', 'CreatedDate_Month', 'CreatedDate_Day') in ["current month" .. "current month"]
	&& 	'Account.Is_Newcomer__c'=="true";
q_registered_only = foreach q_registered_only generate 
        'Studio_.Name',
		unique('Account.Person_Mobile_Phone__c') as 'Account.Person_Mobile_Phone__c';
-- get registered only user count
q_registered_only =  group q_registered_only by ('Studio_.Name');
q_registered_only = foreach q_registered_only generate
        'Studio_.Name',
        sum('Account.Person_Mobile_Phone__c') as 'Account.Person_Mobile_Phone__c';

q_registered_only = limit q_registered_only 2000;