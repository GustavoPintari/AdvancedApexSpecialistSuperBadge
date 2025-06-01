@isTest
public with sharing class BillingCalloutServiceTest {

    @isTest
    public static void testCallBillingService() {
        Accessibility_Project__c project = new Accessibility_Project__c();
        project.Amount__c = 100.00;
        Database.insert(project);

        Test.startTest();

        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());

        AccessibilityProjectBilling.callBillingService(project.Id, project.Amount__c);

        Test.stopTest();

        project = [SELECT Status__c FROM Accessibility_Project__c WHERE Id = :project.Id];
        Assert.areEqual('Complete', project.Status__c, 'Project status should be Complete');
    }
}