q = load "Dataset_Class_Attendance";

-- query attendance count goup by studio, modality, classroom, year-month
q_count = group q by (  'Schedul.Studio_Name__c', 
                        'Modalit.Name', 
                        'Classro.Name', 
                        'Schedul.Class_Start_Time__c_Year', 'Schedul.Class_Start_Time__c_Month', 
                        'Schedul.Id');


r_count = foreach q_count generate 
                'Schedul.Studio_Name__c' as 'Schedul.Studio_Name__c', 
                'Modalit.Name' as 'Modalit.Name', 
                'Classro.Name' as 'Classro.Name', 
                'Schedul.Class_Start_Time__c_Year' as 'Schedul.Class_Start_Time__c_Year',
                'Schedul.Class_Start_Time__c_Month' as 'Schedul.Class_Start_Time__c_Month', 
                'Schedul.Id' as 'Schedul.Id';

r_count = group r_count by (
        'Schedul.Studio_Name__c', 
        'Modalit.Name', 
        'Classro.Name', 
        'Schedul.Class_Start_Time__c_Year', 'Schedul.Class_Start_Time__c_Month'
    );

r_count = foreach r_count generate 
                'Schedul.Studio_Name__c' as 'Studio Name', 
                'Modalit.Name' as 'Modality Name', 
                'Classro.Name' as 'Classroom Name', 
                'Schedul.Class_Start_Time__c_Year' + "~~~" + 'Schedul.Class_Start_Time__c_Month' as 'Schedul.Class_Start_Time__c_Year~~~Schedul.Class_Start_Time__c_Month', 
                count() as 'Schedule Count';


-- query schedule count goup by studio, year-month
q_subTotalOfStudio = group r_count by ('Studio Name', 
    'Schedul.Class_Start_Time__c_Year~~~Schedul.Class_Start_Time__c_Month');
r_subTotalOfStudio = foreach q_subTotalOfStudio generate 
    'Studio Name', 
    'Studio Name'+" 合计" as 'Modality Name', 
    'Schedul.Class_Start_Time__c_Year~~~Schedul.Class_Start_Time__c_Month',
    sum('Schedule Count') as 'Schedule Count';


-- query schedule count per day
r_classPerDayOfStudio = foreach r_subTotalOfStudio generate 
    'Studio Name', 
    'Studio Name'+" 每日排课比例" as 'Modality Name', 
    'Schedul.Class_Start_Time__c_Year~~~Schedul.Class_Start_Time__c_Month',
    number_to_string(sum('Schedule Count')/31/100, "#.00%") as 'Schedule Count';


-- order by studio, modality, classroom, year-month
r_count = order r_count by ('Studio Name' asc, 'Modality Name' asc, 'Classroom Name' asc, 'Schedul.Class_Start_Time__c_Year~~~Schedul.Class_Start_Time__c_Month' asc);

-- union data
r_count = union r_count
                ,r_subTotalOfStudio
                ,r_classPerDayOfStudio
                ;

-- render data in limit
r_count = limit r_count 20000;


