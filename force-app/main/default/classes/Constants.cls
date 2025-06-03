public with sharing class Constants {

    public static final Integer DEFAULT_ROWS = 5;
    public static final String SELECT_ONE = Label.Select_One;
    public static final String INVENTORY_LEVEL_LOW = Label.Inventory_Level_Low;
    public static final String DRAFT_ORDER_STATUS = 'Draft';
    public static final String ACTIVATED_ORDER_STATUS = 'Activated';
    public static final String INVENTORY_ANNOUNCEMENTS = 'Inventory Announcements';
    public static final String ERROR_MESSAGE = 'An error has occurred, please take a screenshot with the URL and send it to IT.';
    public static final Id STANDARD_PRICEBOOK_ID;
    public static final List<Schema.PicklistEntry> PRODUCT_FAMILY;

    static {
        if (String.isBlank(STANDARD_PRICEBOOK_ID)) {
            STANDARD_PRICEBOOK_ID = [SELECT Id FROM Pricebook2 WHERE IsStandard = true].Id;
        }

        if (PRODUCT_FAMILY == null) {
            PRODUCT_FAMILY = new List<Schema.PicklistEntry>();

            Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();

            for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()){
                PRODUCT_FAMILY.add(entry);
            }
        }
    }
}