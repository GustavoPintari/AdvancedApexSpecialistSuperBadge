@isTest
public with sharing class CredentialVerificationServiceTest {

    @isTest
    public static void testValidCredential() {
        Contact contact = new Contact(LastName = 'Test');
        Database.insert(contact);

        Contact_Certification__c contactCertification = createContactCertification(contact, Date.today());

        Test.startTest();

        String result = CredentialVerificationService.verifyCredential(contact.LastName, contactCertification.Name);

        Test.stopTest();

        Assert.areEqual('Valid', result, 'Expected result to be "Valid"');
    }

    @isTest
    public static void testInactiveCertification() {
        Contact contact = new Contact(LastName = 'Test');
        Database.insert(contact);

        Contact_Certification__c contactCertification = createContactCertification(contact, Date.today().addYears(-2));
        contactCertification.isActive__c = false;
        Database.update(contactCertification);

        Test.startTest();

        String result = CredentialVerificationService.verifyCredential(contact.LastName, contactCertification.Name);

        Test.stopTest();

        Assert.areEqual('Needs Renewal', result, 'Expected result to be "Needs Renewal"');
    }

    @isTest
    public static void testWithNullContactAndNullCertification() {
        Test.startTest();

        String result = CredentialVerificationService.verifyCredential('NonExistentLastName', 'Some Certification');

        Test.stopTest();

        String expectedMessage = CredentialVerificationService.NO_RECORD_FOUND;

        Assert.areEqual(expectedMessage, result, 'Expected result to be "No record found"');
    }

    @isTest
    public static void testWithNullCertification() {
        Contact contact = new Contact(LastName = 'Test');
        Database.insert(contact);

        Test.startTest();

        String result = CredentialVerificationService.verifyCredential(contact.LastName, 'NonExistentCertification');

        Test.stopTest();

        String expectedMessage = CredentialVerificationService.NO_RECORD_FOUND;

        Assert.areEqual(expectedMessage, result, 'Expected result to be "No record found"');
    }

    private static Contact_Certification__c createContactCertification(Contact contact, Date issueDate) {
		Certification__c certification = new Certification__c(Name = 'SalesforceCertification');
        Database.insert(certification);

        Contact_Certification__c contactCertification = new Contact_Certification__c(
            isActive__c = true,
            Contact__c = contact.Id,
            Issue_Date__c = Date.today(),
            Certification__c = certification.Id
        );
        Database.insert(contactCertification);

        return [SELECT Name FROM Contact_Certification__c WHERE Contact__c = :contact.Id LIMIT 1];
    }
}