global class WellnessJourneyRewardsBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date endDate = getEndDate();
        System.debug('endDate ' + endDate);

        Date startDate = getStartDate();
        System.debug('startDate ' + startDate);

        return Database.getQueryLocator('SELECT Id, Name, OwnerId, Owner.Name, Owner.Email, Owner.Username FROM Wellness_Journey__c WHERE Status__c = \'Complete\' AND Completion_Date__c >= :startDate AND Completion_Date__c <= :endDate ORDER BY OwnerId, Completion_Date__c');
    }

    global void execute(Database.BatchableContext bc, List<Wellness_Journey__c> scope) {
        Set<Id> sUserIds = new Set<Id>();
        Map<Id, Integer> mUserGoalCount = new Map<Id, Integer>();
        List<Map<String, Object>> mUsers = new List<Map<String, Object>>();

        for (Wellness_Journey__c journey : scope) {
            mUserGoalCount.put(journey.OwnerId, 0);        
        } 

        for (Wellness_Journey__c journey : scope) {
            Integer goalCount = mUserGoalCount.get(journey.OwnerId);

            goalCount++;

            mUserGoalCount.put(journey.OwnerId,goalCount);

            if (sUserIds.contains(journey.OwnerId) || mUserGoalCount.get(journey.OwnerId) < 12) {
                continue;
            }

            Map<String, Object> mUserInformationByField = new Map<String, Object>();

            sUserIds.add(journey.OwnerId);

            mUserInformationByField.put('userId', journey.OwnerId);
            mUserInformationByField.put('fullName', journey.Owner.Name);
            mUserInformationByField.put('email', journey.Owner.Email);
            mUserInformationByField.put('username', journey.Owner.Username);

            mUsers.add(mUserInformationByField);
        }

        String jsonBody = JSON.serialize(mUsers);
        RewardsCalloutService.submitUsersForRewardCallout(jsonBody);
    }

    global void finish(Database.BatchableContext bc) {}

    public static Date getStartDate() {
        Date today = Date.today();
        Integer currentYear = today.year();
        Integer currentMonth = today.month();
        Integer previousQuarterStartMonth = ((currentMonth - 1) / 3) * 3 + 1 - 3;

        if (previousQuarterStartMonth <= 0) {
            previousQuarterStartMonth += 12;
            currentYear--;
        }

        Date previousQuarterStartDate = Date.newInstance(currentYear, previousQuarterStartMonth, 1);
        return previousQuarterStartDate;
    }

    private static Date getEndDate() {
        Date previousQuarterStartDate = getStartDate();
        Date previousQuarterEndDate = previousQuarterStartDate.addMonths(3).addDays(-1);

        return previousQuarterEndDate;
    }
}