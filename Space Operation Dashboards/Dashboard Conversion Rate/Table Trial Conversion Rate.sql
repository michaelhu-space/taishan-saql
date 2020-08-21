q = load "Recipe_Conversion_Rate";

-- trial converted
q_registered = filter q by 'Account.Is_Newcomer__c'==true;

q_tried = filter q by 'Account.Is_Newcomer__c'==true;

-- trial converted
q_trial_converted = filter q by 'Trial_Transfer_Membership__c' is not null;
-- Renew converted
q_renew_converted = filter q by 'Renew_Transfer_Membership__c' is not null;


-- this month trial
q_trial_converted_this_month = filter q_trial_converted by 
		date('Databas.CreatedDate_Year', 'Databas.CreatedDate_Month', 'Databas.CreatedDate_Day') in ["current month" .. "current month"]
	&& 	date('CreatedDate_Year', 'CreatedDate_Month', 'CreatedDate_Day') in ["current month" .. "current month"];

-- last month trial
q_trial_converted_last_month = filter q_trial_converted by 
		date('Databas.CreatedDate_Year', 'Databas.CreatedDate_Month', 'Databas.CreatedDate_Day') in ["1 month ago" .. "1 month ago"] 
	&& 	date('CreatedDate_Year', 'CreatedDate_Month', 'CreatedDate_Day') in ["current month" .. "current month"];

-- this month reniew
-- q_renew_converted_this_month = filter q_renew_converted by 
-- 		date('Databas.CreatedDate_Year', 'Databas.CreatedDate_Month', 'Databas.CreatedDate_Day') in ["1 month ago" .. "1 month ago"],
-- 	&& 	date('CreatedDate_Year', 'CreatedDate_Month', 'CreatedDate_Day') in ["current month" .. "current month"];


-- get this month trial converted group by Dimensions 
q_trial_converted_this_month =  group q_trial_converted_this_month by ('Order.Sold_Studio__c', 'Databas.Product.Name', 'Id');
q_trial_converted_this_month = foreach q_trial_converted_this_month generate 
		unique('Account.Person_Mobile_Phone__c') as 'Account.Person_Mobile_Phone__c',
		average('Average_Price__c') as 'Average_Price__c';
q_trial_converted_this_month = limit q_trial_converted_this_month 2000;

-- get last month trial converted group by Dimensions 
-- q_trial_converted_last_month =  group q_trial_converted_last_month by ('Order.Sold_Studio__c', 'Databas.Product.Name');
-- q_trial_converted_last_month = foreach q_trial_converted_last_month generate 
-- 		unique('Account.Person_Mobile_Phone__c') as 'Account.Person_Mobile_Phone__c';
-- q_trial_last_month = limit q_trial_last_month 2000;



-- result = cogroup 	q_trial_this_month by ('Order.Sold_Studio__c', 'Databas.Product.Name') full, 
--                 	q_trial_last_month by ('Order.Sold_Studio__c', 'Databas.Product.Name') 
--                 	-- q_renew_this_month by ('Order.Sold_Studio__c', '') 
--                 	;

-- r_table = foreach q generate 
-- 		coalesce(
-- 			q_A.'Order.Sold_Studio__c', 
-- 			q_B.'Order.Sold_Studio__c'
-- 			) as 'Order.Sold_Studio__c', 

-- 	coalesce(
-- 		q_A.'Databas.Product.Name', 
-- 		q_B.'Databas.Product.Name'
-- 		) as 'Databas.Product.Name', 
	
-- 	sum(q_A.'Id_UNIQUE') as 'Paid Attendance', 
-- 	sum(q_B.'Id_UNIQUE') as 'Free Attendance'
-- 	;

-- result = order result by ('Schedul.Studio_Name__c' asc, 'Schedul_Schedule_Class_Start_Time_Year_Month' asc);
-- result = limit result 20000;

