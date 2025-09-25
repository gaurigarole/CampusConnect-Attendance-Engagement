import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class AttendanceQuickCreateLWC extends NavigationMixin(LightningElement) {
    @api label = 'New Attendance';
    objectApiName = 'Attendance__c';
    fields = ['Student__c', 'Course__c', 'Date__c', 'Status__c'];

    handleSuccess(event) {
        const recId = event.detail.id;
        this.dispatchEvent(new ShowToastEvent({ title: 'Attendance Saved', message: 'Attendance created successfully', variant: 'success' }));
        this[NavigationMixin.Navigate]({ type: 'standard__recordPage', attributes: { recordId: recId, actionName: 'view' } });
    }

    handleError(event) {
        const msg = event.detail?.message || 'Error creating attendance';
        this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: msg, variant: 'error' }));
    }
}
