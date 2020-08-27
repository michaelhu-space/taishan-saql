q_membership = load "Database_Membership";
q_conversion = load "Recipe_Conversion_Rate";

-- trial this month
q_trial_this_month = filter q_membership by 
	(
	-- 'Average_Price__c' == 0 || 
	'Plan__c' == "Trial"
	 )
	&&  'Reserva.Operation_Status__c' == "Check In"
	&& 	date('Reserva.Checkin_Time__c_Year', 'Reserva.Checkin_Time__c_Month', 'Reserva.Checkin_Time__c_Day') in ["current month" .. "current month"];
q_trial_this_month =  group q_trial_this_month by ('Schedul.Studio_Name__c', 'Product.Name', 'Id');	
q_trial_this_month = foreach q_trial_this_month generate 
		'Schedul.Studio_Name__c',
		'Product.Name',
		unique('Account.Person_Mobile_Phone__c') as 'unique_mobile';


-- trial converted this month
q_trial_converted_this_month = filter q_conversion by 'Last_Purchase_Membership__c' is not null
	&&  'Type_Of_Sale__c' in ["FreeTrialNewCurrent", "PaidTrialNewCurrent", "CombinedTrialNewCurrent"]
	&& 	date('Databas.Reserva.Checkin_Time__c_Year', 'Databas.Reserva.Checkin_Time__c_Month', 'Databas.Reserva.Checkin_Time__c_Day') in 
	["{{cell(StaticStart_1.selection, 0, "value").asString()}}".."{{cell(StaticStart_1.selection, 0, "value").asString()}}"]

	&& 	date('Order_Create_Date__c_Year', 'Order_Create_Date__c_Month', 'Order_Create_Date__c_Day') in 
	["{{cell(StaticStart_1.selection, 0, "value").asString()}}".."{{cell(StaticStart_1.selection, 0, "value").asString()}}"]
	;

q_trial_converted_this_month =  group q_trial_converted_this_month by ('Studio_.Name', 'Databas.Product.Name', 'Id');
q_trial_converted_this_month = foreach q_trial_converted_this_month generate 
		'Studio_.Name',
		'Databas.Product.Name',
		unique('Account.Person_Mobile_Phone__c') as 'unique_mobile',
		average('Order_Item_Payment_Price__c') as 'Order_Item_Payment_Price__c';



result = cogroup 	q_trial_this_month 				by ('Schedul.Studio_Name__c', 'Product.Name') full, 
                	q_trial_converted_this_month 	by ('Studio_.Name', 'Databas.Product.Name') 
                	;

r_trial_converted_this_month = foreach result generate 
	coalesce(
			q_trial_this_month.'Schedul.Studio_Name__c', 
			q_trial_converted_this_month.'Studio_.Name'
			) as 'Studio Name',
	coalesce(
			q_trial_this_month.'Product.Name',
			q_trial_converted_this_month.'Databas.Product.Name'
			) as 'Product Name',
	
	sum(q_trial_this_month.'unique_mobile') as 'Trial amount this month', 
	sum(q_trial_converted_this_month.'unique_mobile') as 'Converted amount this month',
	number_to_string(sum(q_trial_converted_this_month.'unique_mobile')/sum(q_trial_this_month.'unique_mobile'), "#.00%") as 'Converted Rate',

	sum(q_trial_converted_this_month.'Order_Item_Payment_Price__c') as 'Sum of converted packages',
	number_to_string(sum(q_trial_converted_this_month.'Order_Item_Payment_Price__c')/sum(q_trial_converted_this_month.'unique_mobile'), "#.00") as 'price per customer';
	;


q_total = group r_trial_converted_this_month by (
    'Studio Name'
    );
r_total = foreach q_total generate 
    'Studio Name', 
    " " + 'Studio Name' + " 合计" as 'Product Name',
    sum('Trial amount this month') as 'Trial amount this month',
    sum('Converted amount this month') as 'Converted amount this month',
	number_to_string(sum('Converted amount this month')/sum('Trial amount this month'), "#.00%") as 'Converted Rate',
	sum('Sum of converted packages') as 'Sum of converted packages',
	number_to_string(sum('Sum of converted packages')/sum('Converted amount this month'), "#.00") as 'price per customer';

r_trial_converted_this_month = union r_trial_converted_this_month
                ,r_total
                ;

r_trial_converted_this_month = order r_trial_converted_this_month by ('Studio Name' asc, 'Product Name' desc);

r_trial_converted_this_month = limit r_trial_converted_this_month 2000;

