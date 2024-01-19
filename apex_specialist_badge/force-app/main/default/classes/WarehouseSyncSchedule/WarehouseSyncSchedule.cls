public with sharing class WarehouseSyncSchedule implements Schedulable
{
    public void execute(SchedulableContext sc)
    {
        try
        {
            WarehouseCalloutService calloutService = new WarehouseCalloutService();
            System.enqueueJob(calloutService);
        }
        catch (Exception e)
        {
            System.debug('Callout Service Exception : ' + e.getMessage());
        }
    }
}