/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public class TestDataFactory
{
    /**
     * @name ConstructCollaborationGroup
     * @description Returns a single Chatter CollaborationGroup whose Name starts with 'TEST' followed by
     * the INVENTORY_ANNOUNCEMENTS constant and configured so anyone can join, see and post updates.
    **/
    public static CollaborationGroup ConstructCollaborationGroup()
    {
        CollaborationGroup colabGroup = new CollaborationGroup();
        colabGroup.Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS;
        colabGroup.CollaborationType = 'Public';

        colabGroup.IsArchived = false;
        colabGroup.IsAutoArchiveDisabled = true;

        return colabGroup;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt)
    {
        Integer initialInventory = Constants.DEFAULT_INITIAL_INVENTORY;
        List<Schema.PicklistEntry> families = Constants.PRODUCT_FAMILY;

        List<Product2> newProductLst = new List<Product2>();
        for (Integer i = 0; i < cnt; i++)
        {
            Product2 newProduct = new Product2();
            newProduct.Name = 'Test Product ' + i;
            newProduct.Initial_Inventory__c = initialInventory;
            newProduct.IsActive = true;

            Integer idx = Math.mod(i, families.size());
            String familyValue = families[idx].getValue();
            newProduct.Family = familyValue;

            newProductLst.add(newProduct);
        }

        return newProductLst;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods)
    {
        Id standardPricebookId = Constants.STANDARD_PRICEBOOK_ID;
        Decimal defaultUnitPrice = Constants.DEFAULT_UNIT_PRICE;

        List<PricebookEntry> newPricebookEntryLst = new List<PricebookEntry>();
        for (Product2 prod : prods)
        {
            PricebookEntry newPricebookEntry = new PricebookEntry();
            newPricebookEntry.Product2Id = prod.Id;
            newPricebookEntry.Pricebook2Id = standardPricebookId;
            newPricebookEntry.UnitPrice = defaultUnitPrice;
            newPricebookEntry.IsActive = true;

            newPricebookEntryLst.add(newPricebookEntry);
        }

        return newPricebookEntryLst;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt)
    {
        List<Account> newAccountLst = new List<Account>();
        for (Integer i = 0; i < cnt; i++)
        {
            Account newAccount = new Account();
            newAccount.Name = 'Test Account ' + i;

            newAccountLst.add(newAccount);
        }

        return newAccountLst;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts)
    {
        List<Contact> newContactLst = new List<Contact>();
        for (Integer i = 0; i < cnt; i++)
        {
            Contact newContact = new Contact();
            newContact.LastName = 'Test Contact ' + i;

            Integer idx = Math.mod(i, accts.size());
            Account acc = accts[idx];
            newContact.AccountId = acc.Id;

            newContactLst.add(newContact);
        }

        return newContactLst;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts)
    {
        String draftStatus = Constants.DRAFT_ORDER_STATUS;
        Id standardPricebookId = Constants.STANDARD_PRICEBOOK_ID;

        List<Order> newOrderLst = new List<Order>();
        for (Integer i = 0; i < cnt; i++)
        {
            Order newOrder = new Order();
            newOrder.Name = 'Test Order ' + i;
            newOrder.EffectiveDate = Date.today();
            newOrder.Status = draftStatus;
            newOrder.Pricebook2Id = standardPricebookId;

            Integer idx = Math.mod(i, accts.size());
            Account acc = accts[idx];
            newOrder.AccountId = acc.Id;

            newOrderLst.add(newOrder);
        }

        return newOrderLst;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(Integer cnt, list<PricebookEntry> pbes, list<Order> ords)
    {
        Decimal defaultUnitPrice = Constants.DEFAULT_UNIT_PRICE;
        Integer defaultQuantity = Constants.DEFAULT_ROWS;

        List<OrderItem> newOrderItemLst = new List<OrderItem>();
        for (Integer i = 0; i < cnt; i++)
        {
            OrderItem newOrderItem = new OrderItem();
            newOrderItem.UnitPrice = defaultUnitPrice;
            newOrderItem.Quantity = defaultQuantity;

            Integer ordIdx = Math.mod(i, ords.size());
            Integer pbeIdx = Math.mod(i, pbes.size());

            newOrderItem.OrderId = ords[ordIdx].Id;
            newOrderItem.PriceBookEntryId = pbes[pbeIdx].Id;
            
            newOrderItemLst.add(newOrderItem);
        }

        return newOrderItemLst;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt)
    {
        // calls each of the construct methods and inserts the results for use as test data

        CollaborationGroup colabGroup = ConstructCollaborationGroup();
        insert colabGroup;

        List<Product2> newProducts = ConstructProducts(cnt);
        insert newProducts;

        List<PricebookEntry> newPricebookEntries = ConstructPricebookEntries(newProducts);
        insert newPricebookEntries;

        List<Account> newAccounts = ConstructAccounts(cnt);
        insert newAccounts;

        List<Contact> newContacts = ConstructContacts(cnt, newAccounts);
        insert newContacts;

        List<Order> newOrders = ConstructOrders(cnt, newAccounts);
        insert newOrders;

        List<OrderItem> newOrderItems = ConstructOrderItems(cnt, newPricebookEntries, newOrders);  
        insert newOrderItems;
    }

    // verify that the Quantity Ordered field is correctly updated on Products when Orders are activated
    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered)
    {
        Integer sumQty = Integer.valueOf(originalProduct.Quantity_Ordered__c) + qtyOrdered;
        System.assertEquals(updatedProduct.Quantity_Ordered__c, sumQty);
    }

}