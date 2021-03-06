q = load "Recipe_Conversion_Rate";


-- burned 2 months from this month
q_burned_this_month = filter q by 
	( 'Average_Price__c' != 0 && 'Plan__c' != "Trial" )
	&& 'J_Instr.Is_Active__c' == "true"
	&&(		date('End_Date__c_Year', 'End_Date__c_Month', 'End_Date__c_Day') in ["1 month ago" .. "current month"]
		|| ('Main_Total_Class__c' > 5 && 'Main_Total_Available__c'<=5 && 'Status__c' == "Active" )
	);

q_burned_this_month =  group q_burned_this_month by ('Studio_.Name', 'Account.Person_Mobile_Phone__c');	
q_burned_this_month = foreach q_burned_this_month generate 
		'Studio_.Name',
		unique('Account.Person_Mobile_Phone__c') as 'unique_mobile';


-- renew converted this month
q_renew_converted_this_month = filter q by 
	'Last_Purchase_Membership__c' is not null
	&& 'J_Instr.Is_Active__c' == "true"
	&&  'Type_Of_Sale__c' in ["BurnedRenewCurrent", "BurnedRenewLast"]
	&& 	date('Order_Create_Date__c_Year', 'Order_Create_Date__c_Month', 'Order_Create_Date__c_Day') in ["current month" .. "current month"];

q_renew_converted_this_month =  group q_renew_converted_this_month by ('Studio_.Name', 'Account.Person_Mobile_Phone__c', 'Id');
q_renew_converted_this_month = foreach q_renew_converted_this_month generate 
		'Studio_.Name',
		'Account.Person_Mobile_Phone__c',
		'Id',
		unique('Account.Person_Mobile_Phone__c') as 'unique_mobile',
		average('Order_Item_Payment_Price__c') as 'Order_Item_Payment_Price__c';

q_renew_converted_this_month =  group q_renew_converted_this_month by ('Studio_.Name');
q_renew_converted_this_month = foreach q_renew_converted_this_month generate 
		'Studio_.Name',
		unique('Account.Person_Mobile_Phone__c') as 'unique_mobile',
		sum('Order_Item_Payment_Price__c')  as 'Order_Item_Payment_Price__c';


result = cogroup 	q_burned_this_month 			by ('Studio_.Name') full, 
                	q_renew_converted_this_month 	by ('Studio_.Name') 
                	;

r_renew_converted_this_month = foreach result generate 
	coalesce(
			q_burned_this_month.'Studio_.Name', 
			q_renew_converted_this_month.'Studio_.Name'
			) as 'Studio_.Name',
	
	sum(q_burned_this_month.'unique_mobile') as 'Burned amount this month', 
	sum(q_renew_converted_this_month.'unique_mobile') as 'Renew Converted amount this month',
	number_to_string(average(q_renew_converted_this_month.'unique_mobile')/sum(q_burned_this_month.'unique_mobile'), "#.00%") as 'Converted Rate',

	number_to_string(average(q_renew_converted_this_month.'Order_Item_Payment_Price__c'), "#.00") as 'Sum of converted packages',
	number_to_string(sum(q_renew_converted_this_month.'Order_Item_Payment_Price__c')/sum(q_renew_converted_this_month.'unique_mobile'), "#.00") as 'price per customer';
	;

r_renew_converted_this_month = order r_renew_converted_this_month by ('Studio_.Name' asc);

r_renew_converted_this_month = limit r_renew_converted_this_month 2000;

