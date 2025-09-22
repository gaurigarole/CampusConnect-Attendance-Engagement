/**
 * @description Trigger handler for Student__c object
 * @author CampusConnect Development Team
 * @date 2025
 */
public with sharing class StudentTriggerHandler {
    
    // Prevent recursive trigger execution
    private static Boolean isExecuting = false;
    
    /**
     * @description Main entry point for Student trigger
     * @param newStudents List of new Student records
     * @param oldStudents List of old Student records
     * @param triggerEvent Type of trigger event (BEFORE_INSERT, AFTER_UPDATE, etc.)
     */
    public static void handleTrigger(List<Student__c> newStudents, List<Student__c> oldStudents, String triggerEvent) {
        
        // Prevent recursive execution
        if (isExecuting) {
            return;
        }
        isExecuting = true;
        
        try {
            switch on triggerEvent {
                when 'BEFORE_INSERT' {
                    handleBeforeInsert(newStudents);
                }
                when 'BEFORE_UPDATE' {
                    handleBeforeUpdate(newStudents, oldStudents);
                }
                when 'AFTER_INSERT' {
                    handleAfterInsert(newStudents);
                }
                when 'AFTER_UPDATE' {
                    handleAfterUpdate(newStudents, oldStudents);
                }
            }
        } catch (Exception e) {
            System.debug('Error in StudentTriggerHandler: ' + e.getMessage());
            throw e;
        } finally {
            isExecuting = false;
        }
    }
    
    /**
     * @description Handles before insert logic
     * @param newStudents List of new Student records
     */
    private static void handleBeforeInsert(List<Student__c> newStudents) {
        // Update student status based on attendance percentage
        StudentService.updateStudentStatus(newStudents);
        
        // Set default values if needed
        setDefaultValues(newStudents);
    }
    
    /**
     * @description Handles before update logic
     * @param newStudents List of new Student records
     * @param oldStudents List of old Student records
     */
    private static void handleBeforeUpdate(List<Student__c> newStudents, List<Student__c> oldStudents) {
        Map<Id, Student__c> oldStudentMap = new Map<Id, Student__c>(oldStudents);
        List<Student__c> studentsWithAttendanceChange = new List<Student__c>();
        
        // Check which students had attendance percentage changes
        for (Student__c newStudent : newStudents) {
            Student__c oldStudent = oldStudentMap.get(newStudent.Id);
            
            if (newStudent.Attendance_Percentage__c != oldStudent.Attendance_Percentage__c) {
                studentsWithAttendanceChange.add(newStudent);
            }
        }
        
        // Update status for students with attendance changes
        if (!studentsWithAttendanceChange.isEmpty()) {
            StudentService.updateStudentStatus(studentsWithAttendanceChange);
        }
    }
    
    /**
     * @description Handles after insert logic
     * @param newStudents List of new Student records
     */
    private static void handleAfterInsert(List<Student__c> newStudents) {
        // Send notifications for at-risk students
        sendNotificationsForAtRiskStudents(newStudents);
    }
    
    /**
     * @description Handles after update logic
     * @param newStudents List of new Student records
     * @param oldStudents List of old Student records
     */
    private static void handleAfterUpdate(List<Student__c> newStudents, List<Student__c> oldStudents) {
        Map<Id, Student__c> oldStudentMap = new Map<Id, Student__c>(oldStudents);
        List<Student__c> studentsWithStatusChange = new List<Student__c>();
        
        // Check which students had status changes
        for (Student__c newStudent : newStudents) {
            Student__c oldStudent = oldStudentMap.get(newStudent.Id);
            
            if (newStudent.Status__c != oldStudent.Status__c && 
                (newStudent.Status__c == StudentService.STATUS_AT_RISK || 
                 newStudent.Status__c == StudentService.STATUS_PROBATION)) {
                studentsWithStatusChange.add(newStudent);
            }
        }
        
        // Send notifications for newly at-risk students
        if (!studentsWithStatusChange.isEmpty()) {
            sendNotificationsForAtRiskStudents(studentsWithStatusChange);
        }
    }
    
    /**
     * @description Sets default values for new student records
     * @param students List of Student records
     */
    private static void setDefaultValues(List<Student__c> students) {
        for (Student__c student : students) {
            // Set default attendance percentage if not provided
            if (student.Attendance_Percentage__c == null) {
                student.Attendance_Percentage__c = 100.0;
            }
            
            // Set default status if not already set by updateStudentStatus
            if (String.isBlank(student.Status__c)) {
                student.Status__c = StudentService.STATUS_REGULAR;
            }
        }
    }
    
    /**
     * @description Sends notifications for at-risk students
     * @param students List of Student records to check
     */
    private static void sendNotificationsForAtRiskStudents(List<Student__c> students) {
        Set<Id> atRiskStudentIds = new Set<Id>();
        
        for (Student__c student : students) {
            if (student.Status__c == StudentService.STATUS_AT_RISK || 
                student.Status__c == StudentService.STATUS_PROBATION) {
                atRiskStudentIds.add(student.Id);
            }
        }
        
        // Send external notifications asynchronously
        if (!atRiskStudentIds.isEmpty()) {
            StudentService.sendExternalNotification(atRiskStudentIds, 'ATTENDANCE_ALERT');
        }
    }
}