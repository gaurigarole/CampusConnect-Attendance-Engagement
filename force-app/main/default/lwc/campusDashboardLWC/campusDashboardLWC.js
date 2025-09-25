import { LightningElement, track } from 'lwc';

export default class CampusDashboardLWC extends LightningElement {
    @track selectedStudentId;
    @track selectedStudent;

    handleStudentSelected(event) {
        this.selectedStudentId = event.detail.studentId;
        this.selectedStudent = event.detail.student;
    }
}
