public with sharing class AnimalLocator {

    public static String getAnimalNameById(Integer animalId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals/' + String.valueOf(animalId));
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 200) {
            return 'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody();
        }

        Map<String, Object> mResult = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        Map<String, Object> mAnimal = (Map<String, Object>) mResult.get('animal');

        return (String) mAnimal.get('name');
    }
}