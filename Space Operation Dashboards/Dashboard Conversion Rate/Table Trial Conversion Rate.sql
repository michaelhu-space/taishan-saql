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
-- q_registered_only = limit q_registered_only 2000;







-- trial converted this month
q_trial_this_month = filter q by 'Plan__c' == "Trial"
	&& 	date('CreatedDate_Year', 'CreatedDate_Month', 'CreatedDate_Day') in ["current month" .. "current month"];
	
q_trial_converted_this_month = filter q by 'Trial_Transfer_Membership__c' is not null
	&&	date('Databas.CreatedDate_Year', 'Databas.CreatedDate_Month', 'Databas.CreatedDate_Day') in ["current month" .. "current month"]
	&& 	date('CreatedDate_Year', 'CreatedDate_Month', 'CreatedDate_Day') in ["current month" .. "current month"];

-- trial converted last month 
q_trial_last_month = filter q by 'Plan__c' == "Trial"
	&& 	date('CreatedDate_Year', 'CreatedDate_Month', 'CreatedDate_Day') in ["1 month ago" .. "1 month ago"];

q_trial_converted_last_month = filter q by 'Trial_Transfer_Membership__c' is not null
	&&	date('Databas.CreatedDate_Year', 'Databas.CreatedDate_Month', 'Databas.CreatedDate_Day') in ["1 month ago" .. "1 month ago"] 
	&& 	date('CreatedDate_Year', 'CreatedDate_Month', 'CreatedDate_Day') in ["current month" .. "current month"];


-- reniew converted
q_renew_converted = filter q by 'Renew_Transfer_Membership__c' is not null
	&&	date('Databas.CreatedDate_Year', 'Databas.CreatedDate_Month', 'Databas.CreatedDate_Day') in ["1 month ago" .. "current month"]
	&& 	date('CreatedDate_Year', 'CreatedDate_Month', 'CreatedDate_Day') in ["current month" .. "current month"];





-- get this month trial converted group by Dimensions 
q_trial_converted_this_month =  group q_trial_converted_this_month by ('Studio_.Name', 'Databas.Product.Name', 'Id');
q_trial_converted_this_month = foreach q_trial_converted_this_month generate 
		'Studio_.Name',
		unique('Account.Person_Mobile_Phone__c') as 'Account.Person_Mobile_Phone__c',
		average('Average_Price__c') as 'Average_Price__c';
-- q_trial_converted_this_month = limit q_trial_converted_this_month 2000;


-- get last month trial converted group by Dimensions 
q_trial_converted_last_month =  group q_trial_converted_last_month by ('Studio_.Name', 'Databas.Product.Name');
q_trial_converted_last_month = foreach q_trial_converted_last_month generate 
		'Studio_.Name',
		unique('Account.Person_Mobile_Phone__c') as 'Account.Person_Mobile_Phone__c',
		average('Average_Price__c') as 'Average_Price__c';
-- q_trial_converted_last_month = limit q_trial_converted_last_month 2000;


-- get this month renew converted group by Dimensions 
q_renew_converted =  group q_renew_converted by ('Studio_.Name', 'Databas.Product.Name');
q_renew_converted = foreach q_renew_converted generate 
		'Studio_.Name',
		unique('Account.Person_Mobile_Phone__c') as 'Account.Person_Mobile_Phone__c',
		average('Average_Price__c') as 'Average_Price__c';
-- q_trial_converted_last_month = limit q_trial_converted_last_month 2000;




-- result = cogroup 	q_trial_this_month by ('Studio_.Name', 'Databas.Product.Name') full, 
--                 	q_trial_last_month by ('Studio_.Name', 'Databas.Product.Name') 
--                 	-- q_renew_this_month by ('Studio_.Name', '') 
--                 	;

-- r_table = foreach q generate 
-- 		coalesce(
-- 			q_A.'Studio_.Name', 
-- 			q_B.'Studio_.Name'
-- 			) as 'Studio_.Name', 

-- 	coalesce(
-- 		q_A.'Databas.Product.Name', 
-- 		q_B.'Databas.Product.Name'
-- 		) as 'Databas.Product.Name', 
	
-- 	sum(q_A.'Id_UNIQUE') as 'Paid Attendance', 
-- 	sum(q_B.'Id_UNIQUE') as 'Free Attendance'
-- 	;

-- result = order result by ('Schedul.Studio_Name__c' asc, 'Schedul_Schedule_Class_Start_Time_Year_Month' asc);
-- result = limit result 20000;

