q = load "Dataset_Schedule_Attendance";

result_rate = group q by ('Schedul.Studio_Name__c', 'Modalit.Name', 'Schedul_Schedule_Class_Start_Time_Year_Month');

result_rate = foreach result_rate generate 
    'Schedul.Studio_Name__c' as 'Schedul.Studio_Name__c', 
    'Modalit.Name' as 'Modalit.Name', 
    'Schedul_Schedule_Class_Start_Time_Year_Month' as 'Schedul_Schedule_Class_Start_Time_Year_Month', 
    sum('Schedul_Capacity_c_AVG') as 'Capacity',
    sum('Id_UNIQUE') as 'Attendance';

result_rate = foreach result_rate generate 
    'Modalit.Name', 
    'Schedul_Schedule_Class_Start_Time_Year_Month',
    'Capacity',
    'Attendance',
    number_to_string(Attendance/Capacity, "#.00%") as 'Fill Rate';
    
result_rate = order result_rate by ('Modalit.Name' asc, 'Schedul_Schedule_Class_Start_Time_Year_Month' asc);

result_rate = limit result_rate 2000;
