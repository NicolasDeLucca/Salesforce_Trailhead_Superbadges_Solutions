public class Product2Helper
{
    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/

    static List<CollaborationGroup> COLLABORATION_GROUP = 
    [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name = :Constants.INVENTORY_ANNOUNCEMENTS 
        OR Name = :('TEST' + Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];

    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/

    public static void AfterUpdate(List<Product2> newList, List<Product2> oldList)
    {
        List<Product2> needsAnnouncement = new List<Product2>();
        Map<String, Inventory_Setting__mdt> mapInvSetting = new Map<String, Inventory_Setting__mdt>();
        
        List<Inventory_Setting__mdt> invSettingQry = 
        [
            SELECT Id, DeveloperName, Low_Quantity_Alert__c 
            FROM Inventory_Setting__mdt
        ];

        for (Inventory_Setting__mdt inv : invSettingQry)
        {
            mapInvSetting.put(inv.DeveloperName, inv);
        }

        for (Product2 prod : newList)
        {
            Integer idx = newList.indexOf(prod);
            Product2 oldProduct = oldList[idx];

            String invDeveloperName = prod.Family;
            Inventory_Setting__mdt inv = mapInvSetting.get(invDeveloperName);

            Boolean newQtyRemainingLessThanAlert = inv.Low_Quantity_Alert__c > prod.Quantity_Remaining__c;
            Boolean oldQtyRemainingNoLessThanAlert = inv.Low_Quantity_Alert__c <= oldProduct.Quantity_Remaining__c;
            
            // the product's Quantity Remaining has been changed to less than the Low Quantity Alert
            if (newQtyRemainingLessThanAlert && oldQtyRemainingNoLessThanAlert)
               needsAnnouncement.add(prod);
        }

        PostAlerts(needsAnnouncement);
    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/

    public static void PostAlerts(List<Product2> productList)
    {
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for (Product2 pdct : productList)
        {
            ConnectApi.AnnouncementInput alert = new ConnectApi.AnnouncementInput();
            alert.expirationDate = DateTime.Now().AddDays(1);
            alert.sendEmails = false;

            ConnectApi.TextSegmentInput txtSeg = new ConnectApi.TextSegmentInput();
            txtSeg.text = pdct.Name + ' ' + Constants.INVENTORY_LEVEL_LOW;

            ConnectApi.MessageBodyInput mssgBody = new ConnectApi.MessageBodyInput();
            mssgBody.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            mssgBody.messageSegments.add(txtSeg);
            
            alert.parentId = COLLABORATION_GROUP[0].Id;
            alert.body = mssgBody;

            toPost.add(alert);
        }

        AnnouncementQueueable annQueueable = new AnnouncementQueueable(toPost);
        System.enqueueJob(annQueueable);
    }
}