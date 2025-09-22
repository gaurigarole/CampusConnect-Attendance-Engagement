/**
 * @description Trigger handler for Event__c object
 * @author CampusConnect Development Team
 * @date 2025
 */
public with sharing class EventTriggerHandler {
    
    /**
     * @description Main entry point for Event trigger
     * @param newEvents List of new Event records
     * @param oldEvents List of old Event records
     * @param triggerEvent Type of trigger event
     */
    public static void handleTrigger(List<Event__c> newEvents, List<Event__c> oldEvents, String triggerEvent) {
        
        try {
            switch on triggerEvent {
                when 'BEFORE_INSERT' {
                    handleBeforeInsert(newEvents);
                }
                when 'BEFORE_UPDATE' {
                    handleBeforeUpdate(newEvents, oldEvents);
                }
                when 'AFTER_INSERT' {
                    handleAfterInsert(newEvents);
                }
                when 'AFTER_UPDATE' {
                    handleAfterUpdate(newEvents, oldEvents);
                }
            }
        } catch (Exception e) {
            System.debug('Error in EventTriggerHandler: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Handles before insert logic
     * @param newEvents List of new Event records
     */
    private static void handleBeforeInsert(List<Event__c> newEvents) {
        // Validate event dates
        StudentService.validateEventDates(newEvents);
        
        // Set default values
        setDefaultValues(newEvents);
        
        // Check for overlapping events
        checkForOverlappingEvents(newEvents);
    }
    
    /**
     * @description Handles before update logic
     * @param newEvents List of new Event records
     * @param oldEvents List of old Event records
     */
    private static void handleBeforeUpdate(List<Event__c> newEvents, List<Event__c> oldEvents) {
        Map<Id, Event__c> oldEventMap = new Map<Id, Event__c>(oldEvents);
        List<Event__c> eventsWithDateChanges = new List<Event__c>();
        
        // Check which events had date changes
        for (Event__c newEvent : newEvents) {
            Event__c oldEvent = oldEventMap.get(newEvent.Id);
            
            if (newEvent.Date__c != oldEvent.Date__c || newEvent.End_Date__c != oldEvent.End_Date__c) {
                eventsWithDateChanges.add(newEvent);
            }
        }
        
        // Validate dates for events with changes
        if (!eventsWithDateChanges.isEmpty()) {
            StudentService.validateEventDates(eventsWithDateChanges);
            checkForOverlappingEvents(eventsWithDateChanges);
        }
        
        // Auto-update status for completed events
        updateEventStatus(newEvents);
    }
    
    /**
     * @description Handles after insert logic
     * @param newEvents List of new Event records
     */
    private static void handleAfterInsert(List<Event__c> newEvents) {
        // Send notifications for new events
        sendEventNotifications(newEvents, 'NEW_EVENT');
    }
    
    /**
     * @description Handles after update logic
     * @param newEvents List of new Event records
     * @param oldEvents List of old Event records
     */
    private static void handleAfterUpdate(List<Event__c> newEvents, List<Event__c> oldEvents) {
        Map<Id, Event__c> oldEventMap = new Map<Id, Event__c>(oldEvents);
        List<Event__c> eventsWithStatusChange = new List<Event__c>();
        
        // Check which events had status changes
        for (Event__c newEvent : newEvents) {
            Event__c oldEvent = oldEventMap.get(newEvent.Id);
            
            if (newEvent.Status__c != oldEvent.Status__c) {
                eventsWithStatusChange.add(newEvent);
            }
        }
        
        // Send notifications for status changes
        if (!eventsWithStatusChange.isEmpty()) {
            sendEventNotifications(eventsWithStatusChange, 'STATUS_CHANGE');
        }
    }
    
    /**
     * @description Sets default values for new event records
     * @param events List of Event records
     */
    private static void setDefaultValues(List<Event__c> events) {
        for (Event__c event : events) {
            // Set default status if not provided
            if (String.isBlank(event.Status__c)) {
                event.Status__c = 'Scheduled';
            }
            
            // Set default end date if not provided (1 hour after start)
            if (event.End_Date__c == null && event.Date__c != null) {
                DateTime startDateTime = DateTime.newInstance(event.Date__c, Time.newInstance(9, 0, 0, 0));
                event.End_Date__c = startDateTime.addHours(1);
            }
        }
    }
    
    /**
     * @description Updates event status based on dates
     * @param events List of Event records to check
     */
    private static void updateEventStatus(List<Event__c> events) {
        DateTime now = DateTime.now();
        
        for (Event__c event : events) {
            if (event.End_Date__c != null && event.End_Date__c < now && event.Status__c != 'Completed') {
                event.Status__c = 'Completed';
            } else if (event.Date__c != null && event.End_Date__c != null) {
                DateTime startDateTime = DateTime.newInstance(event.Date__c, Time.newInstance(0, 0, 0, 0));
                if (startDateTime <= now && event.End_Date__c >= now && event.Status__c == 'Scheduled') {
                    event.Status__c = 'In Progress';
                }
            }
        }
    }
    
    /**
     * @description Checks for overlapping events in the same location
     * @param events List of Event records to check
     */
    private static void checkForOverlappingEvents(List<Event__c> events) {
        Set<String> locations = new Set<String>();
        Map<String, List<Event__c>> eventsByLocation = new Map<String, List<Event__c>>();
        
        // Group events by location
        for (Event__c event : events) {
            if (String.isNotBlank(event.Location__c)) {
                locations.add(event.Location__c);
                
                if (!eventsByLocation.containsKey(event.Location__c)) {
                    eventsByLocation.put(event.Location__c, new List<Event__c>());
                }
                eventsByLocation.get(event.Location__c).add(event);
            }
        }
        
        if (!locations.isEmpty()) {
            // Query existing events in the same locations
            List<Event__c> existingEvents = [
                SELECT Id, Location__c, Date__c, End_Date__c, Event_Name__c
                FROM Event__c 
                WHERE Location__c IN :locations
                AND Status__c IN ('Scheduled', 'In Progress')
                LIMIT 1000
            ];
            
            // Check for overlaps
            for (Event__c newEvent : events) {
                if (String.isNotBlank(newEvent.Location__c) && newEvent.Date__c != null && newEvent.End_Date__c != null) {
                    DateTime newStart = DateTime.newInstance(newEvent.Date__c, Time.newInstance(0, 0, 0, 0));
                    DateTime newEnd = newEvent.End_Date__c;
                    
                    for (Event__c existingEvent : existingEvents) {
                        if (existingEvent.Location__c == newEvent.Location__c && 
                            existingEvent.Id != newEvent.Id &&
                            existingEvent.Date__c != null && existingEvent.End_Date__c != null) {
                            
                            DateTime existingStart = DateTime.newInstance(existingEvent.Date__c, Time.newInstance(0, 0, 0, 0));
                            DateTime existingEnd = existingEvent.End_Date__c;
                            
                            // Check for overlap
                            if ((newStart < existingEnd && newEnd > existingStart)) {
                                throw new StudentService.StudentServiceException(
                                    'Event overlaps with existing event "' + existingEvent.Event_Name__c + 
                                    '" in location: ' + newEvent.Location__c
                                );
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     * @description Sends notifications for event changes
     * @param events List of Event records
     * @param notificationType Type of notification
     */
    private static void sendEventNotifications(List<Event__c> events, String notificationType) {
        Set<Id> eventIds = new Set<Id>();
        
        for (Event__c event : events) {
            eventIds.add(event.Id);
        }
        
        // Send notifications asynchronously
        if (!eventIds.isEmpty()) {
            StudentService.sendExternalNotification(eventIds, notificationType);
        }
    }
}