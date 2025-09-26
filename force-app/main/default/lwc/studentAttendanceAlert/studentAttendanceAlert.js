import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Student fields
import ATTENDANCE_PERCENTAGE_FIELD from '@salesforce/schema/Student__c.Attendance_Percentage__c';
import STUDENT_NAME_FIELD from '@salesforce/schema/Student__c.Name';
import STUDENT_EMAIL_FIELD from '@salesforce/schema/Student__c.Student_Email__c';
import ROLL_NO_FIELD from '@salesforce/schema/Student__c.Roll_No__c';

const fields = [ATTENDANCE_PERCENTAGE_FIELD, STUDENT_NAME_FIELD, STUDENT_EMAIL_FIELD, ROLL_NO_FIELD];

export default class StudentAttendanceAlert extends LightningElement {
    @api recordId;
    
    @wire(getRecord, { recordId: '$recordId', fields })
    student;

    get attendancePercentage() {
        return getFieldValue(this.student.data, ATTENDANCE_PERCENTAGE_FIELD) || 0;
    }

    get studentName() {
        return getFieldValue(this.student.data, STUDENT_NAME_FIELD);
    }


    get studentEmail() {
        return getFieldValue(this.student.data, STUDENT_EMAIL_FIELD);
    }

    get studentRollNo() {
        return getFieldValue(this.student.data, ROLL_NO_FIELD);
    }

    get showAlert() {
        return this.attendancePercentage < 75;
    }

    get alertVariant() {
        const percentage = this.attendancePercentage;
        if (percentage < 50) return 'error';
        if (percentage < 65) return 'warning';
        return 'warning';
    }

    get alertTitle() {
        const percentage = this.attendancePercentage;
        if (percentage < 50) return 'Critical Attendance Alert';
        if (percentage < 65) return 'Low Attendance Warning';
        return 'Attendance Below Threshold';
    }

    get alertMessage() {
        const percentage = this.attendancePercentage;
        const name = this.studentName;
        
        if (percentage < 50) {
            return `${name} has critically low attendance (${percentage}%). Immediate intervention required.`;
        }
        if (percentage < 65) {
            return `${name} has low attendance (${percentage}%). Consider academic counseling.`;
        }
        return `${name} has attendance below the 75% threshold (${percentage}%). Monitor closely.`;
    }

    get alertIcon() {
        const percentage = this.attendancePercentage;
        if (percentage < 50) return 'utility:error';
        if (percentage < 65) return 'utility:warning';
        return 'utility:info';
    }

    handleSendWarningEmail() {
        // Create email URL
        const emailUrl = `mailto:${this.studentEmail}?subject=Attendance Warning - ${this.studentRollNo}&body=Dear ${this.studentName},%0D%0A%0D%0AYour current attendance is ${this.attendancePercentage}% which is below the required threshold.%0D%0A%0D%0APlease contact your academic advisor to discuss this matter.%0D%0A%0D%0ABest regards,%0D%0AStudent Services`;
        
        window.open(emailUrl, '_blank');
    }

    handleDismissAlert() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Alert Dismissed',
                message: 'Attendance alert has been acknowledged.',
                variant: 'info'
            })
        );
        
        // Hide the alert by setting a flag
        this.template.querySelector('.alert-container').style.display = 'none';
    }

    handleViewAttendanceHistory() {
        // Navigate to attendance history
        this.dispatchEvent(new CustomEvent('viewattendance', {
            detail: { studentId: this.recordId }
        }));
    }
}
