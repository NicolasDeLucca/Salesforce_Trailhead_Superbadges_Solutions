public class OrderHelper
{
    /**
     * @name AfterUpdate
     * @description Handles the logic after an Order update
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
     **/

    public static void AfterUpdate(List<Order> newList, List<Order> oldList)
    {
        try
        {
            RollUpOrderItems(newList);
        } 
        catch (Exception e){}
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param List<Order> updatedOrders
     * @return void
     **/

    public static void RollUpOrderItems(List<Order> updatedOrders)
    {
        // Declare a Map named "productMap" of Ids to Product2 records
        Map<Id, Product2> productMap = new Map<Id, Product2>();
    
        // List to store Product2 records for update
        List<Product2> productsToUpdate = new List<Product2>();
    
        // Determine the API name of the Order.Status field dynamically
        Schema.DescribeFieldResult orderStatusFieldDescribe = Order.Status.getDescribe();
        String activatedOrderStatus = Constants.ACTIVATED_ORDER_STATUS;
    
        // Build a dynamic SOQL query for OrderItems related to the updatedOrders
        String orderItemsQuery = 'SELECT OrderId, Quantity, Product2Id FROM OrderItem ' +
            'WHERE OrderId IN :updatedOrders ' +
            'AND Order.Status = \'' + activatedOrderStatus + '\'';
    
        List<OrderItem> orderItems = Database.query(orderItemsQuery);
    
        // Populate the map with the Id of the related Product2 as the key and Product2 record as the value
        for (OrderItem oi : orderItems)
        {
            // You may need to adjust this depending on your actual data model
            Product2 product = [SELECT Id, Quantity_Ordered__c FROM Product2 WHERE Id = :oi.Product2Id LIMIT 1];
            if (product != null)
                productMap.put(oi.Product2Id, product);
        }
    
        // Loop through a query that aggregates the OrderItems related to the Products in the ProductMap keyset
        List<AggregateResult> aggregatedResults =
        [
            SELECT Product2Id, SUM(Quantity) totalQuantity
            FROM OrderItem
            WHERE Product2Id IN :productMap.keySet()
            GROUP BY Product2Id
        ];
    
        // Perform an update on the records in the productMap
        for (AggregateResult aggResult : aggregatedResults)
        {
            Id productId = (Id)aggResult.get('Product2Id');
            Decimal totalQuantity = (Decimal)aggResult.get('totalQuantity');
            
            Product2 productToUpdate = productMap.get(productId);
            if (productToUpdate != null)
            {
                productToUpdate.Quantity_Ordered__c = totalQuantity;
                // Add the updated Product2 record to the list for update
                productsToUpdate.add(productToUpdate);
            }
        }
    
        // Update the records in the productMap
        if (productsToUpdate.size() > 0)
            update productsToUpdate;
    }    
}
