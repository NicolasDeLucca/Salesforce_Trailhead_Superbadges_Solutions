@isTest 
private class MaintenanceRequestHelperTest
{
    @isTest static void testMaintenanceRequestRecentlyClosed()
    {
        // arrange: create a closed maintenance request
        Case closedRequest = new Case(
            Status = 'Closed'
        );
        insert closedRequest;

        // act: call the Refresh method with a closed maintenance request
        Decimal maintenancePeriod = 180;
        Case refreshedRequest = MaintenanceRequestHelper.Refresh(closedRequest, maintenancePeriod);

        system.assertNotEquals(null, refreshedRequest);
    }

    @istTest static void testUpdateEquipmentMaintenanceRequests()
    {
        // 
    }
}