@isTest
public with sharing class AccountProcessorTest {

    @isTest
    public static void testNumberOfContactsField() {
        Account accountA = new Account(Name = 'Test Account A');
        Account accountB = new Account(Name = 'Test Account B');
        Database.insert(new List<Account>{accountA, accountB});

        Contact contactA = new Contact(AccountId = accountA.Id, LastName = 'Test Contact A');
        Contact contactB = new Contact(AccountId = accountA.Id, LastName = 'Test Contact B');
        Database.insert(new List<Contact>{contactA, contactB});

        Test.startTest();

        List<Id> lAccountIds = new List<Id>{accountA.Id, accountB.Id};

        AccountProcessor.countContacts(lAccountIds);

        Test.stopTest();

        List<Account> lAccounts = [SELECT Id, Number_Of_Contacts__c FROM Account WHERE Id IN :lAccountIds ORDER BY Name DESC];

        Assert.areEqual(2, lAccounts[1].Number_Of_Contacts__c, 'O valor do campo deve corresponder ao total de contatos adicionados na conta A (2).');
        Assert.areEqual(0, lAccounts[0].Number_Of_Contacts__c, 'O valor do campo deve corresponder ao total de contatos adicionados na conta B (0).');
    }
}