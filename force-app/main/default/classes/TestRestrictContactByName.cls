@isTest
public with sharing class TestRestrictContactByName {

    @isTest
    public static void testContactNameRestriction() {
        Contact contact = new Contact(LastName = 'INVALIDNAME');

        Test.startTest();

        Database.saveResult saveResult = Database.insert(contact, false);

        Test.stopTest();

        Assert.isFalse(saveResult.isSuccess(), 'Um erro deveria ter sido emitido.');
        Assert.isTrue(saveResult.getErrors().size() > 0, 'A quantidade de erros deve ser maior que zero.');
        Assert.areEqual('The Last Name "' + contact.LastName + '" is not allowed for DML', saveResult.getErrors()[0].getMessage(), 'As duas mensagens devem ser iguais.');
    }
}