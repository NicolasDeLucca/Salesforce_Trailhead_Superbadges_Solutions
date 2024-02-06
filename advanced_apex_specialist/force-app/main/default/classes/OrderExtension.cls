/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/

public class OrderExtension
{
    ApexPages.StandardController standardController;
    ApexPages.StandardSetController standardSetController;

    public Order orderRecord { get; set; }
    public List<OrderItem> orderItemList { get; set; }
    public String selectedFamily { get; set; }
    public List<chartHelper.chartData> pieData { get; set; }
    public Decimal total { get; set; }
    public Map<Id, OrderItem> orderItemMap;

    public OrderExtension(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        this.orderRecord = (Order) standardController.getRecord();
        this.orderItemMap = new Map<Id, OrderItem>();
        
        if (this.orderRecord.Id != null)
            this.orderRecord = queryOrderRecord(this.orderRecord.Id);

        this.refreshSetController();
        this.populateTotalAndPieData();
        this.populateOrderItems();    
    }

    /**
     * @name OnFieldChange
     * @description This method stores the values changed on the page
    **/

    public void OnFieldChange()
    {
        for (OrderItem ordItem : this.orderItemList)
            this.orderItemMap.put(ordItem.Product2Id, ordItem);
        
        this.populateTotalAndPieData();
    }

    /**
     * @name SelectFamily
     * @description This method filters based on the selected product family
    **/

    public void SelectFamily()
    {        
        this.refreshSetController();
        this.populateOrderItems();
    }

    /**
     * @name Save
     * @description This method saves the order and populated order items
    **/

    public void Save()
    {
        System.Savepoint savePt = Database.setSavepoint();
        List<OrderItem> itemsToUpsert = new List<OrderItem>();
        List<OrderItem> itemsToDelete = new List<OrderItem>();

        if (this.orderRecord.Pricebook2Id == null)
            this.orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;

        try
        {
            upsert this.orderRecord;

            for (OrderItem ordItem : this.orderItemMap.values())
            {
                if (ordItem.Quantity > 0)
                {
                    if (ordItem.OrderId == null)
                        ordItem.OrderId = this.orderRecord.Id;
                    
                    itemsToUpsert.add(ordItem);
                }
                else if (ordItem.Id != null)
                {
                    OrderItem itemToDelete = new OrderItem(Id = ordItem.Id);
                    itemsToDelete.add(itemToDelete);
                    
                    ordItem.Id = null;
                }
            }

            upsert itemsToUpsert;
            delete itemsToDelete;
        }
        catch (Exception e)
        {
            ApexPages.message mssg = new ApexPages.message(ApexPages.Severity.INFO, Constants.ERROR_MESSAGE);
            apexPages.addMessage(mssg);

            Database.rollback(savePt);
        }
    }

    /**
     * @name First
     * @description
    **/

    public void First()
    {
        this.standardSetController.first();
        this.populateOrderItems();
    }

    /**
     * @name Next
     * @description
    **/

    public void Next()
    {
        this.standardSetController.next();
        this.populateOrderItems();
    }

    /**
     * @name Previous
     * @description
    **/

    public void Previous()
    {
        this.standardSetController.previous();
        this.populateOrderItems();
    }

    /**
     * @name Last
     * @description
    **/

    public void Last()
    {
        this.standardSetController.last();
        this.populateOrderItems();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/

    public Boolean GetHasPrevious()
    {
        return this.standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/

    public Boolean GetHasNext()
    {
        return this.standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/

    public Integer GetTotalPages()
    {
        Integer totalSize = this.standardSetController.getResultSize();
        Decimal rows = Constants.DEFAULT_ROWS;
        Decimal numberOfPages = totalSize / rows;

        return (Integer) Math.ceil(numberOfPages);
    }

    /**
     * @name GetPageNumber
     * @description
    **/

    public Integer GetPageNumber()
    {
        return this.standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/

    public List<SelectOption> GetFamilyOptions()
    {
        Product2Extension pdctExt = new Product2Extension(this.standardController);
        return pdctExt.GetFamilyOptions();
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/

    public static Order QueryOrderRecord(Id orderId)
    {
        return
        [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

    // helper methods

    /**
     * @name populateOrderItems
     * @description This method loads orderItems that we will call after pagination and/or family selection
    **/

    private void populateOrderItems()
    {
        this.orderItemList = new List<OrderItem>();
        
        for (SObject sObj : standardSetController.getRecords())
        {
          PricebookEntry pbEntry = (PricebookEntry) sObj;
          Id productId = pbEntry.Product2Id;
          OrderItem relatedItem = orderItemMap.get(productId);
          
          if (orderItemMap.containsKey(productId))
            this.orderItemList.add(relatedItem);
          else
          {
            OrderItem orderItem = new OrderItem(
              PricebookEntryId = pbEntry.Id,
              UnitPrice = pbEntry.UnitPrice,
              Product2Id = productId,
              Product2 = pbEntry.Product2,
              Quantity = 0
            );
            
            this.orderItemMap.put(productId, orderItem);
            this.orderItemList.add(orderItem);
          }
        }
    }

    /**
     * @name populateTotalAndPieData
     * @description This method keeps track of changes to values in the Quantity or Unit Price fields
    **/

    private void populateTotalAndPieData()
    {
        this.total = 0;
        this.pieData = new List<chartHelper.chartData>();

        List<OrderItem> orderItems = this.orderItemMap.values();
        for (OrderItem ordItem : orderItems)
        {
            if (ordItem.Quantity > 0)
            {
              String prodName = ordItem.Product2.Name;  
              Decimal totalPrice = ordItem.Quantity * ordItem.UnitPrice;

              chartHelper.ChartData data = new chartHelper.ChartData(prodName, totalPrice);
              this.pieData.add(data);

              this.total += totalPrice;
            }
        }
    }

    /**
     * @name refreshSetController
     * @description
    **/

    private void refreshSetController()
    {
        String pbEntryQuery = 
            'SELECT Name, UnitPrice, Product2Id, Product2.Name, Product2.Family, Product2.Quantity_Remaining__c ' +
            'FROM PricebookEntry ' +
            'WHERE IsActive = TRUE';
    
        if (this.selectedFamily != null && this.selectedFamily != Constants.SELECT_ONE)
            pbEntryQuery += ' AND Product2.Family = \'' + this.selectedFamily + '\'';
        pbEntryQuery += ' ORDER BY Name';
    
        Database.QueryLocator qryLocator = Database.getQueryLocator(pbEntryQuery);

        this.standardSetController = new ApexPages.StandardSetController(qryLocator);
        this.standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }

}