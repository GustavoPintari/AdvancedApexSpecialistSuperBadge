@isTest
public with sharing class AccountManagerTest {
    
    @isTest
    public static void testGetAccount() {

        Account account = (Account) new AccountBuilder().genericAccount().build();
        Database.insert(account);

        Contact contact = new Contact(LastName = 'Test Contact', AccountId = account.Id);
        Database.insert(contact);

        Test.startTest();

        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        request.requestUri = URL.getOrgDomainUrl() + '/services/apexrest/Accounts/' + account.Id + '/contacts';
        RestContext.request = request;

        Account returnedAccount = AccountManager.getAccount();

        Test.stopTest();

        Assert.areEqual(account.Name, returnedAccount.Name, 'Os nomes das duas contas devem ser iguais.');
    }
}