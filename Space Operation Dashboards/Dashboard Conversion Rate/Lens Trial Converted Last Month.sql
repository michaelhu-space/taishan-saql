q = load "Recipe_Conversion_Rate";


-- trial converted last month
q_trial_last_month = filter q by 'Plan__c' == "Trial"
	&& 	date('CreatedDate_Year', 'CreatedDate_Month', 'CreatedDate_Day') in ["current month" .. "current month"];
q_trial_last_month =  group q_trial_last_month by ('Studio_.Name', 'Databas.Product.Name', 'Id');	
q_trial_last_month = foreach q_trial_last_month generate 
		'Studio_.Name',
		unique('Account.Person_Mobile_Phone__c') as 'unique_mobile';
-- q_trial_last_month = limit q_trial_last_month 2000;

q_trial_converted_last_month = filter q by 'Trial_Transfer_Membership__c' is not null
	&&	date('Databas.CreatedDate_Year', 'Databas.CreatedDate_Month', 'Databas.CreatedDate_Day') in ["current month" .. "current month"]
	&& 	date('CreatedDate_Year', 'CreatedDate_Month', 'CreatedDate_Day') in ["current month" .. "current month"];

q_trial_converted_last_month =  group q_trial_converted_last_month by ('Studio_.Name', 'Databas.Product.Name', 'Id');
q_trial_converted_last_month = foreach q_trial_converted_last_month generate 
		'Studio_.Name',
		unique('Account.Person_Mobile_Phone__c') as 'unique_mobile',
		average('Average_Price__c') as 'Average_Price__c';



result = cogroup 	q_trial_last_month 				by ('Studio_.Name') , 
                	q_trial_converted_last_month 	by ('Studio_.Name') 
                	;

r_trial_converted_last_month = foreach result generate 
	coalesce(
			q_trial_last_month.'Studio_.Name', 
			q_trial_converted_last_month.'Studio_.Name'
			) as 'Studio_.Name',
	sum(q_trial_last_month.'unique_mobile') as 'Total Trial', 
	sum(q_trial_converted_last_month.'unique_mobile') as 'Total Converted',
	-- number_to_string((q_trial_last_month.'unique_mobile'/q_trial_converted_last_month.'unique_mobile'), "#.00%") as 'Converted Rate',
	average(q_trial_converted_last_month.'Average_Price__c') as 'Average_Price__c';
	;

r_trial_converted_last_month = order r_trial_converted_last_month by ('Studio_.Name' asc);

r_trial_converted_last_month = limit r_trial_converted_last_month 2000;

