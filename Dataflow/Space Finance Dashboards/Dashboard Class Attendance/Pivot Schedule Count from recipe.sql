q = load "DataSource_Class_Attendance";

q = filter q by 'Schedul.Status__c' == "Published";

-- query attendance count goup by studio, modality, classroom, year-month
q_count = group q by(  
                'Schedul.Studio_Name__c',
                'Modalit.Name', 
                'Classro.Name', 
                'ClassStartDateAddTimezone_Year', 'ClassStartDateAddTimezone_Month'
                );


r_count = foreach q_count generate 
                'Schedul.Studio_Name__c' as 'Studio Name', 
                'Modalit.Name' as 'Modality Name',
                'Classro.Name' as 'Classroom Name', 
                'ClassStartDateAddTimezone_Year' + "-" +'ClassStartDateAddTimezone_Month' as 'Schedule Start Time YM SH-TZ',
                
                unique('Schedul.Id') as 'Schedule Count';




-- query subtotal of attendance count goup by studio, year-month
q_subTotalOfStudio = group r_count by ('Studio Name', 
    'Schedule Start Time YM SH-TZ');
r_subTotalOfStudio = foreach q_subTotalOfStudio generate 
    'Studio Name', 
    'Studio Name'+" 合计" as 'Modality Name', 
    'Schedule Start Time YM SH-TZ',
    sum('Schedule Count') as 'Schedule Count';

-- query schedule count per day goup by studio, year-month
r_classPerDayOfStudio = foreach r_subTotalOfStudio generate 
    'Studio Name', 
    'Studio Name'+" 每日排课比例" as 'Modality Name', 
    'Schedule Start Time YM SH-TZ',
    number_to_string(sum('Schedule Count')/31/100, "#.00%") as 'Schedule Count';



r_count = order r_count by ('Studio Name' asc, 'Modality Name' asc, 'Classroom Name' asc, 'Schedule Start Time YM SH-TZ' asc);


-- union data
r_count = union r_count
                ,r_subTotalOfStudio
                ,r_classPerDayOfStudio
                ;

-- render data in limit
r_count = limit r_count 20000;

