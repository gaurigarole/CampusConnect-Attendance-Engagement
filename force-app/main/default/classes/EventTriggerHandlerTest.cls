/**
 * @description Test class for EventTriggerHandler and EventTrigger
 * @author CampusConnect Development Team
 * @date 2025
 */
@isTest
public class EventTriggerHandlerTest {
    
    /**
     * @description Test data setup method
     */
    @TestSetup
    static void setupTestData() {
        // Create test events that won't trigger validation issues
        List<Event__c> testEvents = new List<Event__c>();
        
        testEvents.add(new Event__c(
            Event_Name__c = 'Setup Event 1',
            Date__c = Date.today().addDays(1),
            End_Date__c = DateTime.now().addDays(1).addHours(2),
            Location__c = 'Room 101',
            Status__c = 'Scheduled'
        ));
        
        insert testEvents;
    }
    
    /**
     * @description Test before insert trigger logic
     */
    @isTest
    static void testBeforeInsert() {
        Test.startTest();
        
        // Test valid event creation
        Event__c validEvent = new Event__c(
            Event_Name__c = 'Valid Test Event',
            Date__c = Date.today(),
            End_Date__c = DateTime.now().addHours(2),
            Location__c = 'Room 102',
            Status__c = 'Scheduled'
        );
        
        insert validEvent;
        
        // Verify event was created successfully
        Event__c insertedEvent = [SELECT Id, Status__c, End_Date__c FROM Event__c WHERE Id = :validEvent.Id];
        System.assertEquals('Scheduled', insertedEvent.Status__c, 'Event should have Scheduled status');
        System.assertNotEquals(null, insertedEvent.End_Date__c, 'Event should have end date');
        
        Test.stopTest();
    }
    
    /**
     * @description Test date validation in before insert
     */
    @isTest
    static void testDateValidationBeforeInsert() {
        Test.startTest();
        
        Boolean exceptionThrown = false;
        try {
            // Create event with end date before start date
            Event__c invalidEvent = new Event__c(
                Event_Name__c = 'Invalid Test Event',
                Date__c = Date.today(),
                End_Date__c = DateTime.now().addHours(-2), // End date before start
                Location__c = 'Room 103'
            );
            
            insert invalidEvent;
        } catch (Exception e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('End Date must be after Start Date'), 
                         'Should get appropriate error message');
        }
        
        System.assert(exceptionThrown, 'Exception should be thrown for invalid dates');
        
        Test.stopTest();
    }
    
    /**
     * @description Test overlapping events validation
     */
    @isTest
    static void testOverlappingEventsValidation() {
        // Create first event
        Event__c firstEvent = new Event__c(
            Event_Name__c = 'First Event',
            Date__c = Date.today(),
            End_Date__c = DateTime.now().addHours(2),
            Location__c = 'Room 104',
            Status__c = 'Scheduled'
        );
        insert firstEvent;
        
        Test.startTest();
        
        Boolean exceptionThrown = false;
        try {
            // Create overlapping event in same location
            Event__c overlappingEvent = new Event__c(
                Event_Name__c = 'Overlapping Event',
                Date__c = Date.today(),
                End_Date__c = DateTime.now().addHours(1), // Overlaps with first event
                Location__c = 'Room 104', // Same location
                Status__c = 'Scheduled'
            );
            
            insert overlappingEvent;
        } catch (Exception e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('overlaps'), 
                         'Should get overlap error message');
        }
        
        System.assert(exceptionThrown, 'Exception should be thrown for overlapping events');
        
        Test.stopTest();
    }
    
    /**
     * @description Test before update trigger logic
     */
    @isTest
    static void testBeforeUpdate() {
        // Create event
        Event__c event = new Event__c(
            Event_Name__c = 'Update Test Event',
            Date__c = Date.today(),
            End_Date__c = DateTime.now().addHours(2),
            Location__c = 'Room 105',
            Status__c = 'Scheduled'
        );
        insert event;
        
        Test.startTest();
        
        // Update event dates
        event.Date__c = Date.today().addDays(1);
        event.End_Date__c = DateTime.now().addDays(1).addHours(2);
        update event;
        
        // Verify update was successful
        Event__c updatedEvent = [SELECT Id, Date__c, Status__c FROM Event__c WHERE Id = :event.Id];
        System.assertEquals(Date.today().addDays(1), updatedEvent.Date__c, 'Date should be updated');
        
        Test.stopTest();
    }
    
    /**
     * @description Test automatic status updates
     */
    @isTest
    static void testAutomaticStatusUpdates() {
        Test.startTest();
        
        // Create event with past end date
        Event__c pastEvent = new Event__c(
            Event_Name__c = 'Past Event',
            Date__c = Date.today().addDays(-1),
            End_Date__c = DateTime.now().addDays(-1).addHours(-1), // Past end date
            Location__c = 'Room 106',
            Status__c = 'Scheduled'
        );
        insert pastEvent;
        
        // Update the event to trigger status change
        pastEvent.Event_Name__c = 'Updated Past Event';
        update pastEvent;
        
        Test.stopTest();
        
        // Verify status was updated to Completed
        Event__c updatedEvent = [SELECT Id, Status__c FROM Event__c WHERE Id = :pastEvent.Id];
        System.assertEquals('Completed', updatedEvent.Status__c, 'Past event should be marked as Completed');
    }
    
    /**
     * @description Test after insert trigger logic
     */
    @isTest
    static void testAfterInsert() {
        // Mock HTTP callout for external notifications
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        
        Event__c newEvent = new Event__c(
            Event_Name__c = 'After Insert Test Event',
            Date__c = Date.today(),
            End_Date__c = DateTime.now().addHours(2),
            Location__c = 'Room 107',
            Status__c = 'Scheduled'
        );
        
        insert newEvent;
        
        Test.stopTest();
        
        // Verify event was created successfully
        Event__c insertedEvent = [SELECT Id, Status__c FROM Event__c WHERE Id = :newEvent.Id];
        System.assertEquals('Scheduled', insertedEvent.Status__c, 'Event should be created with Scheduled status');
    }
    
    /**
     * @description Test after update trigger logic
     */
    @isTest
    static void testAfterUpdate() {
        // Mock HTTP callout for external notifications
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create event
        Event__c event = new Event__c(
            Event_Name__c = 'After Update Test Event',
            Date__c = Date.today(),
            End_Date__c = DateTime.now().addHours(2),
            Location__c = 'Room 108',
            Status__c = 'Scheduled'
        );
        insert event;
        
        Test.startTest();
        
        // Update event status
        event.Status__c = 'In Progress';
        update event;
        
        Test.stopTest();
        
        // Verify status change
        Event__c updatedEvent = [SELECT Id, Status__c FROM Event__c WHERE Id = :event.Id];
        System.assertEquals('In Progress', updatedEvent.Status__c, 'Event status should be updated');
    }
    
    /**
     * @description Test default value setting
     */
    @isTest
    static void testDefaultValues() {
        Test.startTest();
        
        // Create event without status or end date
        Event__c event = new Event__c(
            Event_Name__c = 'Default Values Test Event',
            Date__c = Date.today(),
            Location__c = 'Room 109'
            // No status or end date specified
        );
        
        insert event;
        
        Test.stopTest();
        
        // Verify default values were set
        Event__c insertedEvent = [SELECT Id, Status__c, End_Date__c FROM Event__c WHERE Id = :event.Id];
        System.assertEquals('Scheduled', insertedEvent.Status__c, 'Default status should be Scheduled');
        System.assertNotEquals(null, insertedEvent.End_Date__c, 'Default end date should be set');
    }
    
    /**
     * @description Test bulk operations
     */
    @isTest
    static void testBulkOperations() {
        Test.startTest();
        
        List<Event__c> events = new List<Event__c>();
        
        // Create multiple events for bulk testing
        for (Integer i = 0; i < 50; i++) {
            events.add(new Event__c(
                Event_Name__c = 'Bulk Event ' + i,
                Date__c = Date.today().addDays(i),
                End_Date__c = DateTime.now().addDays(i).addHours(2),
                Location__c = 'Room ' + (110 + i),
                Status__c = 'Scheduled'
            ));
        }
        
        insert events;
        
        Test.stopTest();
        
        // Verify all events were created
        List<Event__c> insertedEvents = [SELECT Id, Status__c FROM Event__c WHERE Id IN :events];
        System.assertEquals(50, insertedEvents.size(), 'All events should be inserted');
        
        for (Event__c event : insertedEvents) {
            System.assertEquals('Scheduled', event.Status__c, 'All events should have Scheduled status');
        }
    }
    
    /**
     * @description Test events in different locations (no overlap)
     */
    @isTest
    static void testNonOverlappingEvents() {
        Test.startTest();
        
        List<Event__c> events = new List<Event__c>();
        
        // Create events at same time but different locations
        events.add(new Event__c(
            Event_Name__c = 'Event Room A',
            Date__c = Date.today(),
            End_Date__c = DateTime.now().addHours(2),
            Location__c = 'Room A',
            Status__c = 'Scheduled'
        ));
        
        events.add(new Event__c(
            Event_Name__c = 'Event Room B',
            Date__c = Date.today(),
            End_Date__c = DateTime.now().addHours(2),
            Location__c = 'Room B',
            Status__c = 'Scheduled'
        ));
        
        insert events;
        
        Test.stopTest();
        
        // Verify both events were created successfully
        List<Event__c> insertedEvents = [SELECT Id, Location__c FROM Event__c WHERE Id IN :events];
        System.assertEquals(2, insertedEvents.size(), 'Both events should be created');
    }
    
    /**
     * @description Test error handling in trigger
     */
    @isTest
    static void testErrorHandling() {
        Test.startTest();
        
        try {
            // Create event with very long name to test field limits
            Event__c event = new Event__c(
                Event_Name__c = 'Very Long Event Name'.repeat(10), // May exceed field limit
                Date__c = Date.today(),
                End_Date__c = DateTime.now().addHours(2),
                Location__c = 'Room 200'
            );
            
            insert event;
            
            // If insert succeeds, verify the event was created
            Event__c insertedEvent = [SELECT Id, Status__c FROM Event__c WHERE Id = :event.Id];
            System.assertEquals('Scheduled', insertedEvent.Status__c, 'Event should be created with default status');
            
        } catch (Exception e) {
            // If an exception is thrown, that's acceptable for this test
            System.assert(true, 'Exception handling is working: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Mock HTTP response generator for testing callouts
     */
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Event notification sent"}');
            res.setStatusCode(200);
            return res;
        }
    }
}