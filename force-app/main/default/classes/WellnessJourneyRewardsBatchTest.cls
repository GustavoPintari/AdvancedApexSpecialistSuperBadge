@isTest
public with sharing class WellnessJourneyRewardsBatchTest {

    @isTest
    public static void testBatchWithRewardsCalloutSuccess() {
        Test.setMock(HttpCalloutMock.class, new RewardsCalloutServiceMock.MockSuccess());

        Id userId = UserInfo.getUserId();

        List<Wellness_Journey__c> lJourneys = new List<Wellness_Journey__c>();

        System.runAs(new User(Id = userId)) {
            for (Integer i = 0; i < 12; i++) {
                lJourneys.add(new Wellness_Journey__c(
                    Name = 'Journey ' + i,
                    OwnerId = userId,
                    Status__c = 'Complete',
                    Completion_Date__c = WellnessJourneyRewardsBatch.getStartDate()
                ));
            }

            Database.insert(lJourneys);

            Test.startTest();

            Database.executeBatch(new WellnessJourneyRewardsBatch(), 20);

            Test.stopTest();
        }

        lJourneys = [SELECT Id FROM Wellness_Journey__c WHERE OwnerId = :userId];
        Assert.areEqual(12, lJourneys.size(), 'The number of Wellness Journeys created should be equal to 12.');
    }

    @isTest
    public static void testBatchWithRewardsCalloutException() {
        Test.setMock(HttpCalloutMock.class, new RewardsCalloutServiceMock.MockFailure());

        Id userId = UserInfo.getUserId();
        List<Wellness_Journey__c> lJourneys = new List<Wellness_Journey__c>();

        System.runAs(new User(Id = userId)) {
            for (Integer i = 0; i < 12; i++) {
                lJourneys.add(new Wellness_Journey__c(
                    Name = 'Journey ' + i,
                    OwnerId = userId,
                    Status__c = 'Complete',
                    Completion_Date__c = WellnessJourneyRewardsBatch.getStartDate()
                ));
            }
            Database.insert(lJourneys);

            Test.startTest();

            Database.executeBatch(new WellnessJourneyRewardsBatch(), 20);

            Test.stopTest();
        }

        lJourneys = [SELECT Id FROM Wellness_Journey__c WHERE OwnerId = :userId];
        Assert.areEqual(12, lJourneys.size(), 'The number of Wellness Journeys created should be equal to 12.');
    }
}