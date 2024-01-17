trigger MaintenanceRequest on Case (before update, after update)
{
    List<Case> casesToRefresh = new List<Case>();
    Map<Id, Case> casesToUpdate = Trigger.oldMap;
    
    for (Case request : Trigger.New)
    {
       Case oldRequest = casesToUpdate.get(request.Id);
       if (oldRequest.Status != 'Closed' && request.Status == 'Closed')
       {
           if (request.Type == 'Repair' || request.Type == 'Routine Maintenance')
           {
           	   Case newCase = MaintenanceRequestHelper.Create(request);
               casesToRefresh.add(newCase);
           }
       }
    }
    
 	insert casesToRefresh;
}