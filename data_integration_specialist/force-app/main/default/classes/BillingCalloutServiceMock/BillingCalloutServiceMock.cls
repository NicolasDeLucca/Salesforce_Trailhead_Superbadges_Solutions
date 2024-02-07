@isTest
global class BillingCalloutServiceMock implements WebServiceMock 
{
   private String RESPONSE_STATUS = 'OK'; 
   private String RESPONSE_NAME = 'response_x';

   global void doInvoke(
      Object stub, 
      Object soap_request, 
      Map<String, Object> response, 
      String endpoint,
      String soap_action,
      String request_name, 
      String response_namespace, 
      String response_name,
      String response_type
   ){
      BillingServiceProxy.billProjectResponse_element response_x = 
            new BillingServiceProxy.billProjectResponse_element();
            
      response_x.status = RESPONSE_STATUS;
      response.put(RESPONSE_NAME, response_x);
   }   
}