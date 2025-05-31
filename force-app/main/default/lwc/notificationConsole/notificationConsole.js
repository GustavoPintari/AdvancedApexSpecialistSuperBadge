import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { subscribe, unsubscribe, onError } from "lightning/empApi";

export default class NotificationConsole extends LightningElement {
    
    @track
    notifications = [];

    async connectedCallback() {
        // Configure default error handler for the EMP API
        onError((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    variant: "error",
                    title: "EMP API Error",
                    message: "Check your browser's developer console for more details."
                })
            );
            console.log("EMP API error reported by server: ", JSON.stringify(error));
        });
        // Subscribe to our notification platform event with the EMP API
        // listen to all new events
        // and handle them with handleNotificationEvent
        this.subscription = await subscribe("/event/Notification__e", -1, (event) => this.handleNotificationEvent(event));
        
        this.dispatchEvent(
            new ShowToastEvent({
                variant: "success",
                title: "Ready to receive notifications"
            })
        );
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
    }

    handleClearClick() {
        this.notifications = [];
    }

    get notificationCount() {
        return this.notifications.length;
    }

    handleNotificationEvent(event) {
        console.dir(event);
        // Parse event data
        const id = event.data.event.replayId;
        const message = event.data.payload.Message__c;
        const utcDate = new Date(event.data.payload.CreatedDate);
        const time = `${utcDate.getMinutes()}:${utcDate.getSeconds()}`;
        // Add notification to view
        const notification = {id, message, time};

        this.notifications.push(notification);
        this.dispatchEvent(new ShowToastEvent({variant: "info", title: message}));
    }
}