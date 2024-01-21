trigger MaintenanceRequest on Case (after update)
{
    List<Case> newCases = MaintenanceRequestHelper.getNewCases(
        Trigger.OldMap,
        Trigger.New
    );
    
    MaintenanceRequestHelper.RefreshEquipmentMaintenanceRequests(newCases);
}


                
                
