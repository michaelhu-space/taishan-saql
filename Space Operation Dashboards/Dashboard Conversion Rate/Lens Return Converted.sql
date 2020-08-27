q = load "Recipe_Conversion_Rate";


-- 3 months ago from this month
q_expired_3_months = filter q by ( 'Average_Price__c' != 0 || 'Plan__c' != "Trial" )
	&& date('End_Date__c_Year', 'End_Date__c_Month', 'End_Date__c_Day') in [null .. "2 month ago"];

q_expired_3_months =  group q_expired_3_months by ('Studio_.Name', 'Id');	
q_expired_3_months = foreach q_expired_3_months generate 
		'Studio_.Name',
		unique('Account.Person_Mobile_Phone__c') as 'unique_mobile';


-- return converted this month
q_return_converted_this_month = filter q by 'Last_Purchase_Membership__c' is not null
	&&  'Type_Of_Sale__c' in ["Return"]
	&& 	date('Order_Create_Date__c_Year', 'Order_Create_Date__c_Month', 'Order_Create_Date__c_Day') in ["current month" .. "current month"];

q_return_converted_this_month =  group q_return_converted_this_month by ('Studio_.Name', 'Id');
q_return_converted_this_month = foreach q_return_converted_this_month generate 
		'Studio_.Name',
		unique('Account.Person_Mobile_Phone__c') as 'unique_mobile',
		average('Order_Item_Payment_Price__c') as 'Order_Item_Payment_Price__c';



result = cogroup 	q_expired_3_months 				by ('Studio_.Name') full, 
                	q_return_converted_this_month 	by ('Studio_.Name') 
                	;

r_return_converted_this_month = foreach result generate 
	coalesce(
			q_expired_3_months.'Studio_.Name', 
			q_return_converted_this_month.'Studio_.Name'
			) as 'Studio_.Name',
	
	sum(q_expired_3_months.'unique_mobile') as 'Burned amount this month', 
	sum(q_return_converted_this_month.'unique_mobile') as 'Renew Converted amount this month',
	number_to_string(sum(q_return_converted_this_month.'unique_mobile')/sum(q_expired_3_months.'unique_mobile'), "#.00%") as 'Converted Rate',

	sum(q_return_converted_this_month.'Order_Item_Payment_Price__c') as 'Sum of converted packages',
	number_to_string(sum(q_return_converted_this_month.'Order_Item_Payment_Price__c')/sum(q_return_converted_this_month.'unique_mobile'), "#.00") as 'price per customer';
	;

r_return_converted_this_month = order r_return_converted_this_month by ('Studio_.Name' asc);

r_return_converted_this_month = limit r_return_converted_this_month 2000;

