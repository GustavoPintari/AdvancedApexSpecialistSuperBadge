@isTest
public with sharing class WarehouseCalloutServiceMock implements HttpCalloutMock {

    private Integer statusCode;
    private static final List<WarehouseEquipment> EQUIPMENT_LIST;

    public WarehouseCalloutServiceMock() {
        this(200);
    }

    public WarehouseCalloutServiceMock(Integer statusCode) {
        this.statusCode = statusCode;
    }

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();

        response.setHeader('Content-Type', 'application/json');
        response.setBody(JSON.serialize(EQUIPMENT_LIST).replace('id', '_id'));
        response.setStatusCode(this.statusCode);

        return response;
    }

    public class WarehouseEquipment {
        public String id;
        public Boolean replacement;
        public String sku;
        public String name;
        public Double cost;
        public Double lifespan;
        public Double quantity;
        public Double maintenanceperiod;
    }

    static {
        WarehouseEquipment equipmentA = new WarehouseEquipment();
        equipmentA.id = '001';
        equipmentA.sku = '001';
        equipmentA.cost = 5000;
        equipmentA.quantity = 5;
        equipmentA.lifespan = 120;
        equipmentA.replacement = false;
        equipmentA.maintenanceperiod = 365;
        equipmentA.name = 'Generator 1000 kW';

        WarehouseEquipment equipmentB = new WarehouseEquipment();
        equipmentB.id = '002';
        equipmentB.sku = '002';
        equipmentB.cost = 300;
        equipmentB.quantity = 5;
        equipmentB.lifespan = 0;
        equipmentB.replacement = true;
        equipmentB.maintenanceperiod = 0;
        equipmentB.name = 'Cooling Fan';

        EQUIPMENT_LIST = new List<WarehouseEquipment>{equipmentA, equipmentB};
    }
}