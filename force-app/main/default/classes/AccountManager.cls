@RestResource(urlMapping='/Accounts/*')
global with sharing class AccountManager {
    
    @HttpGet
    global static Account getAccount() {
        RestRequest request = RestContext.request;
        Id accountId = getAccountIdFromUrl(request.requestURI);

        return [SELECT Id, Name, (SELECT Id, Name FROM Contacts) FROM Account WHERE Id = :accountId] ?? null;
    }

    private static String getAccountIdFromUrl(String requestURI) {
        List<String> parts = requestURI.split('/');

        Integer accountIndex = parts.indexOf('Accounts') + 1;

        return parts[accountIndex];
    }
}