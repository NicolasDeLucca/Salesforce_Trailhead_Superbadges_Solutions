@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
       System.assertEquals('https://th-superbadge-apex.herokuapp.com/equipment', req.getEndpoint());
       System.assertEquals('GET', req.getMethod());

       // fake response
       HttpResponse res = new HttpResponse();
       res.setHeader('Content-Type', 'application/json');
       res.setBody(
        '[' +
         '{' + 
            '"_id": "55d66226726b611100aaf73d",' + 
            '"replacement": false,' +
            '"quantity": 10,' +
            '"name": "Cooling F20",' +
            '"maintenanceperiod": 180,' +
            '"lifespan": 0,' +
            '"cost": 20000,' +
            '"sku": 100023,' +
         '}' + 
        ']'
       );
       res.setStatusCode(200);

       return res;
    }
}