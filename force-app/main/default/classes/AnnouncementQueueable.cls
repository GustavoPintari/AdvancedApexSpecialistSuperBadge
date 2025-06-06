/**
 * @name AnnouncementQueueable
 * @description This class posts Chatter Announcements
**/
public class AnnouncementQueueable implements Queueable {

    public List<ConnectApi.AnnouncementInput> toPost;

    public AnnouncementQueueable(List<ConnectApi.AnnouncementInput> lAnnouncementInput) {
        this.toPost = lAnnouncementInput;
    }

    public void execute(QueueableContext context) {
        postAnnouncements(this.toPost);
    }

    /**
     * @name postAnnouncements
     * @description This method is provided for you to facilitate the Super Badge
    **/
    public static void postAnnouncements(List<ConnectApi.AnnouncementInput> announcements) {
        if (Test.isRunningTest() || announcements?.isEmpty()) {
            return;
        }

        while (announcements.size() > 0 ) {
            if (Limits.getDMLStatements() < Limits.getLimitDMLStatements()) {
                ConnectApi.AnnouncementInput a = announcements.remove(0);
                ConnectApi.Announcements.postAnnouncement('Internal', a);
            } else {
                break;
            }
        }

        System.enqueueJob(new AnnouncementQueueable(announcements));
    }
}