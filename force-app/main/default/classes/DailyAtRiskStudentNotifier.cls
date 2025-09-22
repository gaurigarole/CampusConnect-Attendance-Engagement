/**
 * @description Scheduled class to send daily notifications about at-risk students to faculty
 * @author CampusConnect Development Team
 * @date 2025
 */
public class DailyAtRiskStudentNotifier implements Schedulable {
    
    /**
     * @description Execute method for Schedulable interface
     * @param sc SchedulableContext
     */
    public void execute(SchedulableContext sc) {
        System.debug('DailyAtRiskStudentNotifier started at: ' + DateTime.now());
        
        try {
            // Get at-risk students
            List<Student__c> atRiskStudents = StudentService.getStudentsWithLowAttendance(75);
            
            if (!atRiskStudents.isEmpty()) {
                // Send notifications to faculty
                sendFacultyNotifications(atRiskStudents);
                
                // Also trigger batch job for probation updates
                Database.executeBatch(new StudentProbationBatch(), 200);
                
                System.debug('Sent notifications for ' + atRiskStudents.size() + ' at-risk students');
            } else {
                System.debug('No at-risk students found');
            }
            
        } catch (Exception e) {
            System.debug('Error in DailyAtRiskStudentNotifier: ' + e.getMessage());
            
            // Send error notification to administrators
            sendErrorNotification(e.getMessage());
        }
    }
    
    /**
     * @description Sends notifications to faculty about at-risk students
     * @param atRiskStudents List of at-risk students
     */
    private void sendFacultyNotifications(List<Student__c> atRiskStudents) {
        try {
            // Get faculty members
            List<Faculty__c> facultyMembers = [
                SELECT Id, Email__c, First_Name__c, Last_Name__c
                FROM Faculty__c 
                WHERE Email__c != null
                LIMIT 50
            ];
            
            if (!facultyMembers.isEmpty()) {
                List<String> facultyEmails = new List<String>();
                for (Faculty__c faculty : facultyMembers) {
                    facultyEmails.add(faculty.Email__c);
                }
                
                // Create and send email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(facultyEmails);
                email.setSubject('CampusConnect: Daily At-Risk Students Report - ' + Date.today().format());
                
                String emailBody = buildAtRiskStudentEmailBody(atRiskStudents);
                email.setHtmlBody(emailBody);
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                System.debug('At-risk student notification sent to ' + facultyEmails.size() + ' faculty members');
            }
            
        } catch (Exception e) {
            System.debug('Error sending faculty notifications: ' + e.getMessage());
        }
    }
    
    /**
     * @description Builds HTML email body for at-risk student notifications
     * @param atRiskStudents List of at-risk students
     * @return String HTML email content
     */
    private String buildAtRiskStudentEmailBody(List<Student__c> atRiskStudents) {
        String emailBody = '<html><body>';
        emailBody += '<h2>CampusConnect: Daily At-Risk Students Report</h2>';
        emailBody += '<p><strong>Date:</strong> ' + Date.today().format() + '</p>';
        emailBody += '<p>The following students require immediate attention due to low attendance:</p>';
        
        // Students table
        emailBody += '<table border="1" cellpadding="8" cellspacing="0" style="border-collapse: collapse; width: 100%;">';
        emailBody += '<tr style="background-color: #ff6b6b; color: white;">';
        emailBody += '<th>Student Name</th><th>Roll No</th><th>Attendance %</th><th>Status</th><th>Email</th>';
        emailBody += '</tr>';
        
        for (Student__c student : atRiskStudents) {
            String rowColor = '';
            if (student.Status__c == 'Probation') {
                rowColor = 'background-color: #ffecec;';
            } else if (student.Status__c == 'At Risk') {
                rowColor = 'background-color: #fff3cd;';
            }
            
            emailBody += '<tr style="' + rowColor + '">';
            emailBody += '<td>' + (student.Name != null ? student.Name : 'N/A') + '</td>';
            emailBody += '<td>' + (student.Roll_No__c != null ? student.Roll_No__c : 'N/A') + '</td>';
            emailBody += '<td style="text-align: center;">' + 
                        (student.Attendance_Percentage__c != null ? student.Attendance_Percentage__c.format() + '%' : 'N/A') + '</td>';
            emailBody += '<td><strong>' + (student.Status__c != null ? student.Status__c : 'N/A') + '</strong></td>';
            emailBody += '<td>' + (student.Student_Email__c != null ? student.Student_Email__c : 'N/A') + '</td>';
            emailBody += '</tr>';
        }
        emailBody += '</table>';
        
        // Summary statistics
        Integer probationCount = 0;
        Integer atRiskCount = 0;
        for (Student__c student : atRiskStudents) {
            if (student.Status__c == 'Probation') {
                probationCount++;
            } else if (student.Status__c == 'At Risk') {
                atRiskCount++;
            }
        }
        
        emailBody += '<br><h3>Summary</h3>';
        emailBody += '<ul>';
        emailBody += '<li><strong>Total At-Risk Students:</strong> ' + atRiskStudents.size() + '</li>';
        emailBody += '<li><strong>Students on Probation:</strong> ' + probationCount + '</li>';
        emailBody += '<li><strong>Students At Risk:</strong> ' + atRiskCount + '</li>';
        emailBody += '</ul>';
        
        emailBody += '<h3>Recommended Actions</h3>';
        emailBody += '<ul>';
        emailBody += '<li>Contact students with attendance below 50% immediately</li>';
        emailBody += '<li>Schedule counseling sessions for at-risk students</li>';
        emailBody += '<li>Review course engagement and participation</li>';
        emailBody += '<li>Consider additional support resources</li>';
        emailBody += '</ul>';
        
        emailBody += '<br><p><em>This is an automated daily report from CampusConnect Student Management System.</em></p>';
        emailBody += '<p><em>For questions or support, please contact the IT department.</em></p>';
        emailBody += '</body></html>';
        
        return emailBody;
    }
    
    /**
     * @description Sends error notification to administrators
     * @param errorMessage Error message to include
     */
    private void sendErrorNotification(String errorMessage) {
        try {
            List<User> admins = [
                SELECT Id, Email 
                FROM User 
                WHERE Profile.Name = 'System Administrator' 
                AND IsActive = true 
                LIMIT 5
            ];
            
            if (!admins.isEmpty()) {
                List<String> adminEmails = new List<String>();
                for (User admin : admins) {
                    if (String.isNotBlank(admin.Email)) {
                        adminEmails.add(admin.Email);
                    }
                }
                
                if (!adminEmails.isEmpty()) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(adminEmails);
                    email.setSubject('CampusConnect: Error in Daily At-Risk Student Notifier');
                    
                    String emailBody = 'An error occurred in the Daily At-Risk Student Notifier scheduled job:\n\n';
                    emailBody += 'Error Message: ' + errorMessage + '\n';
                    emailBody += 'Timestamp: ' + DateTime.now().format() + '\n\n';
                    emailBody += 'Please check the debug logs for more details.\n\n';
                    emailBody += 'This is an automated error notification from CampusConnect.';
                    
                    email.setPlainTextBody(emailBody);
                    
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                }
            }
            
        } catch (Exception e) {
            System.debug('Failed to send error notification: ' + e.getMessage());
        }
    }
    
    /**
     * @description Static method to schedule the daily job
     * @param cronExpression Cron expression for scheduling (e.g., '0 0 8 * * ?' for 8 AM daily)
     * @return String Job ID
     */
    public static String scheduleDaily(String cronExpression) {
        try {
            DailyAtRiskStudentNotifier scheduler = new DailyAtRiskStudentNotifier();
            String jobId = System.schedule('Daily At-Risk Student Notifier', cronExpression, scheduler);
            System.debug('Scheduled DailyAtRiskStudentNotifier with Job ID: ' + jobId);
            return jobId;
        } catch (Exception e) {
            System.debug('Error scheduling DailyAtRiskStudentNotifier: ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * @description Convenience method to schedule for 8 AM daily
     * @return String Job ID
     */
    public static String scheduleDailyAt8AM() {
        return scheduleDaily('0 0 8 * * ?');
    }
}