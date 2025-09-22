@isTest
public with sharing class TestValidationRules {
    @isTest
    static void testAttendancePercentageValidation() {
        // This test will help us identify any validation rules on the Student__c object
        Test.startTest();
        
        // Create a student with a valid attendance percentage
        Student__c validStudent = new Student__c(
            Name = 'Test Student',
            Roll_No__c = 'TS999',
            Student_Email__c = 'test@campusconnect.com',
            Attendance_Percentage__c = 80.0,
            Status__c = 'Regular'
        );
        
        try {
            insert validStudent;
            System.debug('Successfully inserted student with Attendance_Percentage__c = 80.0');
            delete validStudent;
        } catch (Exception e) {
            System.debug('Error inserting student: ' + e.getMessage());
        }
        
        // Try with a different value
        validStudent.Attendance_Percentage__c = 50.0;
        
        try {
            insert validStudent;
            System.debug('Successfully inserted student with Attendance_Percentage__c = 50.0');
            delete validStudent;
        } catch (Exception e) {
            System.debug('Error inserting student: ' + e.getMessage());
        }
        
        // Try with another value
        validStudent.Attendance_Percentage__c = 20.0;
        
        try {
            insert validStudent;
            System.debug('Successfully inserted student with Attendance_Percentage__c = 20.0');
            delete validStudent;
        } catch (Exception e) {
            System.debug('Error inserting student: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
}
