@isTest
@SuppressWarnings('PMD')
public with sharing class ParkServiceMock implements WebServiceMock {
    public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
    ) {
        ParkService.byCountryResponse byCountryResponse = new ParkService.byCountryResponse();
        byCountryResponse.return_x = new List<String>{'Disney'};

        response.put('response_x', byCountryResponse);
   }
}