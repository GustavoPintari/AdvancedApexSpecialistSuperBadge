@isTest
public with sharing class OrderTests {

    @isTest
    public static void testOrderHelper() {
        Product2 product2 = new Product2(Name = 'Test Product', Family = 'Entree', Initial_Inventory__c = 20.0);
        Database.insert(product2);

        Pricebook2 pricebook2 = new Pricebook2(Id = Test.getStandardPricebookId());
        pricebook2.IsActive = true;
        Database.update(pricebook2);

        PricebookEntry pricebookEntry = new PricebookEntry(Product2Id = product2.Id, Pricebook2Id = pricebook2.Id, UnitPrice = 20.0, IsActive = true);
        Database.insert(pricebookEntry);

        Account account = new Account(Name = 'Test Account');
        Database.insert(account);

        Order order = new Order(AccountId = account.Id, Status = 'Draft', EffectiveDate = Date.today(), Pricebook2Id = pricebook2.Id);
        Database.insert(order);

        OrderItem orderItem = new OrderItem(OrderId = order.Id, Quantity = 20.0, PricebookEntryId = pricebookEntry.Id, UnitPrice = pricebookEntry.UnitPrice);
        Database.insert(orderItem);

        Test.startTest();

        order.Status = Constants.ACTIVATED_ORDER_STATUS;
        Database.update(order);

        Test.stopTest();

        product2 = [SELECT Id, Quantity_Ordered__c FROM Product2 WHERE Id = :product2.Id];

        Assert.areEqual(orderItem.Quantity, product2.Quantity_Ordered__c, 'The value must match the quantity of the order item.');
    }
}