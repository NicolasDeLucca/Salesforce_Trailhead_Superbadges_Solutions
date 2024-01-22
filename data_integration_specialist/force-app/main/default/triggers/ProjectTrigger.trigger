trigger ProjectTrigger on Project__c (after update)
{ 
    private static String PROJECT_STATUS = 'Billable';
    List<Project__c> updatedProjects = Trigger.New;

    BillingCalloutService.callBillingService(updatedProjects, PROJECT_STATUS);             
}