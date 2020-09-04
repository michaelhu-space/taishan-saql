q = load "Dataset_Schedule_Fill_Rate";

-- publish schedules
q_schedule_fill_rate = filter q by 
		'Status__c' == "Published"
		&& 'J_Instr.Is_Active__c' == "true"
;


r_schedule_fill_rate = foreach q_schedule_fill_rate generate 
				'Class_Start_Time__c_Year' + "-" + 'Class_Start_Time__c_Month' + "-" + 'Class_Start_Time__c_Day' as 'Schedule Start Y-M-D',
				'Class_Start_Time__c_Hour' + ":" + 'Class_Start_Time__c_Minute' as 'Schedule Start m:i',
				'Studio_Name__c', 
				-- 'Id',
				'Classro.Name',

				(case 
				      when 'J_Instr.Instructor_Role__c' == "Primary Instructor" then ('J_Instr.Instructor_Name__c') 
				      when  'J_Instr.Instructor_Role__c' == "Substitute Instructor" then ('J_Instr.Original_Instructor_Name__c') 
				      else ""
				end ) as 'Primary Instructor', 

				(case 'J_Instr.Instructor_Role__c'
				      when "Substitute Instructor" then ('J_Instr.Instructor_Name__c') 
				      else ""
				end ) as 'Substitute Instructor', 

				(case 'J_Instr.Instructor_Role__c'
				      when "Assistant Instructor" then ('J_Instr.Instructor_Name__c') 
				      else ""
				end ) as 'Assistant Instructor', 

				'Modalit.Name', 
				'Program.Name', 
				'Class__.Name',
				'Consumed_Classes__c',
				'Capacity__c',
				'Reservation_Counts__c',
				'WaitList_Counts__c',
				'Attended_Counts__c',
				number_to_string(Attendance_Rate__c/100, "%") as 'Attendance Rate'
				;
		
r_schedule_fill_rate = order r_schedule_fill_rate by ( 'Studio_Name__c' asc, 'Schedule Start Y-M-D' desc);
r_schedule_fill_rate = limit r_schedule_fill_rate 10000;


