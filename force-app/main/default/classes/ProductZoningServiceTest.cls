@isTest
public with sharing class ProductZoningServiceTest {

    private static final String REQUEST_URL = '/services/apexrest/ProductZoning/';
    
    @IsTest
    public static void testGetPermissibleFlyZone() {
        Product2 product = createProduct();

        RestRequest request = new RestRequest();

        request.requestURI = REQUEST_URL;
        request.addParameter('ProductCode', product.ProductCode);
        request.httpMethod = 'GET';
        request.headers.put('CountryCode', 'US');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        String response = ProductZoningService.getPermissibleFlyZone();

        Assert.areEqual('Confirm with the local authorities', response, 'Both messages must be the same.');

        request.headers.put('CountryCode', 'DE');

        response = ProductZoningService.getPermissibleFlyZone();

        Assert.areEqual('Confirm with the local authorities', response, 'Both messages must be the same.');

        request.headers.put('CountryCode', 'FR');

        response = ProductZoningService.getPermissibleFlyZone();

        Assert.areEqual('Confirm with the local authorities', response, 'Both messages must be the same.');

        request = new RestRequest();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'GET';
        RestContext.request = request;

        response = ProductZoningService.getPermissibleFlyZone();

        Assert.areEqual('ProductCode is missing or doesn\'t exist', response, 'Both messages must be the same.');

        request = new RestRequest();
        request.requestURI = REQUEST_URL;
        request.addParameter('ProductCode', 'INVALID');
        request.httpMethod = 'GET';
        RestContext.request = request;

        response = ProductZoningService.getPermissibleFlyZone();

        Assert.areEqual('ProductCode is missing or doesn\'t exist', response, 'Both messages must be the same.');
    }

    private static Product2 createProduct() {
        Product2 product = new Product2(Name = 'Test Product', ProductCode = '440123', Family = 'Test Family');
        Database.insert(product);

        return product;
    }
}