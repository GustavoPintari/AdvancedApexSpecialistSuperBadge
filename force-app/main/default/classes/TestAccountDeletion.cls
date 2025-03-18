@isTest
public with sharing class TestAccountDeletion {

    @isTest
    public static void testDeleteAccountWithOneOpportunity() {
        Account account = TestDataFactory.createAccountsWithlOpportunities(1, 1).get(0);

        Test.startTest();

        Database.DeleteResult result = Database.delete(account, false);

        Test.stopTest();

        Assert.isFalse(result.isSuccess(), 'Um erro deveria ter sido emitido.');
        Assert.isTrue(result.getErrors().size() > 0, 'A quantidade de erros deve ser maior que zero.');
        Assert.areEqual('Cannot delete account with related opportunities.', result.getErrors()[0].getMessage(), 'As duas mensagens devem ser iguais.');
    }
}