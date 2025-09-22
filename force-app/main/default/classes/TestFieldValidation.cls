@isTest
public with sharing class TestFieldValidation {
    @isTest
    static void testAttendancePercentageRange() {
        // This test will help us identify the valid range for Attendance_Percentage__c
        Test.startTest();
        
        // Test different values to find the valid range
        List<Decimal> testValues = new List<Decimal>{
            0, 1, 10, 25, 50, 75, 99, 100, // Standard values
            0.1, 99.9, 0.5, 99.5, // Decimal values
            0.01, 99.99, // More precise decimals
            -1, 101, // Out of range values
            0.0, 100.0 // Edge cases
        };
        
        // Create a student with each test value
        List<Student__c> testStudents = new List<Student__c>();
        Integer i = 0;
        
        for (Decimal val : testValues) {
            try {
                Student__c s = new Student__c(
                    Name = 'Range Test ' + i,
                    Roll_No__c = 'RNG' + String.valueOf(i).leftPad(3, '0'),
                    Student_Email__c = 'range' + i + '@test.com',
                    Attendance_Percentage__c = val
                );
                
                // Try to insert the record
                insert s;
                
                // If we get here, the value is valid
                System.debug('VALID: ' + val);
                testStudents.add(s);
                
            } catch (Exception e) {
                // If we get here, the value is invalid
                System.debug('INVALID: ' + val + ' - ' + e.getMessage());
            }
            
            i++;
        }
        
        // Clean up any successfully created records
        if (!testStudents.isEmpty()) {
            delete testStudents;
        }
        
        Test.stopTest();
    }
}
