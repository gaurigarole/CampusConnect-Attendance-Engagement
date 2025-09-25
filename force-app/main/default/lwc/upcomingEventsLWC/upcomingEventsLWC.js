import { LightningElement, wire, track } from 'lwc';
import getScheduledEventsWithin7Days from '@salesforce/apex/EventController.getScheduledEventsWithin7Days';
import { NavigationMixin } from 'lightning/navigation';

export default class UpcomingEventsLWC extends NavigationMixin(LightningElement) {
    @track events = [];
    @track error;

    @wire(getScheduledEventsWithin7Days)
    wired({ error, data }) {
        if (data) {
            this.events = data.map(e => ({
                ...e,
                statusClass: e.Status__c === 'Scheduled' ? 'slds-text-color_brand' : 'slds-text-color_weak'
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.events = [];
        }
    }

    viewEvent(event) {
        const id = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId: id, actionName: 'view' }
        });
    }

    // Template helpers
    get hasEvents() {
        return Array.isArray(this.events) && this.events.length > 0;
    }

    get showEmpty() {
        return !this.error && (!Array.isArray(this.events) || this.events.length === 0);
    }
}
