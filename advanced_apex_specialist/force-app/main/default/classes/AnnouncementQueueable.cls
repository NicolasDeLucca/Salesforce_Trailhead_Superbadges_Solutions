/**
 * @name AnnouncementQueueable
 * @description This class posts Chatter Announcements
**/

public class AnnouncementQueueable implements Queueable
{
    public List<ConnectApi.AnnouncementInput> toPost { get; set; }
    
    public AnnouncementQueueable(List<ConnectApi.AnnouncementInput> announcementsToPost)
    {
        this.toPost = announcementsToPost;
    }

    public void execute(QueueableContext context)
    {
        this.postAnnouncements();
    }

    /**
     * @name postAnnouncements
     * @description This method is provided for you to facilitate the Super Badge
    **/
    
    public void PostAnnouncements()
    {
        while (this.toPost.size() > 0)
        {
            if (Limits.getDMLStatements() < Limits.getLimitDMLStatements() && !test.isRunningTest())
            {
                ConnectApi.AnnouncementInput input = this.toPost.remove(0);
                ConnectApi.Announcements.postAnnouncement('Internal', input);
            } 
            else break;
        }

        if (this.toPost.size() > 0 && !test.isRunningTest())
        {
            AnnouncementQueueable queue = new AnnouncementQueueable(this.toPost);
            System.enqueueJob(queue);
        }
    }
}

