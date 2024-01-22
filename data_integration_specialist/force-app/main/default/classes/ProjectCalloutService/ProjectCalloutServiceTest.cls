@isTest
private class ProjectCalloutServiceTest
{
    @testSetup
    static void setUp()
    {
        // Test Arrange

        Date today = Date.today();
        String service_Token = 'TOKEN';
        String oppType = 'New Project';

        Account acc = new Account();
        acc.Name = 'acc';
        insert acc;
        
        ServiceTokens__c servToken = new ServiceTokens__c();
        servToken.Name = 'ProjectServiceToken';
        servToken.Token__c = service_Token;
        insert servToken;   
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'opp1';
        opp1.Type = oppType;
        opp1.CloseDate = today;
        opp1.Amount = 50;
        opp1.StageName = 'Submitted Project';
        opp1.AccountId = acc.Id;
        insert opp1;

        Opportunity opp2 = new Opportunity();
        opp2.Name = 'opp2';
        opp2.Type = oppType;
        opp2.CloseDate = today;
        opp2.Amount = 100;
        opp2.StageName = 'Resubmit Project';
        opp2.AccountId = acc.Id;
        insert opp2;  
    }

    @isTest
    static void testSuccessStatusCode201()
    {
        String successStage = 'Submitted Project';

        Opportunity opp1 = 
        [
          SELECT Id, Name 
          FROM Opportunity 
          WHERE Name = 'opp1' 
          LIMIT 1
        ];

        List<Id> oppIds = new List<Id>();
        oppIds.add(opp1.Id);

        Test.startTest();
        // set success mock callout
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
        ProjectCalloutService.postOpportunityToPMS(oppIds);
        Test.stopTest();    

        String finalStageName = 
        [
          SELECT StageName 
          FROM Opportunity 
          WHERE Id = :opp1.Id
          LIMIT 1
        ].StageName;

        System.assertEquals(finalStageName, successStage);     
    }
  
    @isTest
    static void testFailureStatusCode500()
    {
        String failureStage = 'Resubmit Project';

        Opportunity opp2 = 
        [
          SELECT Id, Name 
          FROM Opportunity 
          WHERE Name = 'opp2' 
          LIMIT 1
        ];

        List<Id> oppIds = new List<Id>();
        oppIds.add(opp2.Id);

        Test.startTest();
        // set failure mock callout
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
        ProjectCalloutService.postOpportunityToPMS(oppIds);
        Test.stopTest();
       
        String finalStageName = 
        [
          SELECT StageName 
          FROM Opportunity 
          WHERE Id = :opp2.Id
          LIMIT 1
        ].StageName;

        System.assertEquals(finalStageName, failureStage);
    }
}