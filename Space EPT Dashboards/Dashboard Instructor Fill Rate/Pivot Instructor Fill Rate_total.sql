q = load "Dataset_Schedule_Fill_Rate";

q = filter q by date('Class_Start_Time__c_Year', 'Class_Start_Time__c_Month', 'Class_Start_Time__c_Day') in [dateRange([2020,6,01], [2020,6,30])];

-- Primary instructor
q_primary_instructor = filter q by 
		'Status__c' == "Published"
		&& 'J_Instr.Is_Active__c' == "true"
		&& 'J_Instr.Instructor_Role__c' == "Primary Instructor"
		-- && 'J_Instr.Instructor_Name__c' == "王磊 Ray"
;
q_primary_instructor = foreach q_primary_instructor generate 
		'J_Instr.Instructor_Name__c' as 'Primary Instructor',
		"" as 'Substitute Instructor',
		"" as 'Assistant Instructor',
		'J_Instr.Instructor_Role__c',
		'Modalit.Name',
		unique('Id') as 'unique_Id';
q_primary_instructor = group q_primary_instructor by rollup ('Primary Instructor','Substitute Instructor','Assistant Instructor','Modalit.Name'); 
q_primary_instructor = foreach q_primary_instructor generate 
		
	    'Primary Instructor',
		'Substitute Instructor',
		'Assistant Instructor',
		(case
	        when grouping('Modalit.Name') == 1 then "～ Total"
	        else 'Modalit.Name'
	    end) as 'Modalit.Name',

		sum('unique_Id') as 'Attendance Count';


-- Substitute instructor
q_substitute_instructor = filter q by 
		'Status__c' == "Published"
		&& 'J_Instr.Is_Active__c' == "true"
		&& 'J_Instr.Instructor_Role__c' == "Substitute Instructor"
;
q_substitute_instructor = foreach q_substitute_instructor generate 
		'J_Instr.Original_Instructor_Name__c' as 'Primary Instructor',
		'J_Instr.Instructor_Name__c' as 'Substitute Instructor',
		"" as 'Assistant Instructor',
		'J_Instr.Instructor_Role__c',
		'Modalit.Name',
		unique('Id') as 'unique_Id';
q_substitute_instructor = group q_substitute_instructor by rollup('Primary Instructor','Substitute Instructor','Assistant Instructor','Modalit.Name'); 
q_substitute_instructor = foreach q_substitute_instructor generate 
		-- make sure dataset substitue doesn't have the total for primary instructor
		(case
	        when grouping('Modalit.Name') == 1 then ""
	        else 'Primary Instructor'
	    end) as 'Primary Instructor',
		'Substitute Instructor',
		'Assistant Instructor',
		(case
	        when grouping('Modalit.Name') == 1 then "～ Total"
	        else 'Modalit.Name'
	    end) as 'Modalit.Name',
		sum('unique_Id') as 'Attendance Count';


-- Assistant instructor
q_assistant_instructor = filter q by 
		'Status__c' == "Published"
		&& 'J_Instr.Is_Active__c' == "true"
		&& 'J_Instr.Instructor_Role__c' == "Assistant Instructor"
;
q_assistant_instructor = foreach q_assistant_instructor generate 
		"" as 'Primary Instructor',
		"" as 'Substitute Instructor',
		'J_Instr.Instructor_Name__c' as 'Assistant Instructor',
		'J_Instr.Instructor_Role__c',
		'Modalit.Name',
		unique('Id') as 'unique_Id';
q_assistant_instructor = group q_assistant_instructor by rollup('Primary Instructor','Substitute Instructor','Assistant Instructor','Modalit.Name'); 
q_assistant_instructor = foreach q_assistant_instructor generate 
		'Primary Instructor',
		'Substitute Instructor',
		'Assistant Instructor',
		(case
	        when grouping('Modalit.Name') == 1 then "～ Total"
	        else 'Modalit.Name'
	    end) as 'Modalit.Name',
		sum('unique_Id') as 'Attendance Count';






q_instructor_fill_rate = cogroup 	q_primary_instructor 		by ('Primary Instructor','Substitute Instructor','Assistant Instructor','Modalit.Name') full, 
									q_substitute_instructor 	by ('Primary Instructor','Substitute Instructor','Assistant Instructor','Modalit.Name') full, 
				                	q_assistant_instructor 		by ('Primary Instructor','Substitute Instructor','Assistant Instructor','Modalit.Name') 
				                	;


r_instructor_fill_rate = foreach q_instructor_fill_rate generate 
				
				coalesce(
					q_primary_instructor.'Primary Instructor',
					q_substitute_instructor.'Primary Instructor',
					q_assistant_instructor.'Primary Instructor'
				) as 'Primary Instructor',

				coalesce(
					q_primary_instructor.'Substitute Instructor',
					q_substitute_instructor.'Substitute Instructor',
					q_assistant_instructor.'Substitute Instructor'
				) as 'Substitute Instructor',

				coalesce(
					q_primary_instructor.'Assistant Instructor',
					q_substitute_instructor.'Assistant Instructor',
					q_assistant_instructor.'Assistant Instructor'
				) as 'Assistant Instructor',

				
				coalesce(
					q_primary_instructor.'Modalit.Name', 
					q_substitute_instructor.'Modalit.Name', 
					q_assistant_instructor.'Modalit.Name'
				) as 'Modalit.Name',

				coalesce(
					average(q_primary_instructor.'Attendance Count'), 
					average(q_substitute_instructor.'Attendance Count'), 
					average(q_assistant_instructor.'Attendance Count')
				) as 'Attendance Count'
				;

		
r_instructor_fill_rate = order r_instructor_fill_rate by ( 'Primary Instructor' asc, 'Substitute Instructor' asc);
r_instructor_fill_rate = limit r_instructor_fill_rate 10000;


