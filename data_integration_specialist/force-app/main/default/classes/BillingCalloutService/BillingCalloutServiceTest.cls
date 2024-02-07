@isTest
private class BillingCalloutServiceTest 
{
    @testSetup 
    static void setUp()
    {
        // TEST ARRANGE 

        Opportunity opp = new Opportunity();
        opp.Name = 'opp';
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';

        insert opp;
        
        Project__c proj = new Project__c();
        proj.Opportunity__c = opp.Id;
        proj.Name = 'proj';
        proj.Billable_Amount__c = 2000;        
        proj.ProjectRef__c = 'ref';
        proj.Status__c = 'Running';

        insert proj;
        
        ServiceCredentials__c credentials = new ServiceCredentials__c();
        credentials.Name = 'BillingServiceCredential';
        credentials.Username__c = 'bsUser1';
        credentials.Password__c = 'bsPass1';

        insert credentials;
    }
    
    @isTest static void testCalloutSuccesful()
    {
        Project__c proj = 
        [
            SELECT Status__C 
            FROM Project__c 
            WHERE ProjectRef__c = 'ref'
            LIMIT 1
        ];

        Assert.isNotNull(proj);

        Test.startTest();

        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());  
        proj.Status__c = 'Billable';
        update proj;

        Test.stopTest();
    }
    
    @isTest static void testCalloutFailed()
    {
        Project__c proj = 
        [
            SELECT Status__C 
            FROM Project__c 
            WHERE ProjectRef__c = 'ref'
            LIMIT 1
        ];

        Assert.isNotNull(proj);

        Test.startTest();

        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());  
        proj.Status__c = 'Running';
        update proj;

        Test.stopTest();
    }    
}