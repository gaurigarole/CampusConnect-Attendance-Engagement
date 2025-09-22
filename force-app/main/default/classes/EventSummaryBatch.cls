/**
 * @description Batch class to send daily event summary to administrators
 * @author CampusConnect Development Team
 * @date 2025
 */
public class EventSummaryBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    // Track events for summary
    public List<Event__c> todaysEvents = new List<Event__c>();
    public List<Event__c> upcomingEvents = new List<Event__c>();
    public Integer totalEventsProcessed = 0;
    
    /**
     * @description Start method - defines the scope of records to process
     * @param bc BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('EventSummaryBatch started at: ' + DateTime.now());
        
        Date today = Date.today();
        Date tomorrow = today.addDays(1);
        
        // Query today's and tomorrow's events
        return Database.getQueryLocator([
            SELECT Id, Event_Name__c, Date__c, End_Date__c, Location__c, Status__c, 
                   Organizer__c, Description__c, Participants__c
            FROM Event__c 
            WHERE Date__c >= :today AND Date__c <= :tomorrow
            ORDER BY Date__c ASC, End_Date__c ASC
        ]);
    }
    
    /**
     * @description Execute method - processes each batch of records
     * @param bc BatchableContext
     * @param scope List of Event records to process
     */
    public void execute(Database.BatchableContext bc, List<Event__c> scope) {
        Date today = Date.today();
        
        for (Event__c event : scope) {
            totalEventsProcessed++;
            
            if (event.Date__c == today) {
                todaysEvents.add(event);
            } else {
                upcomingEvents.add(event);
            }
        }
    }
    
    /**
     * @description Finish method - sends the event summary email
     * @param bc BatchableContext
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('EventSummaryBatch completed at: ' + DateTime.now());
        System.debug('Total events processed: ' + totalEventsProcessed);
        System.debug('Today\'s events: ' + todaysEvents.size());
        System.debug('Upcoming events: ' + upcomingEvents.size());
        
        // Send summary email
        sendEventSummaryEmail();
    }
    
    /**
     * @description Sends event summary email to administrators
     */
    private void sendEventSummaryEmail() {
        try {
            // Get admin users
            List<User> admins = [
                SELECT Id, Email, Name 
                FROM User 
                WHERE Profile.Name = 'System Administrator' 
                AND IsActive = true 
                LIMIT 10
            ];
            
            if (!admins.isEmpty()) {
                List<String> toAddresses = new List<String>();
                for (User admin : admins) {
                    if (String.isNotBlank(admin.Email)) {
                        toAddresses.add(admin.Email);
                    }
                }
                
                if (!toAddresses.isEmpty()) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(toAddresses);
                    email.setSubject('CampusConnect: Daily Event Summary - ' + Date.today().format());
                    
                    String emailBody = buildEventSummaryEmailBody();
                    email.setHtmlBody(emailBody);
                    
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                    System.debug('Event summary email sent to ' + toAddresses.size() + ' administrators');
                }
            }
            
        } catch (Exception e) {
            System.debug('Error sending event summary email: ' + e.getMessage());
        }
    }
    
    /**
     * @description Builds the HTML email body for event summary
     * @return String HTML email content
     */
    private String buildEventSummaryEmailBody() {
        String emailBody = '<html><body>';
        emailBody += '<h2>CampusConnect Daily Event Summary</h2>';
        emailBody += '<p><strong>Date:</strong> ' + Date.today().format() + '</p>';
        
        // Today's Events Section
        emailBody += '<h3>Today\'s Events (' + todaysEvents.size() + ')</h3>';
        if (todaysEvents.isEmpty()) {
            emailBody += '<p><em>No events scheduled for today.</em></p>';
        } else {
            emailBody += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">';
            emailBody += '<tr style="background-color: #f0f0f0;">';
            emailBody += '<th>Event Name</th><th>Time</th><th>Location</th><th>Status</th><th>Organizer</th>';
            emailBody += '</tr>';
            
            for (Event__c event : todaysEvents) {
                emailBody += '<tr>';
                emailBody += '<td>' + (event.Event_Name__c != null ? event.Event_Name__c : 'N/A') + '</td>';
                emailBody += '<td>' + (event.End_Date__c != null ? event.End_Date__c.format('HH:mm') : 'N/A') + '</td>';
                emailBody += '<td>' + (event.Location__c != null ? event.Location__c : 'N/A') + '</td>';
                emailBody += '<td>' + (event.Status__c != null ? event.Status__c : 'N/A') + '</td>';
                emailBody += '<td>' + (event.Organizer__c != null ? event.Organizer__c : 'N/A') + '</td>';
                emailBody += '</tr>';
            }
            emailBody += '</table>';
        }
        
        // Tomorrow's Events Section
        emailBody += '<h3>Tomorrow\'s Events (' + upcomingEvents.size() + ')</h3>';
        if (upcomingEvents.isEmpty()) {
            emailBody += '<p><em>No events scheduled for tomorrow.</em></p>';
        } else {
            emailBody += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">';
            emailBody += '<tr style="background-color: #f0f0f0;">';
            emailBody += '<th>Event Name</th><th>Time</th><th>Location</th><th>Status</th><th>Organizer</th>';
            emailBody += '</tr>';
            
            for (Event__c event : upcomingEvents) {
                emailBody += '<tr>';
                emailBody += '<td>' + (event.Event_Name__c != null ? event.Event_Name__c : 'N/A') + '</td>';
                emailBody += '<td>' + (event.End_Date__c != null ? event.End_Date__c.format('HH:mm') : 'N/A') + '</td>';
                emailBody += '<td>' + (event.Location__c != null ? event.Location__c : 'N/A') + '</td>';
                emailBody += '<td>' + (event.Status__c != null ? event.Status__c : 'N/A') + '</td>';
                emailBody += '<td>' + (event.Organizer__c != null ? event.Organizer__c : 'N/A') + '</td>';
                emailBody += '</tr>';
            }
            emailBody += '</table>';
        }
        
        emailBody += '<br><p><em>This is an automated message from CampusConnect Event Management System.</em></p>';
        emailBody += '</body></html>';
        
        return emailBody;
    }
}