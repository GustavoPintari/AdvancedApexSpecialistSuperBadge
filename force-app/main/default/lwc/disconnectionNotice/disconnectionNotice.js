import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class DisconnectionNotice extends LightningElement {
    subscription = {};
    channelName = '/event/Asset_Disconnection__e';
    status;
    identifier;

    connectedCallback() {
        this.handleSubscribe();
    }

    handleSubscribe() {
        const messageCallBack = (response) => {
            const assetId = response.data.payload.Asset_Identifier__c;
            const isDisconnected = response.data.payload.Disconnected__c;
            
            if (isDisconnected) {
                this.showSuccessToast(assetId);
            } else {
                this.showErrorToast();
            }
        };

        subscribe(this.channelName, -1, messageCallBack).then((response) => {
            this.subscription = response;
        });

        onError((error) => {
            console.error('Error received from server: ', JSON.stringify(error));
        });
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleUnsubscribe() {
        if (this.subscription) {
        unsubscribe(this.subscription)
            .then(() => {
                this.subscription = null;
            })
            .catch((error) => {
                console.error('Unsubscribe error:', error);
            });
        }
    }

    showSuccessToast(assetId) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Asset Id ' + assetId + ' is now disconnected',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Asset was not disconnected. Try Again.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}