/**
 * @description Trigger for Student__c object
 * @author CampusConnect Development Team
 * @date 2025
 */
trigger StudentTrigger on Student__c (before insert, before update, after insert, after update) {
    
    // Determine trigger context and call appropriate handler method
    if (Trigger.isBefore && Trigger.isInsert) {
        StudentTriggerHandler.handleTrigger(Trigger.new, null, 'BEFORE_INSERT');
    }
    else if (Trigger.isBefore && Trigger.isUpdate) {
        StudentTriggerHandler.handleTrigger(Trigger.new, Trigger.old, 'BEFORE_UPDATE');
    }
    else if (Trigger.isAfter && Trigger.isInsert) {
        StudentTriggerHandler.handleTrigger(Trigger.new, null, 'AFTER_INSERT');
    }
    else if (Trigger.isAfter && Trigger.isUpdate) {
        StudentTriggerHandler.handleTrigger(Trigger.new, Trigger.old, 'AFTER_UPDATE');
    }
}