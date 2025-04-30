global with sharing class CredentialVerificationService {

    public static final String NO_RECORD_FOUND = 'No record found';

    webservice static String verifyCredential(String lastName, String certificationName) {

        Contact contact = [SELECT Id FROM Contact WHERE LastName = :lastName LIMIT 1] ?? null;

        if (contact == null) {
            return NO_RECORD_FOUND;
        }

        Contact_Certification__c certification = [
            SELECT Id, isActive__c FROM Contact_Certification__c WHERE Name = :certificationName AND Contact__c = :contact.Id LIMIT 1
        ] ?? null;

        if (certification == null) {
            return NO_RECORD_FOUND;
        }

        String response = 'Needs Renewal';

        if (certification.isActive__c) {
            response = 'Valid';
        }

        return response;
    }
}