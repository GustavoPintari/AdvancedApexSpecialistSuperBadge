global class PilotRatingBatch implements Database.Batchable<SObject>, Database.RaisesPlatformEvents {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Completion_Rating__c, Overall_Rating__c, Safety_Incidents__c, Pilot__c FROM Mission__c WHERE Status__c = \'Complete\'');
    }

    global void execute(Database.BatchableContext bc, List<Mission__c> scope) {
        try {
            List<Contact> lContacts = new List<Contact>();
            for (Mission__c mission : scope) {            
                if (String.isBlank(mission.Pilot__c)) {
                    continue;
                }

                Double newOverallRating = mission.Pilot__r.Pilot_Rating__c + mission.Overall_Rating__c;
                mission.Pilot__r.Pilot_Rating__c = newOverallRating;
                    
                lContacts.add(mission.Pilot__r);
            }
        
            Database.update(lContacts);
         } catch (Exception ex) {
            EventBus.publish(new BatchApexErrorEvent(
                Message = ex.getMessage(),
                AsyncApexJobId = bc.getJobId()
            ));
        }
    }

    global void finish(Database.BatchableContext bc) {}
}