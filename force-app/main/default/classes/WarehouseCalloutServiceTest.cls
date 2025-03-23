@isTest
public with sharing class WarehouseCalloutServiceTest {

    @isTest
    public static void testWareHouseCallout() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        Product2 equipmentA = new Product2(Name = 'Test Equipment A', Warehouse_SKU__c = '001');
        Database.insert(equipmentA);

        Test.startTest();

        new WarehouseCalloutService().upsertEquipmentsWithWareHouseData();

        Test.stopTest();

        List<Product2> lProduct2 = [SELECT Id, Name, Warehouse_SKU__c FROM Product2 ORDER BY Warehouse_SKU__c ASC];

        Assert.areEqual(2, lProduct2.size(), 'Todos os equipamentos contidos no mock devem ser inseridos ou atualizados.');

        Assert.areEqual('Generator 1000 kW', lProduct2[0].Name, 'O nome do equipamento com SKU 001 deve ter sido atualizado.');
        Assert.areEqual(equipmentA.Warehouse_SKU__c, lProduct2[0].Warehouse_SKU__c, 'O valor de SKU para o equipamento já existente deve ser mantido.');

        Assert.areEqual('Cooling Fan', lProduct2[1].Name, 'O equipamento novo deve corresponder ao que foi configurado no mock.');
        Assert.areEqual('002', lProduct2[1].Warehouse_SKU__c, 'o código do equipamento inserido deve corresponder com o SKU configurado no mock.');
    }

    @isTest
    public static void testWareHouseCalloutWithErrorOnMock() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock(500));

        Test.startTest();

        new WarehouseCalloutService().upsertEquipmentsWithWareHouseData();

        Test.stopTest();

        List<Product2> lProduct2 = [SELECT Id, Name, Warehouse_SKU__c FROM Product2 ORDER BY Warehouse_SKU__c ASC];

        Assert.areEqual(0, lProduct2.size(), 'Erro 500, nenhum produto atualizado.');
    }
}