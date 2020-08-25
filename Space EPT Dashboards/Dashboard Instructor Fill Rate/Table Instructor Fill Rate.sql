q = load "Dataset_Class_Attendance";


-- register only this month
q_schedule = group q by (
	'Schedul.Class_Start_Time__c_Year', 'Schedul.Class_Start_Time__c_Month','Schedul.Class_Start_Time__c_Day',
	'Schedul.Class_Start_Time__c_Hour', 'Schedul.Class_Start_Time__c_Minute',
	'Schedul.Studio_Name__c', 
	'Classro.Name',
	-- 'Instruc.Name', 
	-- 'J_Instr.Replacement_Instructor_Name__c',
	'Modalit.Name', 
	'Program.Name', 
	'Schedul.Class__c',
	'Schedul.Id'
	);

q_checkin = filter q_schedule by 'Operation_Status__c' == "Check In";


q_schedule_fill_rate = foreach q_schedule_fill_rate generate 
        'Schedul.Class_Start_Time__c_Year' + "-" + 'Schedul.Class_Start_Time__c_Month'  +"-" + 'Schedul.Class_Start_Time__c_Day' as 'Schedule Start YMD',
        'Schedul.Class_Start_Time__c_Hour' + ":" + 'Schedul.Class_Start_Time__c_Minute' as 'Schedule Start Time H:i',
        'Schedul.Studio_Name__c',
        'Classro.Name',
        -- 'Instruc.Name', 
  --       'J_Instr.Replacement_Instructor_Name__c' as 'Substitute',
		-- -- (case 'RecordT.Name'
		-- --       when "Refund Personal Order" then (-1*'Refund_From_Membership_Paid_Amount__c')
		-- --       else ""
		-- -- end) as 'Paid_Amount__c', 
		'Modalit.Name', 
		'Program.Name', 
		'Schedul.Class__c',
		average('Schedul.Capacity__c') as 'Capacity',
		unique('Id') as 'Booked';
-- get registered only user count
-- q_registered_only = foreach q_registered_only generate
--         'Studio_.Name',
--         sum('Account.Person_Mobile_Phone__c') as 'Account.Person_Mobile_Phone__c';

r_schedule_fill_rate = limit q_schedule_fill_rate 2000;