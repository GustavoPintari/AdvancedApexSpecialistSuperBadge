trigger AccountAddressTrigger on Account (before insert, before update) {
    new AccountTH().copyBillingPostalCodeToShippingPostalCode();
}

