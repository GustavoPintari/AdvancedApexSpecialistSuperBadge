/**
 * @description       : Classe builder para o objeto Account
 * @author            : Thayna Peres (thayna@visumdigital.com)
 * @last modified on  : 28-02-2025
 * @last modified by  : Thayna Peres (thayna@visumdigital.com)
**/
@isTest
public class AccountBuilder extends GenericBuilder {

    public AccountBuilder() {
        super(new Account());
    }

    public AccountBuilder setBillingState(String billingState) {
        this.assign('BillingState', billingState);
        return this;
    }

    public AccountBuilder genericAccount() {
        this.assign('Name', Random.generateText(10));
        return this;
    }
}