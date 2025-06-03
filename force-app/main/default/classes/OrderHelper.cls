public without sharing class OrderHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void afterUpdate(List<Order> newList, List<Order> oldList) {
        Set<Id> sOrderIds = new Set<Id>();

        final String activatedOrderStatus = Constants.ACTIVATED_ORDER_STATUS;

        for (Integer i = 0; i < newList.size(); i++) {
            if (newList[i].Status == activatedOrderStatus && oldList[i].Status != activatedOrderStatus) {
                sOrderIds.add(newList[i].Id);
            }
        }

        if (sOrderIds.isEmpty()) {
            return;
        }

        rollUpOrderItems(sOrderIds);
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void rollUpOrderItems(Set<Id> activatedOrderIds) {
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        
        for (OrderItem orderItem : [
            SELECT Id, Product2Id, Product2.Quantity_Ordered__c, Quantity FROM OrderItem WHERE OrderId IN :activatedOrderIds
        ]) {
            productMap.put(orderItem.Product2Id, orderItem.Product2);
        }

        for (AggregateResult agr : [
            SELECT Product2Id, SUM(Quantity) Total FROM OrderItem WHERE Product2Id IN :productMap.keySet() GROUP BY Product2Id
        ]) {
            Product2 product2 = productMap.get((Id) agr.get('Product2Id'));
            product2.Quantity_Ordered__c = (Decimal) agr.get('Total');
        }

        Database.update(productMap.values());
    }
}