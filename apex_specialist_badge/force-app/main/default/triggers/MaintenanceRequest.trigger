trigger MaintenanceRequest on Case (after update)
{
    List<Case> casesToRefresh = new List<Case>();
    Map<Id, Case> casesToUpdate = Trigger.oldMap;

    List<Product2> equipments = 
    [
        SELECT Id, Maintenance_Cycle__c 
        FROM Product2 
    ];
    
    for (Case request : Trigger.New)
    {
       Case oldRequest = casesToUpdate.get(request.Id);
       if (oldRequest.Status != 'Closed' && request.Status == 'Closed')
       {
           if (request.Type == 'Repair' || request.Type == 'Routine Maintenance')
           {
                List<Product2> requestEquipments = new List<Product2>();
                for (Product2 equipment : equipments)
                {
                    if (equipment.Id == request.ProductId)
                        requestEquipments.add(equipment);
                }
                
                if (requestEquipments.size() > 0)
                {
                    Product2 associatedEquipment = requestEquipments[0];
                    for (Product2 equipment : equipments)
                    {
                        if (equipment.Maintenance_Cycle__c < associatedEquipment.Maintenance_Cycle__c)
                            associatedEquipment = equipment;
                    } 
                
                    Case newCase = MaintenanceRequestHelper.Refresh(request, associatedEquipment.Maintenance_Cycle__c);
                    casesToRefresh.add(newCase);
                }
           }
       }
    }
    
    insert casesToRefresh;
    MaintenanceRequestHelper.UpdateEquipmentMaintenanceRequests(casesToRefresh);
}