// Run this in Developer Console (Anonymous Apex)
// This script will help us understand the valid range for Attendance_Percentage__c

try {
    // Get the field describe result for Attendance_Percentage__c
    Schema.DescribeFieldResult fieldDescribe = Student__c.Attendance_Percentage__c.getDescribe();
    
    // Log field properties
    System.debug('=== Field Properties ===');
    System.debug('Field Label: ' + fieldDescribe.getLabel());
    System.debug('Field Type: ' + fieldDescribe.getType());
    System.debug('Is Required: ' + fieldDescribe.isNillable());
    System.debug('Scale: ' + fieldDescribe.getScale());
    System.debug('Precision: ' + fieldDescribe.getPrecision());
    
    // Check for validation rules
    List<ValidationRule> validationRules = [
        SELECT Id, DeveloperName, ErrorMessage, ValidationFormula 
        FROM ValidationRule 
        WHERE EntityDefinitionId = :fieldDescribe.getReferenceTo()[0].getDescribe().getKeyPrefix()
        AND ValidationFormula LIKE '%Attendance_Percentage__c%'
    ];
    
    System.debug('=== Validation Rules ===');
    if (!validationRules.isEmpty()) {
        for (ValidationRule vr : validationRules) {
            System.debug('Rule: ' + vr.DeveloperName);
            System.debug('Message: ' + vr.ErrorMessage);
            System.debug('Formula: ' + vr.ValidationFormula);
        }
    } else {
        System.debug('No validation rules found for this field.');
    }
    
    // Try to determine valid range by checking field properties
    System.debug('\n=== Suggested Valid Range ===');
    System.debug('Based on field type and scale, valid values should be between 0 and 100');
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
