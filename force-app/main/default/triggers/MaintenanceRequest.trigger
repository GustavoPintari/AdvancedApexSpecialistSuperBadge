trigger MaintenanceRequest on Case (after update) {
    new MaintenanceRequestHelper().run();
}