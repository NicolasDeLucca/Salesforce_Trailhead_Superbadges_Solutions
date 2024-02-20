public without sharing class ChartHelper
{
    @auraEnabled 
    public static List<chartData> GetInventory()
    {
        List<chartData> cht = new List<chartData>();

        // perform a calculation that aggregates active Products that have a positive Quantity_Remaining__c
        List<Product2> activeProducts = 
        [
            SELECT Name, Quantity_Remaining__c , Family
            FROM Product2 
            WHERE IsActive = true AND Quantity_Remaining__c > 0
        ];
        
        // return a list of chartData where the name is the Product Family and the Qty is the sum of the Quantity_Remaining__c
        Map<String, Decimal> productFamilyQtyMap = new Map<String, Decimal>();
        
        for (Product2 product : activeProducts)
        { 
            if (productFamilyQtyMap.containsKey(product.Family))
                productFamilyQtyMap.put(product.Family, productFamilyQtyMap.get(product.Family) + product.Quantity_Remaining__c);
            else 
                productFamilyQtyMap.put(product.Family, product.Quantity_Remaining__c);
        }
        
        for (String productFamily : productFamilyQtyMap.keySet())
        {
            Decimal quantity = productFamilyQtyMap.get(productFamily);
            chartData charData = new chartData(productFamily, quantity);

            cht.add(charData);
        }

        return cht;
    }

    public class ChartData
    {
        public String name { get; set; }
        public Decimal val { get; set; }

        public ChartData(String name, Decimal val)
        {
            this.name = name;
            this.val = val;
        }
    }
}