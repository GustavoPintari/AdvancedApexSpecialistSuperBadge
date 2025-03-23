public with sharing class WarehouseSyncSchedule implements Schedulable {

    public String cronExp = '0 0 0 * * ?';
    public String jobName = 'WarehouseSyncScheduleJob';
    
    public String schedule() {
        return System.schedule(this.jobName, this.cronExp, this);
	}

    public void execute(SchedulableContext context) {
        System.enqueueJob(new WarehouseCalloutService());
    }
}