@RestResource(urlMapping = '/lost')
global without sharing class AssetService {

    public static final String DEVICE_NOT_FOUND = 'No device found.';
    public static final String NO_COVERAGE_LOST_STATUS = 'No coverage. Asset status adjusted to Lost.';

    @HttpPost
    global static String reportLostDevice(String assetIdentifier) {
        Asset asset = [SELECT Id, Name, Status, ContactId, Asset_Identifier__c FROM Asset WHERE Asset_Identifier__c = :assetIdentifier LIMIT 1] ?? null;

        if (asset == null) {
            return DEVICE_NOT_FOUND;
        }

        asset.Status = 'Lost';
        Database.update(asset);

        Insurance__c insurance = [SELECT Id, Asset__c FROM Insurance__c WHERE Asset__c = :asset.Id AND Coverage__c = 'Comprehensive' AND Active__c = true LIMIT 1] ?? null;

        if (insurance == null) {
            return NO_COVERAGE_LOST_STATUS;
        }

        Claim__c claim = [SELECT Id, Name FROM Claim__c WHERE Insurance__c = :insurance.Id AND Type__c = 'Loss' LIMIT 1] ?? null;

        if (claim != null) {
            return claim.Name + ' already filed.';
        }

        claim = new Claim__c(
            Insurance__c = insurance.Id,
            Contact__c = asset.ContactId,
            Type__c = 'Loss',
            Asset__c = asset.Id,
            Status__c = 'New'
        );
        Database.insert(claim);

        claim = [SELECT Id, Name FROM Claim__c WHERE Insurance__c = :insurance.Id AND Type__c = 'Loss' Order by CreatedDate DESC LIMIT 1];
        return claim.Name;
    }
}