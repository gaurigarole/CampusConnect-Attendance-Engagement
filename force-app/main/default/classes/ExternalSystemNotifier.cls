public with sharing class ExternalSystemNotifier {
    
    @future(callout=true)
    public static void notifyExternalSystem(String eventType, String recordId, String changeData) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:StudentVerificationAPI/notifications');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            
            Map<String, Object> notification = new Map<String, Object>{
                'eventType' => eventType,
                'recordId' => recordId,
                'changeData' => changeData,
                'timestamp' => System.now().getTime(),
                'source' => 'CampusConnect'
            };
            
            req.setBody(JSON.serialize(notification));
            
            Long startTime = System.currentTimeMillis();
            Http http = new Http();
            HttpResponse res = http.send(req);
            Long responseTime = System.currentTimeMillis() - startTime;
            
            // Log the API call
            APIMonitoringService.logAPICall('ExternalNotification', 
                                          'callout:StudentVerificationAPI/notifications', 
                                          res.getStatusCode(), 
                                          responseTime);
            
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                System.debug('Successfully notified external system: ' + eventType + ' for ' + recordId);
            } else {
                System.debug('External notification failed: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
            
        } catch (Exception e) {
            System.debug('Error notifying external system: ' + e.getMessage());
        }
    }
    
    // Method to handle Change Data Capture events
    public static void handleStudentChange(List<Student__ChangeEvent> changes) {
        for (Student__ChangeEvent change : changes) {
            String changeType = change.ChangeEventHeader.changeType;
            String recordId = change.ChangeEventHeader.recordIds[0];
            
            Map<String, Object> changeData = new Map<String, Object>{
                'changeType' => changeType,
                'changedFields' => change.ChangeEventHeader.changedFields,
                'studentNumber' => change.Student_Number__c,
                'email' => change.Email__c,
                'status' => change.Status__c
            };
            
            notifyExternalSystem('StudentChange', recordId, JSON.serialize(changeData));
        }
    }
    
    // Method to handle Event changes
    public static void handleEventChange(List<Event__ChangeEvent> changes) {
        for (Event__ChangeEvent change : changes) {
            String changeType = change.ChangeEventHeader.changeType;
            String recordId = change.ChangeEventHeader.recordIds[0];
            
            Map<String, Object> changeData = new Map<String, Object>{
                'changeType' => changeType,
                'changedFields' => change.ChangeEventHeader.changedFields,
                'eventName' => change.Name,
                'eventDate' => change.Event_Date__c,
                'eventType' => change.Event_Type__c
            };
            
            notifyExternalSystem('EventChange', recordId, JSON.serialize(changeData));
        }
    }
}
