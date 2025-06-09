public class Product2Helper {

    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/
    public final static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id FROM CollaborationGroup WHERE Name = :Constants.INVENTORY_ANNOUNCEMENTS OR Name = :('TEST'+Constants.INVENTORY_ANNOUNCEMENTS) LIMIT 1
    ];

    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/
    public static void afterUpdate(List<Product2> lProducts) {
        List<Product2> needsAnnouncement = new List<Product2>();
        Map<String, Inventory_Setting__mdt> mInventorySetting = new Map<String, Inventory_Setting__mdt>();

        for (Inventory_Setting__mdt inventorySetting : Inventory_Setting__mdt.getAll().values()) {
            mInventorySetting.put(inventorySetting.Label, inventorySetting);
        }

        for (Product2 product : lProducts) {
            if (!mInventorySetting.containsKey(product.Family)) {
                continue;
            }

            Inventory_Setting__mdt inventorySetting = mInventorySetting.get(product.Family);
            Decimal alertQuantity = inventorySetting.Low_Quantity_Alert__c;

            if (product.Quantity_Remaining__c > alertQuantity) {
                continue;
            }

            needsAnnouncement.add(product);
        }

        if (needsAnnouncement.isEmpty()) {
            return;
        }

        postAlerts(needsAnnouncement);
    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void postAlerts(List<Product2> productList) {
        if (System.isBatch() || System.isFuture()) {
            return;
        }

        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();

        for (Product2 product : productList) {
            ConnectApi.AnnouncementInput announcement = new ConnectApi.AnnouncementInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            List<ConnectApi.MessageSegmentInput> messageSegmentInput = new List<ConnectApi.MessageSegmentInput>();

            ConnectApi.TextSegmentInput bodySegmentInput = new ConnectApi.TextSegmentInput();

            bodySegmentInput.text = product.Name + ' ' + Constants.INVENTORY_LEVEL_LOW;

            messageSegmentInput.add(bodySegmentInput);
            messageBodyInput.messageSegments = messageSegmentInput;
        
            announcement.sendEmails = false;
            announcement.body = messageBodyInput;
            announcement.parentId = COLLABORATION_GROUP[0].Id;
            announcement.expirationDate = Date.today().addDays(1);

            toPost.add(announcement);
        }

        AnnouncementQueueable announcementQueueable = new AnnouncementQueueable();
        announcementQueueable.toPost = toPost;
        System.enqueueJob(announcementQueueable);
    }
}