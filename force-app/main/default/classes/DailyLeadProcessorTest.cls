@isTest
public with sharing class DailyLeadProcessorTest {

    public static final String CRON_EXP = '0 0 0 15 3 ? 2042';

    @isTest
    public static void testDailyLeadProcessor() {
        List<Lead> lLeads = new List<Lead>();

        for (Integer i = 0; i < 200; i++) {
            lLeads.add((Lead) new LeadBuilder().genericLead().build());
        }

        Database.insert(lLeads);

        Test.startTest();

        System.schedule('ScheduledApexTest', CRON_EXP, new DailyLeadProcessor());

        Test.stopTest();

        lLeads = [SELECT Id FROM Lead WHERE LeadSource = null];

        Assert.isTrue(lLeads.isEmpty(), 'Todos os leads foram atualizados');
    }
}