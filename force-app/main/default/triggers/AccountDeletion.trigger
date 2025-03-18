trigger AccountDeletion on Account (before delete) {
    for (Account account : [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity) AND Id IN :Trigger.old]) {
        Trigger.oldMap.get(account.Id).addError('Cannot delete account with related opportunities.');
    }
}