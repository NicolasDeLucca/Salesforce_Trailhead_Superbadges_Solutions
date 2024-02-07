public class ProjectCalloutService
{
    private static String TOKEN = 'ProjectServiceToken';
    private static Integer SUCCESFUL_RESPONSE = 201;

    class QueueablePMSCall implements System.Queueable, Database.AllowsCallouts
    {
        public String OppId;
        private String token;
        private String inputJson;

        public QueueablePMSCall(String jsonOpp, String serviceToken)
        {
            this.token = serviceToken;
            this.inputJson = jsonOpp;
        }

        public void execute(System.QueueableContext context)
        {
            HTTPRequest req = new HTTPRequest();
            req.setEndPoint('callout:ProjectService');
            req.setMethod('POST');
            req.setHeader('token', this.token);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(this.inputJson);

            HTTPResponse res = new Http().send(req);
            Opportunity oppToUpdate = new Opportunity(Id = this.OppId);

            if (res.getStatusCode() == SUCCESFUL_RESPONSE)          
                oppToUpdate.StageName = 'Submitted Project';
            else 
                oppToUpdate.StageName = 'Resubmit Project';

            update oppToUpdate;
        }        
    }

    @InvocableMethod
	public static void postOpportunityToPMS(List<Id> oppIds)
    {
        Id oppId = oppIds[0];
        String headerToken = ServiceTokens__c.getValues(TOKEN).Token__c;

        Opportunity oppToPost = 
        [
            SELECT Id, Name, Account.Name, closeDate, Amount 
            FROM Opportunity 
            WHERE Id = :oppId
            LIMIT 1
        ];

        String jsonOpp = SerializeOpportunity(oppToPost);
        
        QueueablePMSCall callout = new QueueablePMSCall(jsonOpp, headerToken);
        callout.OppId = oppToPost.Id;

        System.enqueueJob(callout);
    }

    private static String SerializeOpportunity(Opportunity opp)
    {
        return
         '{' +
            '"opportunityId": "' + opp.Id +
            '", opportunityName": "' + opp.Name +
            '", accountName": "' + opp.Account.Name +
            '", closeDate": "' + String.ValueOf(opp.CloseDate) +
            '", amount": "' + opp.Amount +
         '}';
    }
}