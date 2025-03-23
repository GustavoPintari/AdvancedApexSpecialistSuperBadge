@isTest
public with sharing class MaintenanceRequestHelperTest {
    
    @isTest
    public static void testRoutineMaintenceCase() {
        Vehicle__c vehicleA = new Vehicle__c(Name = 'Test Vehicle A');
        Vehicle__c vehicleB = new Vehicle__c(Name = 'Test Vehicle B');
        Database.insert(new List<Vehicle__c>{vehicleA, vehicleB});

        Case parentCaseA = new Case(Status = 'Working', Type = 'Repair', Vehicle__c = vehicleA.Id);
        Case parentCaseB = new Case(Status = 'Working', Type = 'Repair', Vehicle__c = vehicleB.Id);
        Database.insert(new List<Case>{parentCaseA, parentCaseB});

        Product2 equipmentA = new Product2(Name = 'Test Equipment A', Replacement_Part__c = true, Maintenance_Cycle__c = 100.0); 
        Product2 equipmentB = new Product2(Name = 'Test Equipment B', Replacement_Part__c = true, Maintenance_Cycle__c = 20.0); 
        Product2 equipmentC = new Product2(Name = 'Test Equipment C', Replacement_Part__c = true, Maintenance_Cycle__c = 30.0); 
        Database.insert(new List<Product2>{equipmentA, equipmentB, equipmentC});

        Database.insert(new List<Equipment_Maintenance_Item__c>{
            new Equipment_Maintenance_Item__c(Equipment__c = equipmentA.Id, Maintenance_Request__c = parentCaseA.Id),
            new Equipment_Maintenance_Item__c(Equipment__c = equipmentB.Id, Maintenance_Request__c = parentCaseA.Id),
            new Equipment_Maintenance_Item__c(Equipment__c = equipmentC.Id, Maintenance_Request__c = parentCaseA.Id)
        });

        Test.startTest();

        parentCaseA.Status = 'Closed';
        parentCaseB.Status = 'Closed';
        Database.update(new List<Case>{parentCaseA, parentCaseB});

        Test.stopTest();

        Case childCase = [SELECT Id, Date_Due__c, (SELECT Id FROM Equipment_Maintenance_Items__r) FROM Case WHERE Vehicle__c = :vehicleA.Id AND Type = 'Routine Maintenance' LIMIT 1] ?? null;

        Assert.isNotNull(childCase, 'Com o caso pai sendo fechado, um caso filho do tipo Routine Maintenance deve ser gerado.');
        Assert.areEqual(Date.today().addDays(20), childCase.Date_Due__c, 'A data de fechamento deve corresponder ao menor valor de ciclo de manutenção entre os itens.');
        Assert.areEqual(3, childCase.Equipment_Maintenance_Items__r.size(), 'O caso filho deve estar relacionado a mesma quantidade de itens que o caso pai.');
    }

    @isTest
    public static void testRoutineMaintenceCaseWithoutClosedCases() {
        Vehicle__c vehicleA = new Vehicle__c(Name = 'Test Vehicle');
        Vehicle__c vehicleB = new Vehicle__c(Name = 'Test Vehicle');
        Database.insert(new List<Vehicle__c>{vehicleA, vehicleB});

        Case parentCaseA = new Case(Status = 'Working', Type = 'Repair', Vehicle__c = vehicleA.Id);
        Case parentCaseB = new Case(Status = 'Working', Type = 'Repair', Vehicle__c = vehicleB.Id);
        Database.insert(new List<Case>{parentCaseA, parentCaseB});

        Test.startTest();

        Database.update(new List<Case>{parentCaseA, parentCaseB});

        Test.stopTest();

        List<Case> lChildCases = [SELECT Id FROM Case WHERE ParentId != null];

        Assert.isTrue(lChildCases.isEmpty(), 'Nenhum caso filho foi criado pois nenhum dos dois casos atualizados foi fechado.');
    }
}