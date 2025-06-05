public class Product2Extension {

    public List<ProductWrapper> productsToInsert { get; set; }

    public Product2Extension(ApexPages.StandardController controller) {
        this.productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void addRows() {
        for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++) {
            this.productsToInsert.add(new ProductWrapper());
        }
    }

    public List<SelectOption> getFamilyOptions() {
        List<SelectOption> lOptions = new List<SelectOption>();

        lOptions.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));

        for (Schema.PicklistEntry picklistEntry : Constants.PRODUCT_FAMILY) {
            lOptions.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }

        return lOptions;
    }

    public List<ChartHelper.ChartData> getInventory() {
        return ChartHelper.getInventory();
    }

    public PageReference save() {
        SavePoint savePoint = Database.setSavepoint();

        List<Product2> lProducts = new List<Product2>();
        List<PricebookEntry> lPricebookEntries = new List<PricebookEntry>();

        final Id pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;

        try {
            for (ProductWrapper productWrapper : this.productsToInsert) {
                if (!validateProduct(productWrapper)) {
                    continue;
                }

                lProducts.add(productWrapper.productRecord);
                lPricebookEntries.add(productWrapper.pricebookEntryRecord);
            }

            List<Database.SaveResult> lSaveResult = Database.insert(lProducts, false);

            Integer insertedProducts = 0;
            for (Integer i = 0; i < lSaveResult.size(); i++) {
                if (!lSaveResult[i].isSuccess()) {
                    lPricebookEntries.remove(i);
                    continue;
                }

                PricebookEntry pricebookEntry = lPricebookEntries[i];
                pricebookEntry.IsActive = true;
                pricebookEntry.Pricebook2Id = pricebook2Id;
                pricebookEntry.Product2Id = lSaveResult[i].getId();

                insertedProducts++;
            }

            Database.insert(lPricebookEntries);

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, insertedProducts + ' Inserted'));
            this.productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e) {
            Database.rollback(savepoint);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }

        return null;
    }

    private Boolean validateProduct(ProductWrapper productWrapper) {
        String name = productWrapper.productRecord.Name;
        String family = productWrapper.productRecord.Family;
        Boolean isActive = productWrapper.productRecord.IsActive;
        Decimal unitPrice = productWrapper.pricebookEntryRecord.UnitPrice;
        Decimal initialInventory = productWrapper.productRecord.Initial_Inventory__c;

        if (String.isBlank(name) || String.isBlank(family) || family == Constants.SELECT_ONE || unitPrice == null || unitPrice == 0 || initialInventory == null || initialInventory == 0 || !isActive) {
            return false;
        }

        return true;
    }

    public class ProductWrapper {
        public Product2 productRecord { get; set; }
        public PriceBookEntry pricebookEntryRecord { get; set; }

        public ProductWrapper() {
            productRecord = new Product2(Initial_Inventory__c = 0);
            pricebookEntryRecord = new PriceBookEntry(UnitPrice = 0);
        }
    }
}