q = load "Recipe_Order_Payment";

r_table = foreach q generate 
		'Order_lookup_RecordType.Name' as 'Recordy Type Name',
		'Order_lookup_Studio.Name' as 'Studio Name', 
		'OrderNumber' as 'OrderNumber',
		'Order_left_join_Payment.Name' as 'Payment Number', 
		'Order_left_join_Payment.Reference_Number__c' as 'Payment Reference Number', 
		(case 'Order_lookup_RecordType.Name'
		      when "Refund Personal Order" then (-1*'Total_Refund_Amount__c')
		      else 'Paid_Amount__c'
		end) as 'Order Amount', 
		
		(case 'Order_lookup_RecordType.Name'
		      when "Refund Personal Order" then (-1*'Order_left_join_Payment.Refund_Amount__c')
		      else 'Order_left_join_Payment.Pay_Amount__c'
		end) as 'Payment Amount', 

		'Order_lookup_Account.Name' as 'Account Name', 
		'Order_lookup_Account.Person_Mobile_Phone__c' as 'Account Mobile', 

		'Order_left_join_Payment.Payment_Type__c' as 'Payment Type', 
		'Order_left_join_Payment.Bank_Information__c' as 'Payment Bank Information', 
		
		'Order_Payment_lookup_Payment.PaymentDateAddTimezone' as 'Payment Datetime SH TS', 
		'Order_Payment_lookup_Payment.PaymentDateAddTimezone_Year' as 'Payment Datetime SH Year', 
		'Order_Payment_lookup_Payment.PaymentDateAddTimezone_Month' as 'Payment Datetime SH Month', 
		'Order_left_join_Payment.Payment_Method__c' as 'Payment Method',
		'Order_left_join_Payment.Status__c' as 'Payment Status', 
		
		'Type' as 'Type',
		'Order_lookup_Account.Channel__pc' as 'Account Channel', 
		'Order_lookup_Account.Gender__pc' as 'Account Gender', 
		'Order_lookup_Account.Identified_By__c' as 'Account Identified', 
		'Order_lookup_Account.IsPersonAccount' as 'Account Is Person', 
		'Order_lookup_Account.Is_Newcomer__c' as 'Account Is_Newcomer'
		
		;

r_table = limit r_table 5000;

