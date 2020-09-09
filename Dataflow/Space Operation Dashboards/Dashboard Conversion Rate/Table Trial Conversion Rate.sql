使用"connect data sources"来构建 两个数据源的字段关联，这样可以用同一个筛选器来对两个数据源进行筛选。


&& 	{{cell(StaticStart_1.selection, 0, "value").asDateRange("date('Databas.Reserva.Checkin_Time__c_Year', 'Databas.Reserva.Checkin_Time__c_Month', 'Databas.Reserva.Checkin_Time__c_Day')")}}
&& 	{{cell(StaticStart_1.selection, 0, "value").asDateRange("date('Order_Create_Date__c_Year', 'Order_Create_Date__c_Month', 'Order_Create_Date__c_Day')")}}