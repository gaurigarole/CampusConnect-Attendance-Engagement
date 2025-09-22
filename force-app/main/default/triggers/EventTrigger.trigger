/**
 * @description Trigger for Event__c object
 * @author CampusConnect Development Team
 * @date 2025
 */
trigger EventTrigger on Event__c (before insert, before update, after insert, after update) {
    
    // Determine trigger context and call appropriate handler method
    if (Trigger.isBefore && Trigger.isInsert) {
        EventTriggerHandler.handleTrigger(Trigger.new, null, 'BEFORE_INSERT');
    }
    else if (Trigger.isBefore && Trigger.isUpdate) {
        EventTriggerHandler.handleTrigger(Trigger.new, Trigger.old, 'BEFORE_UPDATE');
    }
    else if (Trigger.isAfter && Trigger.isInsert) {
        EventTriggerHandler.handleTrigger(Trigger.new, null, 'AFTER_INSERT');
    }
    else if (Trigger.isAfter && Trigger.isUpdate) {
        EventTriggerHandler.handleTrigger(Trigger.new, Trigger.old, 'AFTER_UPDATE');
    }
}