public with sharing class RandomContactFactory {

    public static List<Contact> generateRandomContacts(Integer quantity, String lastName) {
        List<Contact> lContacts = new List<Contact>();

        for (Integer i = 0; i < quantity; i++) {
            lContacts.add(new Contact(FirstName = 'Test' + i, LastName = 'lastName'));
        }
        Database.insert(lContacts);

        return lContacts;
    }
}