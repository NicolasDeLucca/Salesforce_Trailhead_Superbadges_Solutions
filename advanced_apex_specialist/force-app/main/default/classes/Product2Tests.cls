@isTest (seeAllData=true)
private class Product2Tests
{
    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/

    @isTest 
    static void Product2Extension_UnitTest()
    {
        // idea: simulation of a user interaction with the Product2New page

        Test.startTest();
        Test.setCurrentPage(Page.Product2New);
        
        //-----

        Product2 p = new Product2(
            Name='Test Product', IsActive=true
        );

        ApexPages.StandardController controller = new ApexPages.StandardController(p);
        Product2Extension ext = new Product2Extension(controller);

        System.assert(ext.productsToInsert != null);
        System.assertEquals(ext.productsToInsert.size(), Constants.DEFAULT_ROWS);

        ext.AddRows();
        System.assertEquals(ext.productsToInsert.size(), Constants.DEFAULT_ROWS * 2);

        Integer expectedPopulateRows = 5;
        populateRows(ext, expectedPopulateRows);
        ext.Save();

        ext.GetInventory();
        ext.GetFamilyOptions();

        //-----

        Test.stopTest();

        Integer createdProductsSize = 
        [
            SELECT COUNT() 
            FROM Product2
        ];

        System.assertEquals(createdProductsSize, expectedPopulateRows);
    }

    // helper method to populate N rows
    private static void populateRows(Product2Extension ext, Integer N_ROWS)
    {
        for (Integer i = 0; i < N_ROWS; i ++)
        {
            Product2Extension.ProductWrapper pWrapper = ext.productsToInsert[i];

            Product2 p = new Product2(
                Name = 'Test Product ' + i,
                Initial_Inventory__c = 10,
                IsActive = true,
                Family = Constants.PRODUCT_FAMILY[0].
                    getValue()
            );

            PricebookEntry pbEntry = new PricebookEntry(
                UnitPrice = 100,
                IsActive = true
            );

            pWrapper.productRecord = p;
            pWrapper.pricebookEntryRecord = pbEntry;
        }
    }
}