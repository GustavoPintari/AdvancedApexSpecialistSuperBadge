public with sharing class OpportunityTH {

    private List<Opportunity> lNewData;
    private Map<Id, Opportunity> mOldData;

    public OpportunityTH() {
        this.lNewData = (List<Opportunity>) Trigger.new;
        this.mOldData = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    public void createTask() {
        List<Task> lTasksToInsert = new List<Task>();

        for (Opportunity opportunity : lNewData) {
            if (opportunity.StageName != 'Closed Won') {
                continue;
            }

            Task task = new Task(Subject = 'Follow Up Test Task', WhatId = opportunity.Id);

            lTasksToInsert.add(task);
        }

        Database.insert(lTasksToInsert);
    }
}