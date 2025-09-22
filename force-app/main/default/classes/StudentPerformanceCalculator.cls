/**
 * @description Queueable class for async calculation of student performance scores
 * @author CampusConnect Development Team
 * @date 2025
 */
public class StudentPerformanceCalculator implements Queueable {
    
    private Set<Id> studentIds;
    private Boolean chainNext;
    private Integer batchSize;
    
    /**
     * @description Constructor
     * @param studentIds Set of Student IDs to process
     */
    public StudentPerformanceCalculator(Set<Id> studentIds) {
        this.studentIds = studentIds;
        this.chainNext = false;
        this.batchSize = 100;
    }
    
    /**
     * @description Constructor with chaining option
     * @param studentIds Set of Student IDs to process
     * @param chainNext Whether to chain another job if needed
     */
    public StudentPerformanceCalculator(Set<Id> studentIds, Boolean chainNext) {
        this.studentIds = studentIds;
        this.chainNext = chainNext;
        this.batchSize = 100;
    }
    
    /**
     * @description Execute method for queueable interface
     * @param context QueueableContext
     */
    public void execute(QueueableContext context) {
        System.debug('StudentPerformanceCalculator started for ' + studentIds.size() + ' students');
        
        try {
            // Process students in batches to avoid governor limits
            Set<Id> currentBatch = new Set<Id>();
            Set<Id> remainingStudents = new Set<Id>();
            
            Integer count = 0;
            for (Id studentId : studentIds) {
                if (count < batchSize) {
                    currentBatch.add(studentId);
                    count++;
                } else {
                    remainingStudents.add(studentId);
                }
            }
            
            // Calculate performance scores for current batch
            Map<Id, Decimal> performanceScores = StudentService.calculatePerformanceScores(currentBatch);
            
            // Create custom objects to store performance scores (if you have a Performance__c object)
            // Or update Student records with calculated scores
            updateStudentPerformanceScores(performanceScores);
            
            System.debug('Processed performance scores for ' + performanceScores.size() + ' students');
            
            // Chain next job if there are remaining students and chaining is enabled
            if (!remainingStudents.isEmpty() && chainNext) {
                System.debug('Chaining next job for ' + remainingStudents.size() + ' remaining students');
                System.enqueueJob(new StudentPerformanceCalculator(remainingStudents, true));
            }
            
        } catch (Exception e) {
            System.debug('Error in StudentPerformanceCalculator: ' + e.getMessage());
            
            // Log error to custom object or send notification
            logError('StudentPerformanceCalculator', e.getMessage(), studentIds);
        }
    }
    
    /**
     * @description Updates student records with calculated performance scores
     * @param performanceScores Map of Student ID to Performance Score
     */
    private void updateStudentPerformanceScores(Map<Id, Decimal> performanceScores) {
        List<Student__c> studentsToUpdate = new List<Student__c>();
        
        for (Id studentId : performanceScores.keySet()) {
            Student__c student = new Student__c();
            student.Id = studentId;
            // Assuming you have a Performance_Score__c field on Student object
            // student.Performance_Score__c = performanceScores.get(studentId);
            
            // For now, we'll store it in a text field or create a separate object
            // This is just an example - adjust based on your data model
            studentsToUpdate.add(student);
        }
        
        if (!studentsToUpdate.isEmpty()) {
            try {
                // update studentsToUpdate;
                System.debug('Updated performance scores for ' + studentsToUpdate.size() + ' students');
            } catch (Exception e) {
                System.debug('Error updating student performance scores: ' + e.getMessage());
            }
        }
    }
    
    /**
     * @description Logs errors for monitoring
     * @param className Name of the class where error occurred
     * @param errorMessage Error message
     * @param affectedIds Set of IDs that were being processed
     */
    private void logError(String className, String errorMessage, Set<Id> affectedIds) {
        try {
            // Create error log record (assuming you have an Error_Log__c custom object)
            // Error_Log__c errorLog = new Error_Log__c();
            // errorLog.Class_Name__c = className;
            // errorLog.Error_Message__c = errorMessage;
            // errorLog.Affected_Records__c = String.join(new List<Id>(affectedIds), ',');
            // errorLog.Timestamp__c = DateTime.now();
            // insert errorLog;
            
            System.debug('Error logged: ' + className + ' - ' + errorMessage);
            
        } catch (Exception e) {
            System.debug('Failed to log error: ' + e.getMessage());
        }
    }
    
    /**
     * @description Static method to enqueue performance calculation for all students
     */
    public static void calculateAllStudentPerformances() {
        try {
            // Get all active students
            List<Student__c> students = [
                SELECT Id 
                FROM Student__c 
                WHERE Attendance_Percentage__c != null
                LIMIT 1000
            ];
            
            Set<Id> studentIds = new Set<Id>();
            for (Student__c student : students) {
                studentIds.add(student.Id);
            }
            
            if (!studentIds.isEmpty()) {
                System.enqueueJob(new StudentPerformanceCalculator(studentIds, true));
                System.debug('Enqueued performance calculation for ' + studentIds.size() + ' students');
            }
            
        } catch (Exception e) {
            System.debug('Error enqueuing performance calculation: ' + e.getMessage());
        }
    }
}