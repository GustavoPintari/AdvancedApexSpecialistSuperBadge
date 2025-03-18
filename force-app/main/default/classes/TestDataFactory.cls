@isTest
public class TestDataFactory {

    public static List<Account> createAccountsWithlOpportunities(Integer quantityOfAccounts, Integer quantityOfOpportunitiesByAccount) {
        List<Account> lAccounts = new List<Account>();

        for (Integer i = 0; i < quantityOfAccounts; i++) {
            lAccounts.add(new Account(Name = 'TestAccount' + i));
        }
        Database.insert(lAccounts);

        List<Opportunity> lOpportunities = new List<Opportunity>();

        for(Integer j = 0 ; j < quantityOfAccounts; j++) {
            Account account = lAccounts.get(j);

            for(Integer k = 0 ; k < quantityOfOpportunitiesByAccount; k++) {
                lOpportunities.add(new Opportunity(
                    Name = account.Name + ' Opportunity ' + k,
                    AccountId = account.Id,
                    StageName = 'Prospecting',
                    CloseDate = System.today().addMonths(1)
                ));
            }
        }
        Database.insert(lOpportunities);
        return lAccounts;
    }
}