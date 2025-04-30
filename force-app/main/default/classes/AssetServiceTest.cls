@isTest
public with sharing class AssetServiceTest {

    @isTest 
    public static void testNotFoundAsset() {
        Test.startTest();

        String result = AssetService.reportLostDevice('NonExistentAsset');

        Test.stopTest();

        String expectedMessage = AssetService.DEVICE_NOT_FOUND;

        Assert.areEqual(expectedMessage, result, 'Expected error message for non-existent asset');
    }

    @isTest 
    public static void testNoInsuranceCoverage() {
        Asset asset = createAsset();

        Test.startTest();

        String result = AssetService.reportLostDevice(asset.Asset_Identifier__c);
        String expectedMessage = AssetService.NO_COVERAGE_LOST_STATUS;

        Test.stopTest();

        Assert.areEqual(expectedMessage, result, 'Expected message for no insurance coverage');
    }

    @isTest 
    public static void claimAlreadyFiled() {
        Asset asset = createAsset();

        Insurance__c insurance = new Insurance__c(Asset__c = asset.Id, Coverage__c = 'Comprehensive', Active__c = true);
        Database.insert(insurance);

        Test.startTest();

        String result = AssetService.reportLostDevice(asset.Asset_Identifier__c);

        Test.stopTest();

		Claim__c claim = [SELECT Id,Name FROM Claim__c WHERE Insurance__c = :insurance.Id AND Type__c = 'Loss' LIMIT 1] ?? null;

        Assert.isNotNull(claim, 'A claim record should have been created');
        Assert.areEqual(claim.Name, result, 'Expected message for already filed claim');

    }

    private static Asset createAsset() {
        Account account = new Account(Name = 'Test Account');
        Database.insert(account);

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = account.Id);
        Database.insert(contact);

        Asset asset = new Asset(Name = 'Test Asset', AccountId = account.Id, ContactId = contact.Id, Asset_Identifier__c = 'Asset002', Status = 'Available');
        Database.insert(asset);

        return asset;
    }
}