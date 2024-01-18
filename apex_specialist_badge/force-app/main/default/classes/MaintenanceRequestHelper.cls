public with sharing class MaintenanceRequestHelper
{
    public static Case Refresh(Case c, Decimal equipmentMaintenanceCycle)
    {
        Case newRequest = new Case();
        newRequest.Type = 'Routine Maintenance';
        newRequest.Subject = 'Routine Checkup';
        newRequest.Status = 'New';
        newRequest.Date_Reported__c = System.today();
        //set the parent vehicle
        newRequest.Vehicle__c = c.Vehicle__c;
        //set the related equipment
        newRequest.ProductId = c.ProductId;
        //set the due date
        newRequest.Date_Due__c = newRequest.Date_Reported__c.addDays(
            equipmentMaintenanceCycle.intValue()
        );

        return newRequest;
    }
    
    public static void UpdateEquipmentMaintenanceRequests(List<Case> newRequests)
    {
        // update the equipment maintenance items with the new maintenance requests
        
    }
}