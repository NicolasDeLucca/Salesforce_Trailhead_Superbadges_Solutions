public with sharing class WarehouseCalloutService implements Queueable
{
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    public void execute(QueueableContext context)
    {
        externalSystemCallout();
    }
    
    private void externalSystemCallout()
    {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200)
        {
            String incomingData = response.getBody();
            synchronizeData(incomingData);
        }
    }

    // receives updated equipment values and updates the related records
    private void synchronizeData(String externalJsonData)
    {
        List<wh_Equipment> incomingEquipments = getExternalEquipments(externalJsonData);
        processEquipments(incomingEquipments);
    }

    private List<wh_Equipment> getExternalEquipments(String externalEquipments)
    {
        List<wh_Equipment> parsedEquipments = new List<wh_Equipment>();
        List<Object> externalEquipmentsList = (List<Object>) JSON.deserializeUntyped(externalEquipments);

        if (externalEquipmentsList != null)
        {
            for (Object externalEquipment : externalEquipmentsList)
            {
                Map<String, Object> externalEquipmentMap = (Map<String, Object>) externalEquipment;
                wh_Equipment parsedEquipment = new wh_Equipment();

                parsedEquipment.Id = (String) externalEquipmentMap.get('_id');
                parsedEquipment.Quantity = (Integer) externalEquipmentMap.get('quantity');
                parsedEquipment.Name = (String) externalEquipmentMap.get('name');
                parsedEquipment.MaintenancePeriod = (Integer) externalEquipmentMap.get('maintenanceperiod');
                parsedEquipment.LifeSpan = (Integer) externalEquipmentMap.get('lifespan');
                parsedEquipment.Cost = (Integer) externalEquipmentMap.get('cost');
                parsedEquipment.Sku = (Integer) externalEquipmentMap.get('sku');

                parsedEquipments.add(parsedEquipment);
            }
        }

        return parsedEquipments;
    }

    private void processEquipments(List<wh_Equipment> incomingEquipments)
    {
        List<Product2> updatedEquipments = new List<Product2>();
        List<Product2> existingEquipments = 
        [
            SELECT Id, Name, Replacement_Part__c, QuantityUnitOfMeasure, Maintenance_Cycle__c, Lifespan_Months__c, Cost__c, Warehouse_SKU__c
            FROM Product2
        ];
        Map <Id, Product2> existingEquipmentsMap = new Map<Id, Product2>(existingEquipments);

        for (wh_Equipment incomingEquipment : incomingEquipments)
        {
            Product2 existingEquipment = existingEquipmentsMap.get(incomingEquipment.Id);
            if (existingEquipment != null)
            {
                existingEquipment.Name = incomingEquipment.Name;
                existingEquipment.Replacement_Part__c = true;
                existingEquipment.QuantityUnitOfMeasure = String.valueOf(incomingEquipment.Quantity);
                existingEquipment.Maintenance_Cycle__c = incomingEquipment.MaintenancePeriod;
                existingEquipment.Lifespan_Months__c = incomingEquipment.LifeSpan;
                existingEquipment.Cost__c = incomingEquipment.Cost;
                existingEquipment.Warehouse_SKU__c = String.valueOf(incomingEquipment.Sku);

                updatedEquipments.add(existingEquipment);
            }
        }

        if (!updatedEquipments.isEmpty())
        {
            update updatedEquipments;
        }
    }
}