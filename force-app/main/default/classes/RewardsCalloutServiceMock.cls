@isTest
public with sharing class RewardsCalloutServiceMock {

    public class MockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"success"}');
            response.setStatusCode(200);

            return response;
        }
    }

    public class MockFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            throw new CalloutException('Simulated callout failure');
        }
    }
}