@isTest
public with sharing class AnimalLocatorTest {

    @isTest
    public static void testGetAnimalNameById() {
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());

        Test.startTest();

        String animalName = AnimalLocator.getAnimalNameById(1);
        Map<String, Object> mResult = (Map<String, Object>) JSON.deserializeUntyped(AnimalLocatorMock.mJSONAnimalById.get(1));
        Map<String, Object> mAnimal = (Map<String, Object>) mResult.get('animal');

        Test.stopTest();

        Assert.areEqual(mAnimal.get('name'), animalName, 'Os dois nomes devem ser iguais.');
    }

    @isTest
    public static void testGetAnimalNameByIdWhereIdNotExists() {
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());

        Test.startTest();

        String errorMessage = AnimalLocator.getAnimalNameById(9);

        Test.stopTest();

        Assert.areEqual('The status code returned was not expected: 404 {"error": "Animal not found"}', errorMessage, 'As duas mensagens devem ser iguais.');
    }
}