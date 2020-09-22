q_all = load "DataSource_Class_Attendance";


q_paid = filter q_all by 
    'Members.Average_Price__c' > 0 && !('Account.Identity__c' in ["Employee", "Employee Family"])
    ;


q_all_duration = filter q_all by
        date('ClassStartDateAddTimezone_Year', 'ClassStartDateAddTimezone_Month', 'ClassStartDateAddTimezone_Day') in ["1 day ago" .. "1 day ago"]
    -- && {{cell(StaticStart_1.selection, 0, \"value\").asDateRange(\"date('ClassStartDateAddTimezone_Year', 'ClassStartDateAddTimezone_Month', 'ClassStartDateAddTimezone_Day')\")}}
;

q_paid_duration = filter q_all_duration by
        'Members.Average_Price__c' > 0 && !('Account.Identity__c' in ["Employee", "Employee Family"])
;



q_paid_MTD = filter q_paid by 
    
    date('ClassStartDateAddTimezone_Year', 'ClassStartDateAddTimezone_Month', 'ClassStartDateAddTimezone_Day') in ["current month" .. "current month"]
    ;

q_paid_Last_year = filter q_paid by 
    
    date('ClassStartDateAddTimezone_Year', 'ClassStartDateAddTimezone_Month', 'ClassStartDateAddTimezone_Day') in ["1 year ago" .. "1 year ago"]
    ;


-- query all attendance count goup by studio
q_all_duration = group q_all_duration by(  'Schedul.Studio_Name__c','Id');
q_all_duration = foreach q_all_duration generate 
                'Schedul.Studio_Name__c', 
                'Id',
                1 as 'Id_UNIQUE';
q_all_duration = group q_all_duration by(  'Schedul.Studio_Name__c');                
r_all_duration = foreach q_all_duration generate 
                'Schedul.Studio_Name__c', 
                " # TOTAL ATTENDANCE" as 'Modalit.Name',
                sum('Id_UNIQUE') as 'TOTAL';


-- query paid attendance count goup by studio, modality
q_paid_duration = group q_paid_duration by(  'Schedul.Studio_Name__c','Modalit.Name','Id');
q_paid_duration = foreach q_paid_duration generate 
                'Schedul.Studio_Name__c', 
                'Modalit.Name',
                'Id',
                1 as 'Id_UNIQUE';

q_paid_duration_by_studio = group q_paid_duration by(  'Schedul.Studio_Name__c');
r_paid_duration_by_studio = foreach q_paid_duration_by_studio generate 
                'Schedul.Studio_Name__c', 
                " PAID ATTENDANCE" as 'Modalit.Name',
                sum('Id_UNIQUE') as 'TOTAL';

q_paid_duration_by_modality = group q_paid_duration by(  'Schedul.Studio_Name__c','Modalit.Name');
r_paid_duration_by_modality = foreach q_paid_duration_by_modality generate 
                'Schedul.Studio_Name__c', 
                'Modalit.Name',
                sum('Id_UNIQUE') as 'TOTAL';



-- query MTD attendance count goup by studio
q_paid_MTD = group q_paid_MTD by(  'Schedul.Studio_Name__c','Id');
q_paid_MTD = foreach q_paid_MTD generate 
                'Schedul.Studio_Name__c', 
                'Id',
                1 as 'Id_UNIQUE';
q_paid_MTD = group q_paid_MTD by(  'Schedul.Studio_Name__c');                
r_paid_MTD = foreach q_paid_MTD generate 
                'Schedul.Studio_Name__c', 
                "~ # MTD PAID ATTENDANCE" as 'Modalit.Name',
                sum('Id_UNIQUE') as 'TOTAL';

-- query last year attendance count goup by studio
q_paid_Last_year = group q_paid_Last_year by(  'Schedul.Studio_Name__c','Id');
q_paid_Last_year = foreach q_paid_Last_year generate 
                'Schedul.Studio_Name__c', 
                'Id',
                1 as 'Id_UNIQUE';
q_paid_Last_year = group q_paid_Last_year by(  'Schedul.Studio_Name__c');                
r_paid_Last_year = foreach q_paid_Last_year generate 
                'Schedul.Studio_Name__c',
                "~ LAST YEAR PAID ATTENDANCE" as 'Modalit.Name',
                sum('Id_UNIQUE') as 'TOTAL';




result = cogroup    r_all_duration               by ('Schedul.Studio_Name__c','Modalit.Name') full, 
                    r_paid_duration_by_studio    by ('Schedul.Studio_Name__c','Modalit.Name') full, 
                    r_paid_duration_by_modality  by ('Schedul.Studio_Name__c','Modalit.Name') full, 
                    r_paid_MTD          by ('Schedul.Studio_Name__c','Modalit.Name') full, 
                    r_paid_Last_year    by ('Schedul.Studio_Name__c','Modalit.Name')
                    ;

result = foreach result generate 
    coalesce(
            r_all_duration.'Schedul.Studio_Name__c', 
            r_paid_duration_by_studio.'Schedul.Studio_Name__c',
            r_paid_duration_by_modality.'Schedul.Studio_Name__c',
            r_paid_MTD.'Schedul.Studio_Name__c',
            r_paid_Last_year.'Schedul.Studio_Name__c'
            ) as 'Schedul.Studio_Name__c', 

    coalesce(
            r_all_duration.'Modalit.Name', 
            r_paid_duration_by_studio.'Modalit.Name',
            r_paid_duration_by_modality.'Modalit.Name',
            r_paid_MTD.'Modalit.Name',
            r_paid_Last_year.'Modalit.Name'
            ) as 'Modalit.Name',
    coalesce(
            average(r_all_duration.'TOTAL'), 
            average(r_paid_duration_by_studio.'TOTAL'),
            average(r_paid_duration_by_modality.'TOTAL'),
            average(r_paid_MTD.'TOTAL'),
            average(r_paid_Last_year.'TOTAL')
            ) as 'ATTENDANCE'
    ;

result = order result by ('Schedul.Studio_Name__c' asc);
result = limit result 20000;