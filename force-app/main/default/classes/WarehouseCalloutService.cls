public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {

    public List<Product2> lEquipmentsToUpsert = new List<Product2>();

    private static final String WAREHOUSE_URL;
    private static final Map<String, String> WAREHOUSE_TO_SALESFORCE_FIELD_MAPPING;

    public void execute(QueueableContext context) {
        Database.upsert(this.lEquipmentsToUpsert, Product2.Warehouse_SKU__c);
    }

    public void upsertEquipmentsWithWareHouseData() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = new Http().send(request);

        if (response.getStatusCode() != 200) {
            return;
        }

        for (Object result : (List<Object>) JSON.deserializeUntyped(response.getBody())) {
            Product2 equipment = new Product2();
            Map<String, Object> mResult = (Map<String, Object>) result;

            for (String field : mResult.keySet()) {
                if (!WAREHOUSE_TO_SALESFORCE_FIELD_MAPPING.containsKey(field)) {
                    continue;
                }
                equipment.put(WAREHOUSE_TO_SALESFORCE_FIELD_MAPPING.get(field), mResult.get(field));
            }

            this.lEquipmentsToUpsert.add(equipment);
        }

        System.enqueueJob(this);
    }

    static {
        WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

        WAREHOUSE_TO_SALESFORCE_FIELD_MAPPING = new Map<String, String>{
            'name' => 'Name',
            'cost' => 'Cost__c',
            'sku' => 'ProductCode',
            '_id' => 'Warehouse_SKU__c',
            'lifespan' => 'Lifespan_Months__c',
            'replacement' => 'Replacement_Part__c',
            'maintenanceperiod' => 'Maintenance_Cycle__c'
        };
    }
}