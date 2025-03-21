public with sharing class LeadProcessor implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name, LeadSource FROM Lead]);
    }

    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        for (Lead lead : scope) {
            lead.LeadSource = 'Dreamforce';
        }
        
        Database.update(scope);
    }

    public void finish(Database.BatchableContext bc) {
    }
}