@isTest
private class OrderTests
{
    @testSetup
    static void SetupTestData()
    {
        Integer recordsListSize = 3;
        TestDataFactory.InsertTestData(recordsListSize);
    }
    
    @isTest
    static void OrderUpdate_UnitTest()
    {
        Test.startTest();

        // -----

        List<Product2> productsToUpdate = 
        [
            SELECT Quantity_Ordered__c
            FROM Product2 
        ];

        activateCreatedOrders();

        //verify that the Quantity Ordered field on Products was increased by the trigger
    
        List<Product2> updatedProducts = 
        [
            SELECT Quantity_Ordered__c
            FROM Product2
        ];
        
        for (Integer i=0; i < updatedProducts.size(); i++)
        {
            Product2 pToUpdate = productsToUpdate[i];
            Product2 updatedP = updatedProducts[i];

            TestDataFactory.VerifyQuantityOrdered(pToUpdate, updatedP, constants.DEFAULT_ROWS);
        }

        // -----

        Test.stopTest();
    } 

    private static void activateCreatedOrders()
    {
        List<Order> retrievedOrders = 
        [
            SELECT Status 
            FROM Order
        ];

        List<Order> ordersToUpdate = new List<Order>();

        for (Integer i=0; i < retrievedOrders.size(); i ++)
        {
            Order ord = retrievedOrders[i];
            ord.Status = Constants.ACTIVATED_ORDER_STATUS;

            ordersToUpdate.add(ord);
        }

        update ordersToUpdate;
    }
}