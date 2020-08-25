q = load "Recipe_Conversion_Rate";


-- memberships last month
q_trial_last_month = filter q by 'Plan__c' != "Trial"
	&&	date('Databas.CreatedDate_Year', 'Databas.CreatedDate_Month', 'Databas.CreatedDate_Day') in ["1 month ago" .. "current month"]
q_trial_last_month =  group q_trial_last_month by ('Studio_.Name', 'Databas.Product.Name', 'Id');	
q_trial_last_month = foreach q_trial_last_month generate 
		'Studio_.Name',
		unique('Account.Person_Mobile_Phone__c') as 'unique_mobile';
-- q_trial_last_month = limit q_trial_last_month 2000;

-- reniew converted
q_renew_converted = filter q by 'Renew_Transfer_Membership__c' is not null
	&&	date('Databas.CreatedDate_Year', 'Databas.CreatedDate_Month', 'Databas.CreatedDate_Day') in ["1 month ago" .. "current month"]
	&& 	date('CreatedDate_Year', 'CreatedDate_Month', 'CreatedDate_Day') in ["current month" .. "current month"];

-- get this month renew converted group by Dimensions 
q_renew_converted =  group q_renew_converted by ('Studio_.Name', 'Databa1.Product.Name');
q_renew_converted = foreach q_renew_converted generate 
		'Studio_.Name',
		unique('Account.Person_Mobile_Phone__c') as 'Account.Person_Mobile_Phone__c',
		average('Average_Price__c') as 'Average_Price__c';

q_renew_converted = limit q_renew_converted 2000;