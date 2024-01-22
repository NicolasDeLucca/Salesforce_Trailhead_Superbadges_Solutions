@RestResource(urlMapping='/project/*')
global class ProjectRESTService
{
    @HttpPost
    global static String postProjectData(
        String ref,
        String name,
        String oppId, 
        Date startDate,
        Date endDate,
        Double amount,
        String status
    )
    {
        SavePoint savepoint = Database.setSavePoint();
        String result_message = 'OK';
        try
        {
            // create a new project
            Project__c project = new Project__c();
            project.Name = name;
            project.Opportunity__c = oppId;
            project.Start_Date__c = startDate;
            project.End_Date__c = endDate;
            project.Billable_Amount__c = amount;
            project.Status__c = status;
            project.ProjectRef__c = ref;
            upsert project;
            // update the related opportunity
            Opportunity opp = new Opportunity();
            opp.Id = oppId;
            opp.DeliveryInstallationStatus__c = 'In progress';
            update opp;
        }
        catch(Exception e)
        {
            Database.rollback(savepoint);
            result_message = 'Error - ' + e.getMessage();
        }
        
        return result_message;
    }
}