public with sharing class MaintenanceRequestHelper
{
    public static Case Create(Case c)
    {
        Case newRequest = new Case();
        newRequest.Type = 'Routine Maintenance';
        newRequest.Status = 'New';
        //asa
            
        return newRequest;
    }        
}