@IsTest
private class EventControllerTest {

    @TestSetup
    static void setup() {
        // Create student
        insert new Student__c(Name='Enroll Student', Roll_No__c='ENR001', Status__c='Regular', Attendance_Percentage__c=80, Student_Email__c='enroll@test.com');
        // Create events
        Date today = Date.today();
        insert new List<Event__c>{
            new Event__c(Name='Upcoming Scheduled', Status__c='Scheduled', Date__c=today.addDays(2), End_Date__c=DateTime.now().addDays(2).addHours(1), Location__c='Hall A'),
            new Event__c(Name='Past Completed', Status__c='Completed', Date__c=today.addDays(-3), End_Date__c=DateTime.now().addDays(-3).addHours(1), Location__c='Hall B')
        };
    }

    @IsTest
    static void testSearchEvents() {
        Date startDate = Date.today();
        Date endDate = Date.today().addDays(7);
        Test.startTest();
        List<Event__c> events = EventController.searchEvents(startDate, endDate);
        Test.stopTest();
        System.assertEquals(true, events.size() >= 1, 'Should return at least one upcoming event');
        for (Event__c e : events) {
            System.assert(e.Date__c >= startDate && e.Date__c <= endDate, 'Event date should be within range');
        }
    }

    @IsTest
    static void testGetScheduledEventsWithin7Days() {
        Test.startTest();
        List<Event__c> events = EventController.getScheduledEventsWithin7Days();
        Test.stopTest();
        for (Event__c e : events) {
            System.assertEquals('Scheduled', e.Status__c, 'Only scheduled events expected');
        }
    }

    @IsTest
    static void testEnrollStudentInEvent() {
        Student__c s = [SELECT Id FROM Student__c WHERE Roll_No__c='ENR001' LIMIT 1];
        Event__c e = [SELECT Id FROM Event__c WHERE Status__c='Scheduled' ORDER BY Date__c ASC LIMIT 1];
        Test.startTest();
        Id attId = EventController.enrollStudentInEvent(e.Id, s.Id);
        Test.stopTest();
        Attendance__c att = [SELECT Id, Student__c, Date__c FROM Attendance__c WHERE Id=:attId LIMIT 1];
        System.assertEquals(s.Id, att.Student__c, 'Attendance should be for the selected student');
    }
}
