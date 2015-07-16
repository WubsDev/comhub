global class ContactNotificationBatchScheduler implements Schedulable{

    global void execute(SchedulableContext sc) {

        SendLogInNoticationToContactBatch b1 = new SendLogInNoticationToContactBatch();
        ID batchprocessid = Database.executeBatch(b1,50);           
    }
}