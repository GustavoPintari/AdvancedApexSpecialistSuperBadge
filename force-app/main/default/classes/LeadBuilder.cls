@isTest
public with sharing class LeadBuilder extends GenericBuilder {

    public LeadBuilder() {
        super(new Lead());
    }

    public LeadBuilder setFirstName(String firstName) {
        this.assign('FirstName', firstName);
        return this;
    }

    public LeadBuilder setLastName(String lastName) {
        this.assign('LastName', lastName);
        return this;
    }

    public LeadBuilder setOwnerId(Id ownerId) {
        this.assign('OwnerId', ownerId);
        return this;
    }

    public LeadBuilder setEmail(String email) {
        this.assign('Email', email);
        return this;
    }

    public LeadBuilder setStatus(String status) {
        this.assign('Status', status);
        return this;
    }

    public LeadBuilder setCompany(String company) {
        this.assign('Company', company);
        return this;
    }

    public LeadBuilder genericLead() {
        String firstName = Random.generateText(10);
        String lastName = Random.generateText(10);

        this.setFirstName(firstName)
            .setLastName(lastName)
            .setStatus('Aberto')
            .setEmail(firstName + '@test.com')
            .setCompany(firstName);
        return this;
    }
}