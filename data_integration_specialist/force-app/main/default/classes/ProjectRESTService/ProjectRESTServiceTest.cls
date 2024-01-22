@isTest
private class ProjectRESTServiceTest
{
    @testSetup
    static void setUp()
    {
        // Test Arrange

        Account acc = new Account();
        acc.Name = 'acc';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'opp';
        opp.Type = 'New Project';
        opp.Amount = 100;
        opp.DeliveryInstallationStatus__c = 'In progress';
        opp.CloseDate = Date.today().addDays(5);
        opp.StageName = 'Prospecting';
        opp.AccountId = acc.Id;
        insert opp;

        // configure rest request
        PrepareRestRequest();
    }
      
    @isTest    
    static void testProjectRestServiceWasSuccesful()
    {
      // Arrange

      String URI = '/services/apexrest/project';
      Date today = Date.today();
      String expectedMessage = 'OK';
      String expectedInstallStatus = 'In progress';

      Opportunity opp = 
      [
        SELECT Id 
        FROM Opportunity
        WHERE Name = 'opp' 
        LIMIT 1
      ];
        
      // Act

      Test.startTest();
      // post project data
      String result_message = ProjectRESTService.postProjectData(
        'ref',
        'proj',
        opp.Id, 
        today, 
        today.addDays(5), 
        110, 
        'Running'
      );
      Test.stopTest();
        
      String install_Status = 
      [
        SELECT DeliveryInstallationStatus__c 
        FROM Opportunity
        WHERE Id = :opp.Id 
        LIMIT 1
      ].DeliveryInstallationStatus__c;
      
      // Assert

      System.assertEquals(install_Status, expectedInstallStatus);
      System.assertEquals(result_message, expectedMessage);
    }

    @isTest    
    static void testProjectRestServiceFailed()
    {
        Date today = Date.today();
        String wrongId = 'wrongId';
        String expectedMessage = 'Error - Invalid id: ' + wrongId;
        
        Test.startTest();
        // post project data
        String result_message = ProjectRESTService.postProjectData(
          'ref',
          'proj',
          wrongId, 
          today, 
          today.addDays(5), 
          110, 
          'Running'
        );
        Test.stopTest();

        System.assertEquals(result_message, expectedMessage);
    }

    // helper method
    private static void prepareRestRequest()
    {
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/project';
        RestContext.request = req;
    }
}