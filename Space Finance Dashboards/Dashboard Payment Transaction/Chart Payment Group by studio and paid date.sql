q = load "Recipe_Order_for_Purchased";
    q = filter q by 'Status'=="Active";
r_table = foreach q generate 
		'Studio_.Name' as 'Studio_.Name', 
		(case 'RecordT.Name'
		      when "Refund Personal Order" then (-1*'Refund_From_Membership_Paid_Amount__c')
		      else 'Paid_Amount__c'
		end) as 'Paid_Amount__c', 
		
		(case 'RecordT.Name'
		      when "Refund Personal Order" then (-1*'Payment.Pay_Amount__c')
		      else 'Payment.Pay_Amount__c'
		end) as 'Payment.Pay_Amount__c', 

		'Payment.Payment_Date__c_Year',
		'Payment.Payment_Date__c_Month'
		;
-- r_table = limit r_table 10000;

r_chart = group r_table by ('Studio_.Name', 'Payment.Payment_Date__c_Year', 'Payment.Payment_Date__c_Month');
r_chart = foreach r_chart generate 
	'Studio_.Name' as 'Studio_.Name', 
	'Payment.Payment_Date__c_Year' + "~~~" + 'Payment.Payment_Date__c_Month' as 'Payment.Payment_Date__c_Year~~~Payment.Payment_Date__c_Month', 
	sum('Payment.Pay_Amount__c') as 'sum_Payment.Pay_Amount__c';

r_chart = order r_chart by 'Studio_.Name' asc;
r_chart = limit r_chart 10000;