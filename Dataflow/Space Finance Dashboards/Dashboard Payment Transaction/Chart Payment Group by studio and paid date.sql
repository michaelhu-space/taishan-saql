q = load "Recipe_Order_for_Purchased";
   
-- paid payments
q_paid = filter q by 
	'RecordT.Name' != "Refund Personal Order"
	;

q_paid = foreach q_paid generate 
		'Studio_.Name', 
		'Total_Refund_Amount__c' as 'Order Amount', 
		'Payment.Pay_Amount__c' as 'Payment Amount', 
		"" as 'Refund Amount', 

		'RecordT.Name',
		'Payment.Name',

		'PaidDateAddTimezone_Year',
		'PaidDateAddTimezone_Month',

		'PaidDateAddTimezone_Year' + "~~~" + 'PaidDateAddTimezone_Month' as 'Paid Date SH TZ Year-Month'
		;


-- refund payments
q_refund = filter q by 
	'RecordT.Name' == "Refund Personal Order"
	;
-- q_refund = group q_refund by ('Studio_.Name', 'PaidDateAddTimezone_Year', 'PaidDateAddTimezone_Month', 'Payment.Name');
q_refund = foreach q_refund generate 
		'Studio_.Name',
		-1*'Total_Refund_Amount__c'  as 'Order Amount', 
		"" as 'Payment Amount', 
		-1*'Payment.Refund_Amount__c' as 'Refund Amount', 

		'RecordT.Name',
		'Payment.Name',

		'PaidDateAddTimezone_Year',
		'PaidDateAddTimezone_Month', 

		'PaidDateAddTimezone_Year' + "~~~" + 'PaidDateAddTimezone_Month' as 'Paid Date SH TZ Year-Month'
		;

r_chart = cogroup 	q_paid 		by ('Studio_.Name', 'Paid Date SH TZ Year-Month') full, 
            		q_refund 	by ('Studio_.Name', 'Paid Date SH TZ Year-Month') 
				                	;

r_chart = foreach r_chart generate 
	
	coalesce(
		q_paid.'Studio_.Name',
		q_refund.'Studio_.Name'
	) as 'Studio_.Name',

	coalesce(
		q_paid.'Paid Date SH TZ Year-Month',
		q_refund.'Paid Date SH TZ Year-Month'
	) as 'Paid Date SH TZ Year-Month',
	

	
	sum(q_paid.'Payment Amount') as 'Payment Amount',
	sum(q_refund.'Refund Amount') as 'Refund Amount';

r_chart = order r_chart by 'Studio_.Name' asc;
r_chart = limit r_chart 10000;






