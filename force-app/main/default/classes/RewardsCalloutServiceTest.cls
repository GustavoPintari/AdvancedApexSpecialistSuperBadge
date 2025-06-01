@isTest
public with sharing class RewardsCalloutServiceTest {
    
    @isTest
    public static void testSubmitUsersForRewardCalloutSuccess() {
        Test.setMock(HttpCalloutMock.class, new RewardsCalloutServiceMock.MockSuccess());

        String jsonBody = '[{"userId":"005xx0000012345", "fullName":"Test User", "email":"test@example.com", "username":"test.user"}]';

        Test.startTest();

        Integer responseCode = RewardsCalloutService.submitUsersForRewardCallout(jsonBody);

        Test.stopTest();

        Assert.areEqual(200, responseCode, 'Expected HTTP 200 response');
    }

    @isTest
    public static void testSubmitUsersForRewardCalloutFailure() {
        Test.setMock(HttpCalloutMock.class, new RewardsCalloutServiceMock.MockFailure());

        String jsonBody = '[{"userId":"005xx0000012345", "fullName":"Test User", "email":"test@example.com", "username":"test.user"}]';

        Test.startTest();

        Integer responseCode = RewardsCalloutService.submitUsersForRewardCallout(jsonBody);

        Test.stopTest();

        Assert.areEqual(500, responseCode, 'Expected HTTP 500 response due to simulated exception');
    }
}