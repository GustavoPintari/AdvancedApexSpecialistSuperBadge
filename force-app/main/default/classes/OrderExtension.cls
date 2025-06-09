/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public with sharing class OrderExtension {

    public Decimal total { get; set; }
    public Order orderRecord { get; set; }
    public String selectedFamily { get; set; }
    public List<OrderItem> orderItemList { get; set; }
    public List<ChartHelper.ChartData> pieData { get; set; }

    public Map<Id, OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardController standardController) {
        this.orderItemMap = new Map<Id, OrderItem>();
        this.pieData = new List<ChartHelper.ChartData>();
        this.orderRecord = (Order) standardController.getRecord();

        if (this.orderRecord.Id != null) {
            this.orderRecord = queryOrderRecord(this.orderRecord.Id);
        }

        resetSsc();
        this.total = 0;

        for (OrderItem orderItem : orderRecord.OrderItems) {
            this.orderItemMap.put(orderItem.Product2Id, orderItem);

            if (orderItem.Quantity == 0 || orderItem.Quantity == null) {
                continue;
            }

            this.total += orderItem.UnitPrice * orderItem.Quantity;
            this.pieData.add(new ChartHelper.ChartData(orderItem.Product2.Name, orderItem.Quantity * orderItem.UnitPrice));
        }

        populateOrderItems();
    }

    private void resetSsc() {
        String query = 'SELECT Name, Product2.Family, Product2.Name, Product2Id, UnitPrice, Product2.Quantity_Remaining__c FROM PricebookEntry WHERE IsActive = true';

        if (String.isNotBlank(selectedFamily) && selectedFamily != Constants.SELECT_ONE) {
            query += ' AND Product2.Family = \'' + selectedFamily + '\'';
        }

        query += ' ORDER BY Name';

        this.standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        this.standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }

    private void populateOrderItems() {
        this.orderItemList = new List<OrderItem>();

        for (SObject record : standardSetController.getRecords()) {
            PricebookEntry pricebookEntry = (PricebookEntry) record;

            if (!this.orderItemMap.containsKey(pricebookEntry.Product2Id)) {
                OrderItem item = new OrderItem(
                    Quantity = 0,
                    Product2 = pricebookEntry.Product2,
                    PricebookEntryId = pricebookEntry.Id,
                    UnitPrice = pricebookEntry.UnitPrice,
                    Product2Id = pricebookEntry.Product2Id
                );

                this.orderItemList.add(item);
            } else {
                this.orderItemList.add(orderItemMap.get(pricebookEntry.Product2Id));
            }
        }
    }

    /**
     * @name OnFieldChange
     * @description
    **/
    public void onFieldChange() {
        for (OrderItem orderItem : this.orderItemList) {
            this.orderItemMap.put(orderItem.Product2Id, orderItem);
        }

        this.pieData = new List<ChartHelper.ChartData>();
        this.total = 0;

        for (OrderItem orderItem : orderItemMap.values()) {
            if (orderItem.Quantity == 0 || orderItem.Quantity == null) {
                continue;
            }

            this.pieData.add(new ChartHelper.ChartData(orderItem.Product2.Name, orderItem.Quantity * orderItem.UnitPrice));
            this.total += orderItem.UnitPrice * orderItem.Quantity;
        }
    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void selectFamily() {
        resetSsc();
        populateOrderItems();
    }

    /**
     * @name Save
     * @description
    **/
    public void save() {
        SavePoint savePoint = Database.setSavepoint();

        try {
            if (String.isBlank(this.orderRecord.Pricebook2Id)) {
                this.orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }

            Database.upsert(this.orderRecord);

            List<OrderItem> lOrderItemsToUpsert = new List<OrderItem>();
            List<OrderItem> lOrderItemsToDelete = new List<OrderItem>();

            for (OrderItem orderItem : this.orderItemList) {
                if (orderItem.Quantity > 0) {
                    if (String.isBlank(orderItem.OrderId)) {
                        orderItem.OrderId = this.orderRecord.Id;
                    }

                    lOrderItemsToUpsert.add(orderItem);
                } else if (String.isNotBlank(orderItem.Id)) {
                    lOrderItemsToDelete.add(orderItem);
                }
            }

            Database.upsert(lOrderItemsToUpsert);
            Database.delete(lOrderItemsToDelete);
        } catch (Exception e) {
            Database.rollback(savePoint);
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, Constants.ERROR_MESSAGE));
        }
    }

    /**
     * @name First
     * @description
    **/
    public void first() {
        this.standardSetController.first();
        populateOrderItems();
    }

    /**
     * @name Next
     * @description
    **/
    public void next() {
        this.standardSetController.next();
        populateOrderItems();
    }


    /**
     * @name Previous
     * @description
    **/
    public void previous() {
        this.standardSetController.previous();
        populateOrderItems();
    }

    /**
     * @name Last
     * @description
    **/
    public void last() {
        this.standardSetController.last();
        populateOrderItems();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean getHasPrevious() {
        return this.standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean getHasNext() {
        return this.standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer getTotalPages() {
        return (Integer) Math.ceil(this.standardSetController.getResultSize() / (Decimal) Constants.DEFAULT_ROWS);
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer getPageNumber() {
        return this.standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> getFamilyOptions() {
        List<SelectOption> lOptions = new List<SelectOption>();

        lOptions.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));

        for (Schema.PicklistEntry picklistEntry : Constants.PRODUCT_FAMILY) {
            lOptions.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }

        return lOptions;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order queryOrderRecord(Id orderId) {
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id, Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }
}