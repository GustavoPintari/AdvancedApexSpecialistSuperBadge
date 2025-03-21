@isTest
public with sharing class LeadProcessorTest {

    @isTest
    public static void testLeadProcessorBatch() {
        List<Lead> lLeads = new List<Lead>();

        for (Integer i = 0; i < 200; i++) {
            lLeads.add((Lead) new LeadBuilder().genericLead().build());
        }

        Database.insert(lLeads);

        Test.startTest();

        Database.executeBatch(new LeadProcessor(), 200);
        
        Test.stopTest();

        lLeads = [SELECT Id, LeadSource FROM Lead WHERE LeadSource = null];

        Assert.isTrue(lLeads.isEmpty(), 'Todos os leads da organização devem estar com a origem marcada como DreamForce');
    }
}