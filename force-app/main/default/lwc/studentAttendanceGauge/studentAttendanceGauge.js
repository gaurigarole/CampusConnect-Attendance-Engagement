import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

// Student fields
import ATTENDANCE_PERCENTAGE_FIELD from '@salesforce/schema/Student__c.Attendance_Percentage__c';
import STUDENT_NAME_FIELD from '@salesforce/schema/Student__c.Name';
import ROLL_NO_FIELD from '@salesforce/schema/Student__c.Roll_No__c';
import STUDENT_EMAIL_FIELD from '@salesforce/schema/Student__c.Student_Email__c';

const fields = [ATTENDANCE_PERCENTAGE_FIELD, STUDENT_NAME_FIELD, ROLL_NO_FIELD, STUDENT_EMAIL_FIELD];

export default class StudentAttendanceGauge extends LightningElement {
    @api recordId;
    
    @wire(getRecord, { recordId: '$recordId', fields })
    student;

    get attendancePercentage() {
        return getFieldValue(this.student.data, ATTENDANCE_PERCENTAGE_FIELD) || 0;
    }

    get studentName() {
        return getFieldValue(this.student.data, STUDENT_NAME_FIELD);
    }

    get studentRollNo() {
        return getFieldValue(this.student.data, ROLL_NO_FIELD);
    }

    get studentEmail() {
        return getFieldValue(this.student.data, STUDENT_EMAIL_FIELD);
    }

    get progressRingClass() {
        const percentage = this.attendancePercentage;
        if (percentage >= 90) return 'progress-ring excellent';
        if (percentage >= 80) return 'progress-ring good';
        if (percentage >= 75) return 'progress-ring warning';
        return 'progress-ring critical';
    }

    get attendanceStatus() {
        const percentage = this.attendancePercentage;
        if (percentage >= 90) return 'Excellent';
        if (percentage >= 80) return 'Good';
        if (percentage >= 75) return 'Needs Attention';
        return 'Critical';
    }

    get statusIcon() {
        const percentage = this.attendancePercentage;
        if (percentage >= 90) return 'utility:success';
        if (percentage >= 80) return 'utility:info';
        if (percentage >= 75) return 'utility:warning';
        return 'utility:error';
    }

    get statusVariant() {
        const percentage = this.attendancePercentage;
        if (percentage >= 90) return 'success';
        if (percentage >= 80) return 'brand';
        if (percentage >= 75) return 'warning';
        return 'error';
    }

    get circumference() {
        return 2 * Math.PI * 45; // radius = 45
    }

    get strokeDasharray() {
        const percentage = this.attendancePercentage;
        const progress = (percentage / 100) * this.circumference;
        return `${progress} ${this.circumference}`;
    }

    handleMarkAttendance() {
        // Navigate to create new attendance record
        this.dispatchEvent(new CustomEvent('markattendance', {
            detail: { 
                studentId: this.recordId,
                studentName: this.studentName 
            }
        }));
    }

    handleSendEmail() {
        // Open email client with student email
        if (this.studentEmail) {
            const emailUrl = `mailto:${this.studentEmail}?subject=Regarding Your Attendance - ${this.studentRollNo}&body=Dear ${this.studentName},%0D%0A%0D%0A`;
            window.open(emailUrl, '_blank');
        }
    }
}
