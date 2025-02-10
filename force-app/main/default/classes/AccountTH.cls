public with sharing class AccountTH {

    private List<Account> lNewData;
    private Map<Id, Account> mOldData;

    public AccountTH() {
        this.lNewData = (List<Account>) Trigger.new;
        this.mOldData = (Map<Id, Account>) Trigger.oldMap;
    }

    public void copyBillingPostalCodeToShippingPostalCode() {
        for (Account account : lNewData) {
            if (account.Match_Billing_Address__c != true) {
                continue;
            }

            account.ShippingPostalCode = account.BillingPostalCode;
        }
    }
}