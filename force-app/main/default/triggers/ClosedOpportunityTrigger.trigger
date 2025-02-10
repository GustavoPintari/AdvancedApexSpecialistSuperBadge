trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {
    new OpportunityTH().createTask();
}