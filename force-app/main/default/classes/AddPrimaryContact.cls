public with sharing class AddPrimaryContact implements Queueable {

    private Contact contact;
    private String stateCode;

    public AddPrimaryContact(Contact contact, String stateCode) {
        this.stateCode = stateCode;
        this.contact = contact;
    }

    public void execute(QueueableContext context) {
        List<Contact> lContactsToClone = new List<Contact>();

        for (Account account : [SELECT Id, Name FROM Account WHERE BillingState = :this.stateCode LIMIT 200]) {
            Contact contact = this.contact.clone();
            contact.AccountId = account.Id;

            lContactsToClone.add(contact);
        }

        Database.insert(lContactsToClone);
    }
}