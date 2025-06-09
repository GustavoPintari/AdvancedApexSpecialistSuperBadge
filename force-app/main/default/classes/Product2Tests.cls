@isTest
public with sharing class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @isTest
    private static void product2Extension_UnitTest() {
        Test.setCurrentPage(Page.product2New);

        Test.startTest();

        Product2Extension product2Extension = new Product2Extension(new ApexPages.StandardController(new Product2()));
        product2Extension.addRows();

        Assert.areEqual(product2Extension.productsToInsert.size(), Constants.DEFAULT_ROWS * 2, 'The number of products to be inserted must match the one stored in the Constants class.');

        String family = Product2Extension.getFamilyOptions()[1].getValue();

        for (Product2Extension.ProductWrapper wrapper : product2Extension.productsToInsert) {
            Product2 product = new Product2(
                Name = 'Test Product',
                IsActive = true,
                Family = family,
                Initial_Inventory__c = 20
            );

            PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), IsActive = true, UnitPrice = 10);

            wrapper.productRecord = product;
            wrapper.pricebookEntryRecord = pricebookEntry;
        }

        product2Extension.save();

        Test.stopTest();

        List<Product2> lProduct2 = [SELECT Id FROM Product2];

        Assert.areEqual(Constants.DEFAULT_ROWS * 2, lProduct2.size(), 'The number inserted products must match the one stored in the Constants class.');
    }

    @isTest
    private static void product2Trigger_UnitTest() {
        Product2 product = new Product2();
        product.Name = 'Test';
        product.Family = 'Dessert';
        product.IsActive = true;
        product.Quantity_Ordered__c = 5;
        product.Initial_Inventory__c = 10;
        Database.insert(product);
        
        CollaborationGroup collabGroup = new CollaborationGroup();
        collabGroup.Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS;
        collabGroup.Description = 'Test';
        collabGroup.CollaborationType = 'Public';
        Database.insert(collabGroup);
        
        Test.startTest();

        product.Quantity_Ordered__c = 80;
        Database.SaveResult result = Database.update(product, false);

        Test.stopTest();

        Assert.isTrue(result.isSuccess(), 'The product must be updated without errors.');
    } 
}