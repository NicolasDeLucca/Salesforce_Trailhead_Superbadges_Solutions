@isTest
global class ProjectCalloutServiceMockFailure implements HttpCalloutMock
{
   global HTTPResponse respond(HTTPRequest req)
   {
       HttpResponse res = new HttpResponse();
       res.setHeader('Content-Type', 'application/json');
       res.setStatus('Bad Request');
       res.setStatusCode(500);
              
       return res;
   }
}