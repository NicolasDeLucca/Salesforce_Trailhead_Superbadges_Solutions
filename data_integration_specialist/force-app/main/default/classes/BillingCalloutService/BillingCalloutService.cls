public class BillingCalloutService
{
    private static String BILLING_CRENDENTIAL = 'BillingServiceCredential';
    private static String BILLED_STATUS = 'Billed';

    public static void callBillingService(List<Project__c> updatedProjects, String projStatus)
    {
        List<Project__c> projectsToUpdate = new List<Project__c>();

        for (Project__c proj : updatedProjects)
        {
            if (proj.Status__c != null && proj.Status__c == projStatus)
            {
                List<Project__c> projsToUpdate = getProjectsToUpdate(
                    proj.ProjectRef__c, 
                    proj.Billable_Amount__c
                );

                projectsToUpdate.addAll(projsToUpdate);
            }
        }

        if (!projectsToUpdate.isEmpty())
            update projectsToUpdate;
    }

    private static List<Project__c> getProjectsToUpdate(String ref, Decimal amount)
    {
        List<Project__c> projectsToUpdate = new List<Project__c>();
        ServiceCredentials__c credentials = ServiceCredentials__c.getValues(BILLING_CRENDENTIAL);

        try
        {
           proxyCallout(amount, credentials.Username__c, credentials.Password__c);
           
           List<Project__c> incomingProjects = 
            [
                SELECT Status__c 
                FROM Project__c 
                WHERE ProjectRef__c = :ref
            ];

            for (Project__c proj : incomingProjects)
            {
                // set status to billed
                proj.Status__c = BILLED_STATUS;

                projectsToUpdate.add(proj);
            }
        }
        catch(Exception e){}

        return projectsToUpdate;
    }

    @future(callout=true)
    private static void proxyCallout(Decimal amount, String userName, String password)
    {
        BillingServiceProxy.project proj = new BillingServiceProxy.project();
        proj.billAmount = amount;
        proj.username = userName;
        proj.password = password;

        BillingServiceProxy.InvoicesPortSoap11 invoices = new BillingServiceProxy.InvoicesPortSoap11();
        String res = invoices.billProject(proj);
        
        if (res == null || res.toUpperCase() != 'OK')
            throw new System.StringException();
    }
}