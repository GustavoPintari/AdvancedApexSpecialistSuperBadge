@isTest
public with sharing class MaintenanceRequestHelperTest {
    
    @isTest
    public static void testRoutineMaintenceCase() {
        Vehicle__c vehicle = new Vehicle__c(Name = 'Test Vehicle');
        Database.insert(vehicle);

        Case testCase = new Case(Status = 'Closed', Type = 'Repair');
        Case parentCase = new Case(Status = 'Working', Type = 'Repair', Vehicle__c = vehicle.Id);
        Database.insert(new List<Case>{testCase, parentCase});

        Product2 equipmentA = new Product2(Name = 'Test Equipment A', Replacement_Part__c = true, Maintenance_Cycle__c = 100.0); 
        Product2 equipmentB = new Product2(Name = 'Test Equipment B', Replacement_Part__c = true, Maintenance_Cycle__c = 20.0); 
        Product2 equipmentC = new Product2(Name = 'Test Equipment C', Replacement_Part__c = true, Maintenance_Cycle__c = 30.0); 
        Database.insert(new List<Product2>{equipmentA, equipmentB, equipmentC});

        Database.insert(new List<Equipment_Maintenance_Item__c>{
            new Equipment_Maintenance_Item__c(Equipment__c = equipmentA.Id, Maintenance_Request__c = parentCase.Id),
            new Equipment_Maintenance_Item__c(Equipment__c = equipmentB.Id, Maintenance_Request__c = parentCase.Id),
            new Equipment_Maintenance_Item__c(Equipment__c = equipmentC.Id, Maintenance_Request__c = parentCase.Id)
        });

        Test.startTest();

        parentCase.Status = 'Closed';
        Database.update(new List<Case>{testCase, parentCase});

        Test.stopTest();

        Case childCase = [SELECT Id, Date_Due__c, (SELECT Id FROM Equipment_Maintenance_Items__r) FROM Case WHERE Vehicle__c = :vehicle.Id AND Type = 'Routine Maintenance' LIMIT 1] ?? null;

        Assert.isNotNull(childCase, 'Com o caso pai sendo fechado, um caso filho do tipo Routine Maintenance deve ser gerado.');
        Assert.areEqual(Date.today().addDays(20), childCase.Date_Due__c, 'A data de fechamento deve corresponder ao menor valor de ciclo de manutenção entre os itens.');
        Assert.areEqual(3, childCase.Equipment_Maintenance_Items__r.size(), 'O caso filho deve estar relacionado a mesma quantidade de itens que o caso pai.');
    }
}