public with sharing class OrderEventTH extends TriggerHandler {

    private List<Order_Event__e> lNewData;
    private Map<Id, Order_Event__e> mOldData;

    public OrderEventTH() {
        this.lNewData = (List<Order_Event__e>) Trigger.new;
        this.mOldData = (Map<Id, Order_Event__e>) Trigger.oldMap;
    }

    override
    public void afterInsert() {
        List<Task> lTasksToInsert = new List<Task>();

        for (Order_Event__e orderEvent : this.lNewData) {
            if (!orderEvent.Has_Shipped__c) {
                continue;
            }

            lTasksToInsert.add(new Task(Priority = 'Medium', Subject = 'Follow up on shipped order 105', OwnerId = orderEvent.CreatedById));
        }

        Database.insert(lTasksToInsert);
    }
}