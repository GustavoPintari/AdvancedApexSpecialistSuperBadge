@isTest
public with sharing class WarehouseSyncScheduleTest {
    
    @isTest
    public static void testWarehouseSyncSchedule() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        Product2 equipmentA = new Product2(Name = 'Test Equipment A', Warehouse_SKU__c = '001');
        Database.insert(equipmentA);

        Test.startTest();

        WarehouseSyncSchedule warehouseSchedule = new WarehouseSyncSchedule();
        warehouseSchedule.jobName = 'WarehouseSyncScheduleJobTest';
        warehouseSchedule.schedule();
        warehouseSchedule.execute(null);

        Test.stopTest();

        List<Product2> lProduct2 = [SELECT Id, Name, Warehouse_SKU__c FROM Product2 ORDER BY Warehouse_SKU__c ASC];

        Assert.areEqual(2, lProduct2.size(), 'Todos os equipamentos contidos no mock devem ser inseridos ou atualizados.');
    }
}