public with sharing class RewardsCalloutService {

    private static final String ENDPOINT = 'callout:BalancedLiving/rewards';

    public static Integer submitUsersForRewardCallout(String jsonBody) {

        if (String.isBlank(jsonBody)) {
            return 500;
        }

        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonBody);

        Integer statusCode;

        try {
            HttpResponse response = new Http().send(request);
            statusCode = response.getStatusCode();
        } catch (Exception e) {
            statusCode = 500;
        }

        return statusCode;
    }
}