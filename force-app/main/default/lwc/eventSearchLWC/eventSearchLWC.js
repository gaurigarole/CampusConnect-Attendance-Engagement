import { LightningElement, track, api } from 'lwc';
import searchEvents from '@salesforce/apex/EventController.searchEvents';
import enrollStudentInEvent from '@salesforce/apex/EventController.enrollStudentInEvent';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Event Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Status', fieldName: 'Status__c', type: 'text', sortable: true, cellAttributes: { class: { fieldName: 'statusClass' } } },
    { label: 'Start Date', fieldName: 'Date__c', type: 'date', sortable: true },
    { label: 'End Date', fieldName: 'End_Date__c', type: 'date', sortable: true },
    {
        type: 'button',
        typeAttributes: {
            label: 'Enroll',
            name: 'enroll',
            title: 'Enroll in Event',
            variant: 'brand'
        }
    }
];

export default class EventSearchLWC extends NavigationMixin(LightningElement) {
    @api selectedStudentId; // provided by parent (e.g., dashboard)

    @track startDate;
    @track endDate;
    @track events = [];
    @track isLoading = false;
    @track error;

    columns = COLUMNS;
    @track sortedBy;
    @track sortedDirection = 'asc';

    handleStartDateChange(event) {
        this.startDate = event.target.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }

    async handleSearchClick() {
        if (!this.startDate || !this.endDate) {
            this.showToast('Error', 'Please select a start and end date', 'error');
            return;
        }
        if (new Date(this.startDate) > new Date(this.endDate)) {
            this.showToast('Error', 'Start date cannot be after end date', 'error');
            return;
        }
        this.isLoading = true;
        try {
            const result = await searchEvents({ startDate: this.startDate, endDate: this.endDate });
            this.events = (result || []).map(e => ({
                ...e,
                statusClass: e.Status__c === 'Scheduled' ? 'slds-text-color_success' : (e.Status__c === 'Completed' ? 'slds-text-color_weak' : '')
            }));
            this.error = undefined;
        } catch (e) {
            this.error = e;
            this.events = [];
            this.showToast('Error', e.body?.message || 'Failed to search events', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        if (action.name === 'enroll') {
            this.enroll(row.Id);
        }
    }

    async enroll(eventId) {
        if (!this.selectedStudentId) {
            this.showToast('Select a Student', 'Please select a student from Student Search before enrolling.', 'warning');
            return;
        }
        this.isLoading = true;
        try {
            const newRecordId = await enrollStudentInEvent({ eventId: eventId, studentId: this.selectedStudentId });
            this.showToast('Enrollment successful', 'Attendance record created', 'success');
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: { recordId: newRecordId, actionName: 'view' }
            });
            // Notify parent about selected event
            this.dispatchEvent(new CustomEvent('eventselected', { detail: { eventId } }));
        } catch (e) {
            this.showToast('Error', e.body?.message || 'Failed to enroll', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortDirection;
        const cloneData = [...this.events];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.events = cloneData;
    }

    sortBy(field, reverse) {
        return (a, b) => {
            let x = a[field];
            let y = b[field];
            x = x === null || x === undefined ? '' : x;
            y = y === null || y === undefined ? '' : y;
            // Date fields: convert to Date when both are present
            if (field === 'Date__c' || field === 'End_Date__c') {
                const dx = x ? new Date(x) : new Date(0);
                const dy = y ? new Date(y) : new Date(0);
                return reverse * ((dx > dy) - (dx < dy));
            }
            const xn = typeof x === 'number';
            const yn = typeof y === 'number';
            if (xn && yn) {
                return reverse * ((x > y) - (x < y));
            }
            x = x.toString().toLowerCase();
            y = y.toString().toLowerCase();
            return reverse * ((x > y) - (x < y));
        };
    }

    // Template helpers
    get isSearchDisabled() {
        return !this.startDate || !this.endDate || new Date(this.startDate) > new Date(this.endDate);
    }

    get hasEvents() {
        return Array.isArray(this.events) && this.events.length > 0;
    }

    get showNoResults() {
        return !this.isLoading && !!this.startDate && !!this.endDate && (!Array.isArray(this.events) || this.events.length === 0);
    }
}
