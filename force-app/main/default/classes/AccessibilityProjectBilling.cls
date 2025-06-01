global class AccessibilityProjectBilling {
    
     @future(callout = true)
     public static void callBillingService(String projectId, Decimal billingAmount) {
          BillingServiceProxy.InvoicesPortSoap11 stub = new BillingServiceProxy.InvoicesPortSoap11();

          BillingServiceProxy.project project = new BillingServiceProxy.project();
          project.projectid = projectId;
          project.billAmount = (Double) billingAmount;
          project.username = '{!$Credential.BillingServiceCredential.username}';
          project.password = '{!$Credential.BillingServiceCredential.password}';

          String status = stub.billProject(project);

          if (status != 'ok') {
               return;
          }
          
          Accessibility_Project__c ap = [SELECT Id, Status__c FROM Accessibility_Project__c WHERE Id = :projectId];
          ap.Status__c = 'Complete';
          Database.update(ap);
     }
}