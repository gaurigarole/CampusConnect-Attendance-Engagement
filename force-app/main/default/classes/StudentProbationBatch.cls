/**
 * @description Batch class to mark students as Probation if attendance < 50%
 * @author CampusConnect Development Team
 * @date 2025
 */
public class StudentProbationBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    // Track processed records for reporting
    public Integer recordsProcessed = 0;
    public Integer recordsUpdated = 0;
    public List<String> errors = new List<String>();
    
    /**
     * @description Start method - defines the scope of records to process
     * @param bc BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('StudentProbationBatch started at: ' + DateTime.now());
        
        // Query students with low attendance who are not already on probation
        return Database.getQueryLocator([
            SELECT Id, Name, Roll_No__c, Attendance_Percentage__c, Status__c, Student_Email__c
            FROM Student__c 
            WHERE Attendance_Percentage__c < 50 
            AND Status__c != 'Probation'
            AND Attendance_Percentage__c != null
        ]);
    }
    
    /**
     * @description Execute method - processes each batch of records
     * @param bc BatchableContext
     * @param scope List of Student records to process
     */
    public void execute(Database.BatchableContext bc, List<Student__c> scope) {
        List<Student__c> studentsToUpdate = new List<Student__c>();
        
        try {
            for (Student__c student : scope) {
                recordsProcessed++;
                
                // Update status to Probation
                student.Status__c = StudentService.STATUS_PROBATION;
                studentsToUpdate.add(student);
                
                System.debug('Marking student ' + student.Name + ' as Probation (Attendance: ' + 
                           student.Attendance_Percentage__c + '%)');
            }
            
            // Bulk update students
            if (!studentsToUpdate.isEmpty()) {
                Database.SaveResult[] results = Database.update(studentsToUpdate, false);
                
                // Process results and track errors
                for (Integer i = 0; i < results.size(); i++) {
                    if (results[i].isSuccess()) {
                        recordsUpdated++;
                    } else {
                        String errorMsg = 'Failed to update student ' + studentsToUpdate[i].Name + ': ';
                        for (Database.Error error : results[i].getErrors()) {
                            errorMsg += error.getMessage() + '; ';
                        }
                        errors.add(errorMsg);
                        System.debug('Error: ' + errorMsg);
                    }
                }
            }
            
        } catch (Exception e) {
            String errorMsg = 'Exception in StudentProbationBatch.execute: ' + e.getMessage();
            errors.add(errorMsg);
            System.debug(errorMsg);
        }
    }
    
    /**
     * @description Finish method - performs cleanup and sends summary
     * @param bc BatchableContext
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('StudentProbationBatch completed at: ' + DateTime.now());
        System.debug('Records processed: ' + recordsProcessed);
        System.debug('Records updated: ' + recordsUpdated);
        System.debug('Errors encountered: ' + errors.size());
        
        // Send summary email to administrators
        sendSummaryEmail();
        
        // Chain next batch job if needed
        // Database.executeBatch(new EventSummaryBatch(), 200);
    }
    
    /**
     * @description Sends summary email to administrators
     */
    private void sendSummaryEmail() {
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            // Get admin users (you can customize this query)
            List<User> admins = [SELECT Id, Email FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 5];
            
            if (!admins.isEmpty()) {
                List<String> toAddresses = new List<String>();
                for (User admin : admins) {
                    if (String.isNotBlank(admin.Email)) {
                        toAddresses.add(admin.Email);
                    }
                }
                
                email.setToAddresses(toAddresses);
                email.setSubject('CampusConnect: Nightly Student Probation Update Summary');
                
                String emailBody = 'Student Probation Batch Job Summary\n\n';
                emailBody += 'Execution Date: ' + DateTime.now().format() + '\n';
                emailBody += 'Records Processed: ' + recordsProcessed + '\n';
                emailBody += 'Records Updated: ' + recordsUpdated + '\n';
                emailBody += 'Errors Encountered: ' + errors.size() + '\n\n';
                
                if (!errors.isEmpty()) {
                    emailBody += 'Error Details:\n';
                    for (String error : errors) {
                        emailBody += '- ' + error + '\n';
                    }
                }
                
                emailBody += '\nThis is an automated message from CampusConnect.';
                
                email.setPlainTextBody(emailBody);
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                System.debug('Summary email sent to administrators');
            }
            
        } catch (Exception e) {
            System.debug('Error sending summary email: ' + e.getMessage());
        }
    }
}