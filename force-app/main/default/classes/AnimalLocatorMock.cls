@isTest
public class AnimalLocatorMock implements HttpCalloutMock {

    public static Map<Integer, String> mJSONAnimalById = new Map<Integer, String>{
        1 => '{"animal":{"id": 1, "name": "majestic badger"}}',
        2 => '{"animal":{"id": 2, "name": "fluffy bunny"}}',
        3 => '{"animal":{"id": 3, "name": "scary bear"}}',
        4 => '{"animal":{"id": 4, "name": "chicken"}}',
        5 => '{"animal":{"id": 5, "name": "mighty moose"}}'
    };

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);

        String url = request.getEndpoint();
        if (url.endsWith('/animals')) {
            response.setBody('{"animals": [' + String.join(mJSONAnimalById.values(), ',') + ']}');
        } else {
            Integer animalId = Integer.valueOf(url.substring(url.lastIndexOf('/') + 1));

            if (mJSONAnimalById.containsKey(animalId)) {
                response.setBody(mJSONAnimalById.get(animalId));
            } else {
                response.setStatusCode(404);
                response.setBody('{"error": "Animal not found"}');
            }
        }
        return response;
    }
}