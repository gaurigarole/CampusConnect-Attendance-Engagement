import { LightningElement, wire, track } from 'lwc';
import getAtRiskStudents from '@salesforce/apex/StudentController.getAtRiskStudents';
import { NavigationMixin } from 'lightning/navigation';

export default class AtRiskStudentsLWC extends NavigationMixin(LightningElement) {
    @track students = [];
    @track error;

    @wire(getAtRiskStudents)
    wired({ error, data }) {
        if (data) {
            this.students = data.map(s => ({
                ...s,
                statusClass: 'slds-badge slds-theme_error'
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.students = [];
        }
    }

    handleView(event) {
        const id = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId: id, actionName: 'view' }
        });
    }

    // Template helpers
    get hasStudents() {
        return Array.isArray(this.students) && this.students.length > 0;
    }

    get showEmpty() {
        return !this.error && (!Array.isArray(this.students) || this.students.length === 0);
    }
}
