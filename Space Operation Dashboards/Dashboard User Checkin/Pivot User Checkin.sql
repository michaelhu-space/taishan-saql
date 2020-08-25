q = load "Dataset_Class_Attendance";

-- query attendance count goup by studio, modality, classroom, year-month
q_count = group q by (  
                'Account.Name', 
                'Account.Person_Mobile_Phone__c',
                'Schedul.Studio_Name__c', 
                'Modalit.Name', 
                'Classro.Name', 
                'Schedul.Class_Start_Time__c_Year', 'Schedul.Class_Start_Time__c_Month','Schedul.Class_Start_Time__c_Day'
                );


r_count = foreach q_count generate 
                'Account.Name', 
                'Account.Person_Mobile_Phone__c',
                'Schedul.Studio_Name__c' as 'Schedul.Studio_Name__c', 
                'Modalit.Name' as 'Modalit.Name', 
                'Classro.Name' as 'Classro.Name', 
                'Schedul.Class_Start_Time__c_Year' as 'Schedul.Class_Start_Time__c_Year',
                'Schedul.Class_Start_Time__c_Month' as 'Schedul.Class_Start_Time__c_Month', 
                'Schedul.Class_Start_Time__c_Day' as 'Schedul.Class_Start_Time__c_Day', 
                -- 'Schedul.Class_Start_Time__c_Week' as 'Schedul.Class_Start_Time__c_Week', 
                unique('Id') as 'Id_UNIQUE';



r_count = foreach r_count generate 
                'Account.Name' as 'Account.Name', 
                'Account.Person_Mobile_Phone__c' as 'Account.Person_Mobile_Phone__c', 
                'Schedul.Class_Start_Time__c_Year' + "-" + 'Schedul.Class_Start_Time__c_Month'  +"-" + 'Schedul.Class_Start_Time__c_Day'
                as 'Schedule Start Time YMD',
                -- 'Schedul.Class_Start_Time__c_Week' as 'Schedul.Class_Start_Time__c_Week',
                sum('Id_UNIQUE') as 'Attendance Count';
                


q_total = group r_count by (
	'Account.Name'
    );
r_total = foreach q_total generate 
    'Account.Name', 
    "合计" as 'Account.Person_Mobile_Phone__c', 
    "" as 'Schedule Start Time YMD',
    sum('Attendance Count') as 'Attendance Count';


r_count = union r_count
                ,r_total
                -- ,r_classPerDayOfStudio
                ;

r_count = order r_count by (
    'Account.Name' asc,
    'Account.Person_Mobile_Phone__c' asc,
    'Schedule Start Time YMD' asc
    -- 'Schedul.Class_Start_Time__c_Week' desc
    );		

-- render data in limit
r_count = limit r_count 20000;


