@isTest
private class WarehouseSyncScheduleTest
{
    static String scheduleJobName = 'WarehouseSyncScheduleJob';

    @isTest static void testCalloutExecution()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseSyncSchedule sync = new WarehouseSyncSchedule();
        sync.execute(null);
        Test.stopTest();

        // callout job is in queue
        AsyncApexJob scheduledJob = 
        [
            SELECT ApexClass.Name, CreatedDate
            FROM AsyncApexJob
            WHERE ApexClass.Name = :scheduleJobName
            LIMIT 1
        ];

        system.assert(scheduledJob != null);
    }

    @isTest static void testCalloutExecutionWithException()
    {
        Test.startTest();
        //
        Test.stopTest();

        // callout job is not in queue
        AsyncApexJob scheduledJob = 
        [
            SELECT ApexClass.Name, CreatedDate
            FROM AsyncApexJob
            WHERE ApexClass.Name = :scheduleJobName
            LIMIT 1
        ];

        system.assert(scheduledJob == null);
    }
}