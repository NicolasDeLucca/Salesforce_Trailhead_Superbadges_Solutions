public with sharing class MaintenanceRequestHelper
{
    public static List<Case> getNewCases(Map<Id, Case> casesToRefreshMap, List<Case> updatedCases)
    {
        List<Case> newCases = new List<Case>();
        List<Product2> equipments = 
        [
            SELECT Id, Maintenance_Cycle__c 
            FROM Product2 
        ];

        for (Case request : updatedCases)
        {
            Case oldRequest = casesToRefreshMap.get(request.Id);
            Boolean requestRecentlyClosed = oldRequest.Status != 'Closed' && request.Status == 'Closed';
            Boolean requestToMaintain = request.Type == 'Repair' || request.Type == 'Routine Maintenance';

            if (requestRecentlyClosed && requestToMaintain)
            {
                List<Product2> requestEquipments = new List<Product2>();
                for (Product2 eq : equipments)
                {
                    if (request.ProductId != null && eq.Id == request.ProductId)
                        requestEquipments.add(eq);
                }   

                if (!requestEquipments.isEmpty())
                {
                    Product2 equip = requestEquipments[0];
                    for (Product2 associatedEquipment : requestEquipments)
                    {
                        if (equip.Maintenance_Cycle__c < associatedEquipment.Maintenance_Cycle__c)
                            equip = associatedEquipment;
                    }
                    Case newRequest = getNewRequest(request, equip.Maintenance_Cycle__c);
                    newCases.add(newRequest); 
                }                
            }
        }

        if (!newCases.isEmpty())
            insert newCases;

        return newCases;
    }
    
    public static void RefreshEquipmentMaintenanceRequests(List<Case> newRequests)
    {
        if (newRequests != null)
        {
            List<Equipment_Maintenance_Item__c> newItems = new List<Equipment_Maintenance_Item__c>();
            Map<Case, Id> caseIds = new Map<Case, Id>();
            
            for (Case c : newRequests)
                caseIds.put(c, c.Id);

            List<Equipment_Maintenance_Item__c> items = 
            [
                SELECT Id, Maintenance_Request__c, Quantity__c, Equipment__c
                FROM Equipment_Maintenance_Item__c
                WHERE Maintenance_Request__c IN :caseIds.values()
            ];

            for (Equipment_Maintenance_Item__c item : items)
            {
                Equipment_Maintenance_Item__c newItem = new Equipment_Maintenance_Item__c();
                newItem.Quantity__c = item.Quantity__c;
                newItem.Equipment__c = item.Equipment__c;
                newItem.Maintenance_Request__c = item.Maintenance_Request__c;

                newItems.add(newItem);
            }

            if (!items.isEmpty())
                insert items;
        }
    }

    private static Case getNewRequest(Case c, Decimal equipMaintenanceCycle)
    {
        Case newRequest = new Case();
        newRequest.Type = 'Routine Maintenance';
        newRequest.Subject = 'Routine Checkup';
        newRequest.Status = 'New';
        newRequest.Origin = 'Web';
        newRequest.Date_Reported__c = System.today();
        //set the related vehicle
        newRequest.Vehicle__c = c.Vehicle__c;
        newRequest.ParentId = c.ParentId;
        //set the related equipment
        newRequest.ProductId = c.ProductId;
        //set the due date
        newRequest.Date_Due__c = newRequest.Date_Reported__c.addDays(
            equipMaintenanceCycle.intValue()
        );  
        
        return newRequest;
    }
}