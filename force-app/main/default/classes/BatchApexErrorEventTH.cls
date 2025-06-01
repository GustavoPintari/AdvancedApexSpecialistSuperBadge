public with sharing class BatchApexErrorEventTH extends TriggerHandler {

    private List<BatchApexErrorEvent> lNewData;
    private Map<Id, BatchApexErrorEvent> mOldData;

    public BatchApexErrorEventTH() {
        this.lNewData = (List<BatchApexErrorEvent>) Trigger.new;
        this.mOldData = (Map<Id, BatchApexErrorEvent>) Trigger.oldMap;
    }

    override
    public void afterInsert() {
        this.insertErrorLogs();
    }

    private void insertErrorLogs() {
        List<Error_Log__c> lErrorLogs = new List<Error_Log__c>();
        
        for (BatchApexErrorEvent event : this.lNewData) {
            lErrorLogs.add(new Error_Log__c(Name = 'Batch Error', Message__c = event.Message, Async_Apex_Job_Id__c = event.AsyncApexJobId));
        }
        
        Database.insert(lErrorLogs);
    }
}