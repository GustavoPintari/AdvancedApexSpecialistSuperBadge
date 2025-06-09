/**
 * @name AnnouncementQueueable
 * @description This class posts Chatter Announcements
**/
public class AnnouncementQueueable implements Queueable {

    public List<ConnectApi.AnnouncementInput> toPost;

    public void execute(QueueableContext context) {
        postAnnouncements(this.toPost);
    }

    /**
     * @name postAnnouncements
     * @description This method is provided for you to facilitate the Super Badge
    **/
    public static void postAnnouncements(List<ConnectApi.AnnouncementInput> announcements) {
        while (announcements.size() > 0) {
            if (Limits.getDMLStatements() < Limits.getLimitDMLStatements() && !Test.isRunningTest()) {
                ConnectApi.AnnouncementInput a = announcements.remove(0);
                ConnectApi.Announcements.postAnnouncement('Internal', a);
            } else {
                break;
            }
        }

        AnnouncementQueueable announcementQueueable = new AnnouncementQueueable();
        announcementQueueable.toPost = announcements;

        if (!Test.isRunningTest() && !System.isQueueable()) {
            System.enqueueJob(announcementQueueable);
        }
    }
}