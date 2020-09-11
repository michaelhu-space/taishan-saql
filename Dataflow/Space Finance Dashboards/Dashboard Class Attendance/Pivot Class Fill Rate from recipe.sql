q = load "DataSource_Schedule_Fill_Rate";


-- publish schedules
q_schedule_fill_rate = filter q by 
        'Status__c' == "Published"
        && 'J_Instr.Is_Active__c' == "true"
;

q_schedule_attendance = group q_schedule_fill_rate by ('Studio_Name__c', 'Modalit.Name', 'ClassStartDateAddTimezone_Year','ClassStartDateAddTimezone_Month', 'Id');

q_schedule_attendance = foreach q_schedule_attendance generate 
    'Studio_Name__c', 
    'Modalit.Name', 
    'ClassStartDateAddTimezone_Year' + "-" + 'ClassStartDateAddTimezone_Month' as 'Start Date YM SH-TZ', 
    average('Capacity__c') as 'Capacity__c',
    average('Attended_Counts__c') as 'Attended_Counts__c';

q_schedule_attendance = group q_schedule_attendance by ('Studio_Name__c', 'Modalit.Name', 'Start Date YM SH-TZ');
result_rate = foreach q_schedule_attendance generate 
    'Studio_Name__c', 
    'Modalit.Name', 
    'Start Date YM SH-TZ', 
    sum('Capacity__c') as 'Capacity__c',
    sum('Attended_Counts__c') as 'Attended_Counts__c',
    number_to_string(sum('Attended_Counts__c')/sum('Capacity__c'), "#.00%") as 'Fill Rate';
    
result_rate = order result_rate by ('Studio_Name__c' asc, 'Modalit.Name' asc, 'Start Date YM SH-TZ' asc);

result_rate = limit result_rate 2000;
