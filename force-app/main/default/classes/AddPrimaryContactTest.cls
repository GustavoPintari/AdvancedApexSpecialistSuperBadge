@isTest
public with sharing class AddPrimaryContactTest {

    @isTest
    public static void testAddPrimaryContact() {
        List<Account> lAccounts = new List<Account>();

        for (Integer i = 0; i < 50; i++) {
            lAccounts.add((Account) new AccountBuilder().genericAccount().setBillingState('NY').build());
            lAccounts.add((Account) new AccountBuilder().genericAccount().setBillingState('CA').build());
        }
        Database.insert(lAccounts);

        Contact contact = new Contact(LastName = 'Test Contact');
        Database.insert(contact);

        Test.startTest();
        	
        AddPrimaryContact addPrimaryContact = new AddPrimaryContact(contact, 'CA');
        System.enqueueJob(addPrimaryContact);

        Test.stopTest();

        Set<Id> sAccounts = new Map<Id, Account>(lAccounts).keySet();

        List<Contact> lContacts = [SELECT Id FROM Contact WHERE AccountId IN :sAccounts AND Account.BillingState = 'CA'];

        Assert.areEqual(50, lContacts.size(), 'Apenas as contas do estado CA devem ter contatos gerados');
    }
}