public with sharing class MaintenanceRequestHelper
{
    public static Case Refresh(Case c, Decimal equipmentMaintenanceCycle)
    {
        Case newRequest = new Case();
        newRequest.Type = 'Routine Maintenance';
        newRequest.Subject = 'Routine Checkup';
        newRequest.Status = 'New';
        newRequest.Origin = 'Web';
        newRequest.Date_Reported__c = System.today();
        newRequest.ClosedId__c = c.Id;
        //set the related vehicle
        newRequest.Vehicle__c = c.Vehicle__c;
        //set the related equipment
        newRequest.ProductId = c.ProductId;
        //set the due date
        newRequest.Date_Due__c = newRequest.Date_Reported__c.addDays(
            equipmentMaintenanceCycle.intValue()
        );

        return newRequest;
    }
    
    // update the equipment maintenance items with the new maintenance requests
    public static void UpdateEquipmentMaintenanceRequests(List<Case> newRequests)
    {
        Map<Id, Id> casesRedirection = new Map<Id, Id>();
        for (Case c : newRequests)
        {
            casesRedirection.put(c.ClosedId__c, c.Id);    
        }

        List<Equipment_Maintenance_Item__c> items = [
            SELECT Id, Maintenance_Request__c
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN :casesRedirection.keySet()
        ];

        for (Equipment_Maintenance_Item__c item : items)
        {
            item.Maintenance_Request__c = casesRedirection.get(item.Maintenance_Request__c);
        }

        if (!items.isEmpty())
            update items;
    }
}