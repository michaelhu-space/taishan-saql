q = load "DataSource_Class_Attendance";


-- query attendance count goup by studio, modality, classroom, year-month
q = group q by(  
                'Schedul.Studio_Name__c',
                'ClassStartDateAddTimezone_Year', 'ClassStartDateAddTimezone_Month',
                'Account.Identity__c',
				'Members.Product__c', 
                'Operation_Status__c', 
                'Id'
                );


q = foreach q generate 
                'Schedul.Studio_Name__c', 
                'ClassStartDateAddTimezone_Year' + "-" +'ClassStartDateAddTimezone_Month' as 'Schedule Start Time YM SH-TZ',
                'Account.Identity__c',
				'Members.Product__c', 
                'Operation_Status__c',
                'Id',
                average('Members.Average_Price__c') as 'Members_Average_Price_c_AVG',
                unique('Id') as 'Id_UNIQUE';



q_A = filter q by 'Members_Average_Price_c_AVG' > 0 && !('Account.Identity__c' in ["Employee", "Employee Family"]);
q_B = filter q by 'Members_Average_Price_c_AVG' == 0 && !('Account.Identity__c' in ["Employee", "Employee Family"]);
q_C = filter q by 'Account.Identity__c' in ["Employee", "Employee Family"] && 'Members.Product__c'=="01t2x000000dYP4AAM";
q_D = filter q by 'Account.Identity__c' in ["Employee", "Employee Family"] && 'Members.Product__c'=="01t2x000000dYWPAA2";
q_E = filter q by 'Account.Identity__c' in ["Employee", "Employee Family"] &&  ('Members.Product__c' in ["01t2x000000dYP4AAM", "01t2x000000dYWPAA2"]);

result = cogroup 	q_A by ('Schedul.Studio_Name__c', 'Schedule Start Time YM SH-TZ') full, 
                	q_B by ('Schedul.Studio_Name__c', 'Schedule Start Time YM SH-TZ') full,
                	q_C by ('Schedul.Studio_Name__c', 'Schedule Start Time YM SH-TZ') full,
                	q_D by ('Schedul.Studio_Name__c', 'Schedule Start Time YM SH-TZ') full,
                	q_E by ('Schedul.Studio_Name__c', 'Schedule Start Time YM SH-TZ')
                	;

result = foreach result generate 
	coalesce(
			q_A.'Schedul.Studio_Name__c', 
			q_B.'Schedul.Studio_Name__c',
			q_C.'Schedul.Studio_Name__c',
			q_D.'Schedul.Studio_Name__c',
			q_E.'Schedul.Studio_Name__c'
			) as 'Schedul.Studio_Name__c', 

	coalesce(
		q_A.'Schedule Start Time YM SH-TZ', 
		q_B.'Schedule Start Time YM SH-TZ',
		q_C.'Schedule Start Time YM SH-TZ',
		q_D.'Schedule Start Time YM SH-TZ',
		q_E.'Schedule Start Time YM SH-TZ'
		) as 'Schedule Start Time YM SH-TZ', 
	
	sum(q_A.'Id_UNIQUE') as 'Paid Attendance', 
	sum(q_B.'Id_UNIQUE') as 'Free Attendance', 
	sum(q_C.'Id_UNIQUE') as '一年会籍-无限型(员工/员眷)',
	sum(q_D.'Id_UNIQUE') as '(员工体验5课包)',
	sum(q_E.'Id_UNIQUE') as 'Employee Attendance'
	;

result = order result by ('Schedul.Studio_Name__c' asc, 'Schedule Start Time YM SH-TZ' asc);
result = limit result 20000;