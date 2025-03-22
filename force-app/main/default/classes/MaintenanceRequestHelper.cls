public with sharing class MaintenanceRequestHelper extends TriggerHandler {

    private List<Case> lNewData;
    private Map<Id, Case> mOldData;

    public MaintenanceRequestHelper() {
        this.lNewData = (List<Case>) Trigger.new;
        this.mOldData = (Map<Id, Case>) Trigger.oldMap;
    }

    override
    public void afterUpdate() {
        this.scheduleMaintanceRequestForClosedQuotes();
    }

    private void scheduleMaintanceRequestForClosedQuotes() {
        Map<Id, Case> mCases = new Map<Id, Case>();
        Set<String> sValidTypes = new Set<String>{'Routine Maintenance', 'Repair'};

        for (Case c : this.lNewData) {
            if (String.isBlank(c.Vehicle__c) || !c.IsClosed || !sValidTypes.contains(c.Type)) {
                continue;
            }
            mCases.put(c.Id, c);
        }

        if (mCases.isEmpty()) {
            return;
        }

        Map<Id, Set<Id>> mEquipmentSetByCaseId = new Map<Id, Set<Id>>();
        Map<Id, Integer> mMaintanceCycleByCaseId = new Map<Id, Integer>();

        getEquipmentMaintanceItemsToFillMaps(mCases.keySet(), mEquipmentSetByCaseId, mMaintanceCycleByCaseId);

        List<Case> lRoutineMaintenanceCases = generateRoutineMaintenanceCases(mCases.values(), mMaintanceCycleByCaseId);
        Database.insert(lRoutineMaintenanceCases);

        List<Equipment_Maintenance_Item__c> lEquipmentMaitenanceItems = generateEquipmentsToRoutineMaintenanceCases(lRoutineMaintenanceCases, mEquipmentSetByCaseId);
        Database.insert(lEquipmentMaitenanceItems);
    }

    private List<Case> generateRoutineMaintenanceCases(List<Case> lClosedCases, Map<Id, Integer> mMaintanceCycleByCaseId) {
        List<Case> lCasesToInsert = new List<Case>();

        for (Case closedCase : lClosedCases) {           
            Integer maintanceCycle = mMaintanceCycleByCaseId.get(closedCase.Id);
 
            Case routineMaintenanceCase = closedCase.clone();
            routineMaintenanceCase.Type = 'Routine Maintenance';
            routineMaintenanceCase.Status = 'New';
            routineMaintenanceCase.ParentId = closedCase.Id;
            routineMaintenanceCase.Date_Due__c = maintanceCycle == null ? Date.today() : Date.today().addDays(maintanceCycle);

            lCasesToInsert.add(routineMaintenanceCase);
        }
        return lCasesToInsert;
    }

    private List<Equipment_Maintenance_Item__c> generateEquipmentsToRoutineMaintenanceCases(List<Case> lRoutineMaintenanceCases, Map<Id, Set<Id>> mEquipmentSetByCaseId) {
        List<Equipment_Maintenance_Item__c> lEquipmentMaitenanceItems = new List<Equipment_Maintenance_Item__c>(); 

        for (Case c : lRoutineMaintenanceCases) {
            if (!mEquipmentSetByCaseId.containsKey(c.ParentId)) {
                continue;
            }

            for (Id equipmentId : mEquipmentSetByCaseId.get(c.ParentId)) {
                lEquipmentMaitenanceItems.add(new Equipment_Maintenance_Item__c(Equipment__c = equipmentId, Maintenance_Request__c = c.Id));
            }
        }

        return lEquipmentMaitenanceItems;
    }

    private void getEquipmentMaintanceItemsToFillMaps(Set<Id> sCaseIds, Map<Id, Set<Id>> mEquipmentSetByCaseId, Map<Id, Integer> mMaintanceCycleByCaseId) {
        for (Equipment_Maintenance_Item__c item : [
            SELECT Id, Maintenance_Request__c, Equipment__c, Equipment__r.Maintenance_Cycle__c 
            FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :sCaseIds ORDER BY Maintenance_Request__c, Equipment__r.Maintenance_Cycle__c DESC
        ]) {
            Id maintanceRequestId = item.Maintenance_Request__c;
            Integer maintanceCycle = Integer.valueOf(item.Equipment__r.Maintenance_Cycle__c);

            if (!mMaintanceCycleByCaseId.containsKey(maintanceRequestId) || maintanceCycle < mMaintanceCycleByCaseId.get(maintanceRequestId)) {
                mMaintanceCycleByCaseId.put(maintanceRequestId, maintanceCycle);
            }

            if (!mEquipmentSetByCaseId.containsKey(maintanceRequestId)) {
                mEquipmentSetByCaseId.put(maintanceRequestId, new Set<Id>());
            }
            mEquipmentSetByCaseId.get(maintanceRequestId).add(item.Equipment__c);
        }
    }
}