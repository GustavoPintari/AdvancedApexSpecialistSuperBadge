trigger BatchApexErrorEvent on BatchApexErrorEvent (after insert) {
    new BatchApexErrorEventTH().run();
}