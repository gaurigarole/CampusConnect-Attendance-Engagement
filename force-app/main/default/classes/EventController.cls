public with sharing class EventController {

    @AuraEnabled(cacheable=true)
    public static List<Event__c> searchEvents(Date startDate, Date endDate) {
        if (startDate == null || endDate == null) {
            return new List<Event__c>();
        }
        if (endDate < startDate) {
            return new List<Event__c>();
        }
        return [
            SELECT Id, Name, Status__c, Date__c, End_Date__c, Location__c, Description__c
            FROM Event__c
            WHERE Date__c >= :startDate AND Date__c <= :endDate
            ORDER BY Date__c ASC, Name ASC
            LIMIT 200
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Event__c> getScheduledEventsWithin7Days() {
        Date today = Date.today();
        Date in7 = today.addDays(7);
        return [
            SELECT Id, Name, Status__c, Date__c, End_Date__c, Location__c
            FROM Event__c
            WHERE Status__c = 'Scheduled' AND Date__c >= :today AND Date__c <= :in7
            ORDER BY Date__c ASC, Name ASC
            LIMIT 50
        ];
    }

    @AuraEnabled
    public static Id enrollStudentInEvent(Id eventId, Id studentId) {
        if (eventId == null || studentId == null) {
            throw new AuraHandledException('Event and Student are required');
        }
        Event__c ev = [SELECT Id, Date__c FROM Event__c WHERE Id = :eventId LIMIT 1];
        // Create an Attendance record as proof of enrollment
        Attendance__c att = new Attendance__c();
        att.Name = 'ATT-' + String.valueOf(System.currentTimeMillis());
        att.Student__c = studentId;
        att.Date__c = ev.Date__c;
        att.Status__c = 'Present';
        insert att;
        return att.Id;
    }
}
