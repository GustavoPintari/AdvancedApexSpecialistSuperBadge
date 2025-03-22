public with sharing class ParkLocator {

    public static List<String> country(String countryName) {
        ParkService.ParksImplPort parkService = new ParkService.ParksImplPort();
        return (List<String>) parkService.ByCountry(countryName);
    }
}