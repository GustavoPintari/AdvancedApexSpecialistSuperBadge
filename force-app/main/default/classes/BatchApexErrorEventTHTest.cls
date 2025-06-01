@isTest
public with sharing class BatchApexErrorEventTHTest implements Database.RaisesPlatformEvents {

    @isTest
    public static void testBatchApexErrorEventTrigger() {
        Contact pilot = new Contact(FirstName = 'Test', LastName = 'Pilot', Pilot_Rating__c = 3.0);
        Database.insert(pilot);

        Mission__c mission = new Mission__c(
            Pilot__c = pilot.Id,
            Completion_Rating__c = 4.0,
            Overall_Rating__c = 5.0,
            Safety_Incidents__c = 1.0,
            Status__c = 'Complete',
            Subject__c = 'Test Mission'
        );
        Database.insert(mission);

        Test.startTest();

        Database.executeBatch(new PilotRatingBatch());

        Test.stopTest();
     
        List<Error_Log__c> lErrorLogs = [SELECT Id, Name, Async_Apex_Job_Id__c, Message__c FROM Error_Log__c];
        Assert.areEqual(1, lErrorLogs.size(), 'A error log should be created.');
    }
}