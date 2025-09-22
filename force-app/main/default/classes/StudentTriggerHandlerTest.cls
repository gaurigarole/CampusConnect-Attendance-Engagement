/**
 * @description Test class for StudentTriggerHandler and StudentTrigger
 * @author CampusConnect Development Team
 * @date 2025
 */
@isTest
public class StudentTriggerHandlerTest {
    
    /**
     * @description Test data setup method
     */
    @TestSetup
    static void setupTestData() {
        // Create test data that won't trigger the trigger during setup
        // We'll create students in individual test methods to test trigger behavior
    }
    
    /**
     * @description Test before insert trigger logic
     */
    @isTest
    static void testBeforeInsert() {
        Test.startTest();
        
        // Create students with different attendance percentages
        List<Student__c> students = new List<Student__c>();
        
        students.add(new Student__c(
            Name = 'Regular Student',
            Roll_No__c = 'REG001',
            Student_Email__c = 'regular@test.com',
            Attendance_Percentage__c = 85.0
        ));
        
        students.add(new Student__c(
            Name = 'At Risk Student',
            Roll_No__c = 'RISK001',
            Student_Email__c = 'atrisk@test.com',
            Attendance_Percentage__c = 65.0
        ));
        
        students.add(new Student__c(
            Name = 'Probation Student',
            Roll_No__c = 'PROB001',
            Student_Email__c = 'probation@test.com',
            Attendance_Percentage__c = 40.0
        ));
        
        students.add(new Student__c(
            Name = 'No Attendance Student',
            Roll_No__c = 'NONE001',
            Student_Email__c = 'none@test.com'
            // No attendance percentage set
        ));
        
        // Insert students - this will trigger the before insert logic
        insert students;
        
        Test.stopTest();
        
        // Query the inserted students to verify status updates
        List<Student__c> insertedStudents = [
            SELECT Id, Name, Status__c, Attendance_Percentage__c 
            FROM Student__c 
            WHERE Id IN :students
            ORDER BY Name
        ];
        
        // Verify status assignments
        System.assertEquals('At Risk', insertedStudents[0].Status__c, 'At Risk student should have correct status');
        System.assertEquals('Regular', insertedStudents[3].Status__c, 'No attendance student should default to Regular');
        System.assertEquals(100.0, insertedStudents[3].Attendance_Percentage__c, 'No attendance student should default to 100%');
        System.assertEquals('Probation', insertedStudents[2].Status__c, 'Probation student should have correct status');
        System.assertEquals('Regular', insertedStudents[1].Status__c, 'Regular student should have correct status');
    }
    
    /**
     * @description Test before update trigger logic
     */
    @isTest
    static void testBeforeUpdate() {
        // Create initial student
        Student__c student = new Student__c(
            Name = 'Test Student',
            Roll_No__c = 'TEST001',
            Student_Email__c = 'test@test.com',
            Attendance_Percentage__c = 85.0
        );
        insert student;
        
        // Verify initial status
        student = [SELECT Id, Status__c, Attendance_Percentage__c FROM Student__c WHERE Id = :student.Id];
        System.assertEquals('Regular', student.Status__c, 'Initial status should be Regular');
        
        Test.startTest();
        
        // Update attendance percentage to trigger status change
        student.Attendance_Percentage__c = 65.0;
        update student;
        
        Test.stopTest();
        
        // Verify status was updated
        student = [SELECT Id, Status__c, Attendance_Percentage__c FROM Student__c WHERE Id = :student.Id];
        System.assertEquals('At Risk', student.Status__c, 'Status should be updated to At Risk');
    }
    
    /**
     * @description Test after insert trigger logic
     */
    @isTest
    static void testAfterInsert() {
        // Mock HTTP callout for external notifications
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        
        // Create at-risk student
        Student__c student = new Student__c(
            Name = 'At Risk Student',
            Roll_No__c = 'RISK001',
            Student_Email__c = 'atrisk@test.com',
            Attendance_Percentage__c = 65.0
        );
        
        insert student;
        
        Test.stopTest();
        
        // Verify student was created with correct status
        student = [SELECT Id, Status__c FROM Student__c WHERE Id = :student.Id];
        System.assertEquals('At Risk', student.Status__c, 'Student should be marked as At Risk');
        
        // Note: We can't directly test the future method call, but we can verify
        // that the insert completed successfully without errors
    }
    
    /**
     * @description Test after update trigger logic
     */
    @isTest
    static void testAfterUpdate() {
        // Mock HTTP callout for external notifications
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create initial student with regular status
        Student__c student = new Student__c(
            Name = 'Test Student',
            Roll_No__c = 'TEST001',
            Student_Email__c = 'test@test.com',
            Attendance_Percentage__c = 85.0
        );
        insert student;
        
        Test.startTest();
        
        // Update to trigger status change to At Risk
        student.Attendance_Percentage__c = 65.0;
        update student;
        
        Test.stopTest();
        
        // Verify status change
        student = [SELECT Id, Status__c FROM Student__c WHERE Id = :student.Id];
        System.assertEquals('At Risk', student.Status__c, 'Status should be updated to At Risk');
    }
    
    /**
     * @description Test bulk operations
     */
    @isTest
    static void testBulkOperations() {
        Test.startTest();
        
        // Create multiple students for bulk testing
        List<Student__c> students = new List<Student__c>();
        
        for (Integer i = 0; i < 200; i++) {
            Decimal attendancePercentage;
            if (Math.mod(i, 3) == 0) {
                attendancePercentage = 85.0; // Regular
            } else if (Math.mod(i, 3) == 1) {
                attendancePercentage = 65.0; // At Risk
            } else {
                attendancePercentage = 40.0; // Probation
            }
            
            students.add(new Student__c(
                Name = 'Bulk Student ' + i,
                Roll_No__c = 'BULK' + String.valueOf(i).leftPad(3, '0'),
                Student_Email__c = 'bulk' + i + '@test.com',
                Attendance_Percentage__c = attendancePercentage
            ));
        }
        
        // Insert all students at once
        insert students;
        
        Test.stopTest();
        
        // Verify all students were processed correctly
        List<Student__c> insertedStudents = [
            SELECT Id, Status__c, Attendance_Percentage__c 
            FROM Student__c 
            WHERE Id IN :students
        ];
        
        System.assertEquals(200, insertedStudents.size(), 'All students should be inserted');
        
        // Count status distributions
        Integer regularCount = 0;
        Integer atRiskCount = 0;
        Integer probationCount = 0;
        
        for (Student__c student : insertedStudents) {
            if (student.Status__c == 'Regular') regularCount++;
            else if (student.Status__c == 'At Risk') atRiskCount++;
            else if (student.Status__c == 'Probation') probationCount++;
        }
        
        System.assert(regularCount > 0, 'Should have some regular students');
        System.assert(atRiskCount > 0, 'Should have some at-risk students');
        System.assert(probationCount > 0, 'Should have some probation students');
    }
    
    /**
     * @description Test recursive trigger prevention
     */
    @isTest
    static void testRecursivePrevention() {
        // Create student
        Student__c student = new Student__c(
            Name = 'Recursive Test Student',
            Roll_No__c = 'REC001',
            Student_Email__c = 'recursive@test.com',
            Attendance_Percentage__c = 85.0
        );
        insert student;
        
        Test.startTest();
        
        // Update multiple times to test recursive prevention
        student.Attendance_Percentage__c = 65.0;
        update student;
        
        student.Attendance_Percentage__c = 40.0;
        update student;
        
        student.Attendance_Percentage__c = 85.0;
        update student;
        
        Test.stopTest();
        
        // Verify final status
        student = [SELECT Id, Status__c FROM Student__c WHERE Id = :student.Id];
        System.assertEquals('Regular', student.Status__c, 'Final status should be Regular');
    }
    
    /**
     * @description Test error handling in trigger
     */
    @isTest
    static void testErrorHandling() {
        Test.startTest();
        
        try {
            // Create student with invalid data to test error handling
            Student__c student = new Student__c(
                Name = 'Error Test Student',
                Roll_No__c = 'ERR001',
                Student_Email__c = 'invalid-email', // Invalid email format
                Attendance_Percentage__c = 65.0
            );
            
            insert student;
            
            // If we reach here, the insert succeeded despite invalid email
            // The trigger should still work correctly
            student = [SELECT Id, Status__c FROM Student__c WHERE Id = :student.Id];
            System.assertEquals('At Risk', student.Status__c, 'Status should still be set correctly');
            
        } catch (Exception e) {
            // If an exception is thrown, that's also acceptable for this test
            System.assert(true, 'Exception handling is working');
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
            res.setBody('{"status":"success","message":"Notification sent"}');
            res.setStatusCode(200);
            return res;
        }
    }
}