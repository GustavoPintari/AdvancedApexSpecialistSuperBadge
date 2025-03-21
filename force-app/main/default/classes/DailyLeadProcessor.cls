public with sharing class DailyLeadProcessor implements Schedulable {

    public void execute(SchedulableContext ctx) {
        List<Lead> lLeadsToUpdate = [SELECT Id FROM Lead WHERE LeadSource = null LIMIT 200];
        
        for (Lead lead : lLeadsToUpdate) {
            lead.LeadSource = 'Dreamforce';
        }

        Database.update(lLeadsToUpdate);
    }
}