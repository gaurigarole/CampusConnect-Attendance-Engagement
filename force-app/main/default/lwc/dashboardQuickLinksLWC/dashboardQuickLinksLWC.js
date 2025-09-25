import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class DashboardQuickLinksLWC extends NavigationMixin(LightningElement) {
    newStudent() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Student__c',
                actionName: 'new'
            }
        });
    }

    newAttendance() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Attendance__c',
                actionName: 'new'
            }
        });
    }
}
