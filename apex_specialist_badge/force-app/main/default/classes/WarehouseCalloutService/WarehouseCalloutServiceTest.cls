@IsTest
private class WarehouseCalloutServiceTest
{
    @isTest static void testExternalSystemCalloutWorksAsExpected()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService service = new WarehouseCalloutService();
        service.execute(null);
        Test.stopTest();
    }
}