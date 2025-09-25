import { LightningElement, track } from 'lwc';
import searchStudents from '@salesforce/apex/StudentController.searchStudents';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Roll No', fieldName: 'Roll_No__c', type: 'text', sortable: true },
    {
        label: 'Status',
        fieldName: 'Status__c',
        type: 'text',
        cellAttributes: { class: { fieldName: 'statusClass' } }
    },
    { label: 'Attendance %', fieldName: 'attendancePctValue', type: 'percent', sortable: true, typeAttributes: { minimumFractionDigits: 0, maximumFractionDigits: 2 } },
    {
        type: 'button',
        typeAttributes: {
            label: 'Select',
            name: 'select',
            title: 'Select Student',
            variant: 'neutral',
            iconName: 'utility:check'
        }
    },
    {
        type: 'button',
        typeAttributes: {
            label: 'View Details',
            name: 'view_details',
            title: 'View Details',
            variant: 'base'
        }
    }
];

export default class StudentSearchLWC extends NavigationMixin(LightningElement) {
    @track searchTerm = '';
    @track students = [];
    @track isLoading = false;
    @track error;
    columns = COLUMNS;
    @track sortedBy;
    @track sortedDirection = 'asc';

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    async handleSearchClick() {
        if (!this.searchTerm || this.searchTerm.length < 2) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Input too short', message: 'Enter at least 2 characters', variant: 'warning' }));
            return;
        }
        this.isLoading = true;
        try {
            const result = await searchStudents({ searchTerm: this.searchTerm });
            this.students = (result || []).map(s => ({
                ...s,
                statusClass: s.Status__c === 'At Risk' ? 'slds-text-color_error' : 'slds-text-color_success',
                attendancePctValue: s.Attendance_Percentage__c != null ? s.Attendance_Percentage__c / 100 : null
            }));
            this.error = undefined;
        } catch (e) {
            this.error = e;
            this.students = [];
            this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: e.body?.message || 'Failed to search students', variant: 'error' }));
        } finally {
            this.isLoading = false;
        }
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        if (action.name === 'view_details') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: { recordId: row.Id, actionName: 'view' }
            });
        } else if (action.name === 'select') {
            // Notify parent about the selected student
            this.dispatchEvent(new CustomEvent('studentselected', { detail: { studentId: row.Id, student: row } }));
            this.dispatchEvent(new ShowToastEvent({ title: 'Selected', message: `Selected ${row.Name}`, variant: 'success' }));
        }
    }

    // Template helpers to avoid complex expressions in markup
    get hasStudents() {
        return Array.isArray(this.students) && this.students.length > 0;
    }

    get showNoResults() {
        return !this.isLoading && !!this.searchTerm && (!Array.isArray(this.students) || this.students.length === 0);
    }

    get isSearchDisabled() {
        return !this.searchTerm || this.searchTerm.length < 2;
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortDirection;
        const cloneData = [...this.students];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.students = cloneData;
    }

    sortBy(field, reverse) {
        return (a, b) => {
            let x = a[field];
            let y = b[field];
            // Handle undefined/null
            x = x === null || x === undefined ? '' : x;
            y = y === null || y === undefined ? '' : y;
            // Numeric compare when both are numbers
            const xn = typeof x === 'number';
            const yn = typeof y === 'number';
            if (xn && yn) {
                return reverse * ((x > y) - (x < y));
            }
            // String compare
            x = x.toString().toLowerCase();
            y = y.toString().toLowerCase();
            return reverse * ((x > y) - (x < y));
        };
    }
}
