public with sharing class AccountProcessor {

    @future
    public static void countContacts(List<Id> lAccountIds) {

        List<Account> lAccountsToUpdate = new List<Account>();

        for (Account account : [SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :lAccountIds]) {
            if (account.Contacts.isEmpty()) {
                continue;
            }

            account.Number_Of_Contacts__c = account.Contacts.size();
            lAccountsToUpdate.add(account);
        }

        Database.update(lAccountsToUpdate);
    }
}