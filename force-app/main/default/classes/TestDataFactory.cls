/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    public static void verifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered) {
        Assert.areEqual(updatedProduct.Quantity_Ordered__c, originalProduct.Quantity_Ordered__c + qtyOrdered, 'The value must match the quantity of the order item.');
    }

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup constructCollaborationGroup() {
        return new CollaborationGroup(Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS, CollaborationType = 'Public');
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> constructProducts(Integer cnt) {
        List<Product2> lProducts = new List<Product2>();

        List<Schema.PicklistEntry> productFamily = Constants.PRODUCT_FAMILY;

        Integer aux = 0;
        for (Integer i = 0; i < cnt; i++) {
            if (aux >= productFamily.size()) {
                aux = 0;
            }

            lProducts.add(new Product2(Name = 'Test Product ' + i, Family = productFamily[aux].getValue(), Initial_Inventory__c = 10, IsActive = true));

            aux++;
        }

        return lProducts;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> constructPricebookEntries(List<Product2> prods) {
        List<PricebookEntry> lPricebookEntries = new List<PricebookEntry>();

        for (Product2 product2 : prods) {
            lPricebookEntries.add(new PricebookEntry(Product2Id = product2.Id, Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID, UnitPrice = 20.0, IsActive = true));
        }

        return lPricebookEntries;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> constructAccounts(Integer cnt) {
        List<Account> lAccounts = new List<Account>();

        for (Integer i = 0; i < cnt; i++) {
            lAccounts.add(new Account(Name = 'Test Account ' + i));
        }

        return lAccounts;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> constructContacts(Integer cnt, List<Account> accts) {
        List<Contact> lContacts = new List<Contact>();

        if (accts.size() != cnt) {
            return lContacts;
        }

        for (Integer i = 0; i < cnt; i++) {
            lContacts.add(new Contact(AccountId = accts[i].Id, LastName = 'Test Contact ' + i));
        }

        return lContacts;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> constructOrders(Integer cnt, List<Account> accts) {
        List<Order> lOrders = new List<Order>();

        if (accts.size() != cnt) {
            return lOrders;
        }

        Id pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;

        for (Integer i = 0; i < cnt; i++) {
            lOrders.add(new Order(AccountId = accts[i].Id, Status = 'Draft', EffectiveDate = Date.today(), Pricebook2Id = pricebook2Id));
        }

        return lOrders;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> constructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords) {
        List<OrderItem> lOrderItems = new List<OrderItem>();

        if (cnt != pbes.size() || cnt != ords.size()) {
            return lOrderItems;
        }

        for (Integer i = 0; i < cnt; i++) {
            lOrderItems.add(new OrderItem(OrderId = ords[i].Id, Quantity = Constants.DEFAULT_ROWS, PricebookEntryId = pbes[i].Id, UnitPrice = pbes[i].UnitPrice));
        }

        return lOrderItems;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void insertTestData(Integer cnt) {
        CollaborationGroup collabGroup = constructCollaborationGroup();
        Database.insert(collabGroup);

        List<Product2> lProducts = constructProducts(cnt);
        Database.insert(lProducts);

        List<PricebookEntry> lPricebookEntries = constructPricebookEntries(lProducts);
        Database.insert(lPricebookEntries);

        List<Account> lAccounts = constructAccounts(cnt);
        Database.insert(lAccounts);

        List<Contact> lContacts = constructContacts(cnt, lAccounts);
        Database.insert(lContacts);

        List<Order> lOrders = constructOrders(cnt, lAccounts);
        Database.insert(lOrders);

        List<OrderItem> lOrderItems = constructOrderItems(cnt, lPricebookEntries, lOrders);
        Database.insert(lOrderItems);
    }
}