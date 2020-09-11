q = load "DataSource_Schedule_Fill_Rate";

-- publish schedules
q_schedule_fill_rate = filter q by 
		'Status__c' == "Published"
		&& 'J_Instr.Is_Active__c' == "true"
;


r_schedule_fill_rate = foreach q_schedule_fill_rate generate 
				'ClassStartDateAddTimezone_Year' + "-" + 'ClassStartDateAddTimezone_Month' + "-" + 'ClassStartDateAddTimezone_Day' as 'Start Y-M-D SH TZ',
				'ClassStartDateAddTimezone_Hour' + ":" + 'ClassStartDateAddTimezone_Minute' as 'Start m:i SH TZ',
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
		
r_schedule_fill_rate = order r_schedule_fill_rate by ( 'Studio_Name__c' asc, 'Start Y-M-D SH TZ' desc);
r_schedule_fill_rate = limit r_schedule_fill_rate 10000;


