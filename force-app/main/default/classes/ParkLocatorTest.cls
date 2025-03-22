@isTest
public with sharing class ParkLocatorTest {
    
    @isTest
    public static void byCountryTest() {
        Test.setMock(WebServiceMock.class, new ParkServiceMock());

        String countryName = 'United States';

        List<String> lParks = ParkLocator.country(countryName);

        Assert.areEqual(lParks[0], 'Disney', 'O parque definido no Mock é Disney.');
    }   
}