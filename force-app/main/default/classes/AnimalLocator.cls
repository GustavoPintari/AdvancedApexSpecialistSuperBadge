public with sharing class AnimalLocator {

    public String getAnimalNameById(Integer animalId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals/' + String.valueOf(animalId));
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 200) {
            return 'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus();
        }

        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        // Object animal = (Object) results.get('animal');

        // return animal.get('Name');
    }
}