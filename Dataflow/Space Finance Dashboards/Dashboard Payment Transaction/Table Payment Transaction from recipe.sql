q = load "DataSource_Order_Payment";

r_table = foreach q generate 
		'RecordT.Name' as 'RecordT.Name',
		'Studio_.Name' as 'Studio_.Name', 
		'OrderNumber' as 'OrderNumber',
		'Payment.Name' as 'Payment.Name', 
		'Payment.Reference_Number__c' as 'Payment.Reference_Number__c', 
		(case 'RecordT.Name'
		      when "Refund Personal Order" then (-1*'Total_Refund_Amount__c')
		      else 'Paid_Amount__c'
		end) as 'Order Amount', 
		
		(case 'RecordT.Name'
		      when "Refund Personal Order" then (-1*'Payment.Refund_Amount__c')
		      else 'Payment.Pay_Amount__c'
		end) as 'Payment Amount', 

		'Account.Name' as 'Account.Name', 
		'Account.Person_Mobile_Phone__c' as 'Account.Person_Mobile_Phone__c', 

		'Payment.Payment_Type__c' as 'Payment.Payment_Type__c', 
		'Payment.Bank_Information__c' as 'Payment.Bank_Information__c', 
		
		date_to_string(toDate('Payment.Payment_Date__c_sec_epoch'), "yyyy-MM-dd HH:mm:ss") as 'Payment Datetime GMT', 
		date_to_string(toDate('PaymentDateAddTimezone_sec_epoch'), "yyyy-MM-dd HH:mm:ss") as 'Payment Datetime SH TS', 
		'PaymentDateAddTimezone_Year' as 'Payment Datetime SH Year', 
		'PaymentDateAddTimezone_Month' as 'Payment Datetime SH Month', 
		'Payment.Payment_Method__c' as 'Payment.Payment_Method__c',
		'Payment.Status__c' as 'Payment.Status__c', 
		
		'Type' as 'Type',
		'Account.Channel__pc' as 'Account.Channel__pc', 
		'Account.Gender__pc' as 'Account.Gender__pc', 
		'Account.Identified_By__c' as 'Account.Identified_By__c', 
		'Account.IsPersonAccount' as 'Account.IsPersonAccount', 
		'Account.Is_Newcomer__c' as 'Account.Is_Newcomer__c', 
		

		'Pre_tax_Price__c' as 'Pre_tax_Price__c', 
		'Refund_Fee_Charge_Tax__c' as 'Refund_Fee_Charge_Tax__c', 
		'Refund_From_Membership_Paid_Amount__c' as 'Refund_From_Membership_Paid_Amount__c', 
		'Tax_Rate__c' as 'Tax_Rate__c'
		;

r_table = limit r_table 50000;

