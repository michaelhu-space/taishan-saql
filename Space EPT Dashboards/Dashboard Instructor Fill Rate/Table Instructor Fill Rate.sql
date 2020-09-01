q = load "Dataset_Class_Attendance";

q = filter q by date('Schedul.Class_Start_Time__c_Year', 'Schedul.Class_Start_Time__c_Month', 'Schedul.Class_Start_Time__c_Day') in ["2 month ago" .. "current month"];

-- booked reservations
q_booked = filter q by 'Reservation_Status__c' == "Confirmed";
q_booked = group q_booked by (
				'Schedul.Class_Start_Time__c_Year', 'Schedul.Class_Start_Time__c_Month','Schedul.Class_Start_Time__c_Day',
				'Schedul.Class_Start_Time__c_Hour', 'Schedul.Class_Start_Time__c_Minute',
				'Schedul.Studio_Name__c', 
				'Schedul.Id',
				'Classro.Name',
				'J_Instr.Instructor_Name__c',
				'J_Instr.Replacement_Instructor_Name__c',
				'Modalit.Name', 
				'Program.Name', 
				'Class__.Name'
			);

q_booked = foreach q_booked generate 
				'Schedul.Class_Start_Time__c_Year' + "~~~" + 'Schedul.Class_Start_Time__c_Month' + "~~~" + 'Schedul.Class_Start_Time__c_Day'  as 'Start Date', 
				'Schedul.Class_Start_Time__c_Hour' + "~~~" + 'Schedul.Class_Start_Time__c_Minute'  as 'Start Time', 
				'Schedul.Studio_Name__c', 
				'Classro.Name',
				'J_Instr.Instructor_Name__c' as 'Instructor',
				'J_Instr.Replacement_Instructor_Name__c' as 'Substitute',
				'Modalit.Name', 
				'Program.Name', 
				'Class__.Name',
				count() as 'Booked'
				;


-- waitlist reservations
q_waitlist = filter q by 'Reservation_Status__c' == "Waitlist";

-- checkin reservations
q_checkin = filter q by 'Operation_Status__c' == "Check In";


-- result = cogroup 	q_booked 				by (
-- 												'Schedul.Class_Start_Time__c_Year', 'Schedul.Class_Start_Time__c_Month','Schedul.Class_Start_Time__c_Day',
-- 												'Schedul.Class_Start_Time__c_Hour', 'Schedul.Class_Start_Time__c_Minute',
-- 												'Schedul.Studio_Name__c', 
-- 												'Schedul.Id'
-- 												'Classro.Name',
-- 												'Instruc.Name', 
-- 												'J_Instr.Replacement_Instructor_Name__c',
-- 												'Modalit.Name', 
-- 												'Program.Name', 
-- 												'Class__.Name',
-- 												'Schedul.Consumed_Classes__c',
-- 												'Schedul.Capacity__c') full, 
-- 					q_waitlist 				by (
-- 												'Schedul.Class_Start_Time__c_Year', 'Schedul.Class_Start_Time__c_Month','Schedul.Class_Start_Time__c_Day',
-- 												'Schedul.Class_Start_Time__c_Hour', 'Schedul.Class_Start_Time__c_Minute',
-- 												'Schedul.Studio_Name__c', 
-- 												'Schedul.Id'
-- 												'Classro.Name',
-- 												'Instruc.Name', 
-- 												'J_Instr.Replacement_Instructor_Name__c',
-- 												'Modalit.Name', 
-- 												'Program.Name', 
-- 												'Class__.Name',
-- 												'Schedul.Consumed_Classes__c',
-- 												'Schedul.Capacity__c') full, 
--                 	q_checkin 				by (
--                 								'Schedul.Class_Start_Time__c_Year', 'Schedul.Class_Start_Time__c_Month','Schedul.Class_Start_Time__c_Day',
-- 												'Schedul.Class_Start_Time__c_Hour', 'Schedul.Class_Start_Time__c_Minute',
-- 												'Schedul.Studio_Name__c', 
-- 												'Schedul.Id'
-- 												'Classro.Name',
-- 												'Instruc.Name', 
-- 												'J_Instr.Replacement_Instructor_Name__c',
-- 												'Modalit.Name', 
-- 												'Program.Name', 
-- 												'Class__.Name',
-- 												'Schedul.Consumed_Classes__c',
-- 												'Schedul.Capacity__c');


q_schedule_fill_rate = foreach q_schedule_fill_rate generate 
        'Schedul.Class_Start_Time__c_Year' + "-" + 'Schedul.Class_Start_Time__c_Month'  +"-" + 'Schedul.Class_Start_Time__c_Day' as 'Schedule Start YMD',
        'Schedul.Class_Start_Time__c_Hour' + ":" + 'Schedul.Class_Start_Time__c_Minute' as 'Schedule Start Time H:i',
        'Schedul.Studio_Name__c',
        'Classro.Name',
        'Instruc.Name', 
        'J_Instr.Replacement_Instructor_Name__c' as 'Substitute',
		'Modalit.Name', 
		'Program.Name', 
		'Schedul.Class__c',
		'Schedul.Consumed_Classes__c',
		'Schedul.Capacity__c';
-- get registered only user count
-- q_registered_only = foreach q_registered_only generate
--         'Studio_.Name',
--         sum('Account.Person_Mobile_Phone__c') as 'Account.Person_Mobile_Phone__c';

r_schedule_fill_rate = limit q_schedule_fill_rate 2000;

