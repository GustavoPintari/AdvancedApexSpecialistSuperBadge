public without sharing class ChartHelper {

    @AuraEnabled
    public static List<ChartData> getInventory() {
        List<ChartData> lChatterData = new List<ChartData>();
        
        for (AggregateResult result : [
            SELECT Family, SUM(Quantity_Remaining__c) sum FROM Product2 WHERE IsActive = true AND Quantity_Remaining__c > 0 GROUP BY Family
        ]) {
            String name = (String) result.get('Family');
            Decimal value = (Decimal) result.get('sum');

            lChatterData.add(new ChartData(name, value));
        }

        return lChatterData;
    }

    public class ChartData {
        public String name { get; set; }
        public Decimal val { get; set; }

        public ChartData(String name, Decimal val) {
            this.name = name;
            this.val = val;
        }
    }
}