@isTest
private class OrderTests
{
    private static final Integer RECORDS_LIST_SIZE = 3;

    @testSetup
    static void SetupTestData()
    {
        TestDataFactory.InsertTestData(RECORDS_LIST_SIZE);
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
        
        for (Integer i = 0; i < updatedProducts.size(); i++)
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

        for (Integer i = 0; i < retrievedOrders.size(); i ++)
        {
            Order ord = retrievedOrders[i];
            ord.Status = Constants.ACTIVATED_ORDER_STATUS;

            ordersToUpdate.add(ord);
        }
	
        if (ordersToUpdate.size() > 0)
       		update ordersToUpdate;
    }

    @isTest
    static void OrderExtension_UnitTest()
    {
        Test.startTest();
        Test.setCurrentPage(Page.OrderEdit);
        
        //-----

        Order ord = 
        [
            SELECT Id, Status 
            FROM Order 
            LIMIT 1
        ];
        
        ApexPages.StandardController controller = new ApexPages.StandardController(ord);
        OrderExtension ext = new OrderExtension(controller);

        System.assert(ext.orderItemList != null);
        System.assertEquals(ext.orderItemList.size(), RECORDS_LIST_SIZE);

        ext.OnFieldChange();
        ext.SelectFamily();
        ext.Save();
        ext.First();
        ext.Next();
        ext.Previous();
        ext.Last();
        ext.GetHasPrevious();
        ext.GetHasNext();
        ext.GetTotalPages();
        ext.GetPageNumber();
        ext.GetFamilyOptions();
        OrderExtension.QueryOrderRecord(ord.Id);

        //-----

        Test.stopTest();
    }
}