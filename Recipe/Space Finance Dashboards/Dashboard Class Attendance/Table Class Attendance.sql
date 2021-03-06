q = load "Dataset_Class_Attendance";

q = foreach q generate 
	'Account.Channel__pc' as 'Account.Channel__pc',
	'Account.Gender__pc' as 'Account.Gender__pc',
	'Account.Identity__c' as 'Account.Identity__c',
	'Account.IsPersonAccount' as 'Account.IsPersonAccount',
	'Account.Name' as 'Account.Name',
	'Account.PersonEmail' as 'Account.PersonEmail',
	'Account.Person_Mobile_Phone__c' as 'Account.Person_Mobile_Phone__c',
	'Account.WeChat_Id__c' as 'Account.WeChat_Id__c',
	'Classro.Name' as 'Classro.Name',
	'Consumed_Classes__c' as 'Consumed_Classes__c',
	'Instruc.Name' as 'Instruc.Name',
	'Members.Average_Price__c' as 'Members.Average_Price__c',
	'Members.Main_Total_Available__c' as 'Members.Main_Total_Available__c',
	'Members.Main_Total_Class__c' as 'Members.Main_Total_Class__c',
	'Members.Main_Used_Class__c' as 'Members.Main_Used_Class__c',
	'Members.Name' as 'Members.Name',
	'Modalit.Name' as 'Modalit.Name',
	'Program.Name' as 'Program.Name',
	'RecordT.Name' as 'RecordT.Name',
	'Checkin_Time__c' as 'Checkin_Time__c',
	'Request_Type__c' as 'Request_Type__c',
	'Operation_Status__c' as 'Operation_Status__c',
	'Reservation_Status__c' as 'Reservation_Status__c',
	'Schedul.Capacity__c' as 'Schedul.Capacity__c',
	'Schedul.Class_Start_Time__c' as 'Schedul.Class_Start_Time__c',
	'Schedul.Consumed_Classes__c' as 'Schedul.Consumed_Classes__c',
	'Schedul.Studio_Name__c' as 'Schedul.Studio_Name__c',
	'Schedule__c' as 'Schedule__c';

q = limit q 10000;