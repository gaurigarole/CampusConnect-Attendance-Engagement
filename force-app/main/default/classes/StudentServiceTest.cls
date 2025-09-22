/**
 * @description Test class for StudentService
 * @author CampusConnect Development Team
 * @date 2025
 */
@isTest
public class StudentServiceTest {
    
    /**
     * @description Test data setup method
     */
    @TestSetup
    static void setupTestData() {
        // Create test students
        List<Student__c> testStudents = new List<Student__c>();
        
        testStudents.add(new Student__c(
            Name = 'Test Student 1',
            Roll_No__c = 'TS001',
            Student_Email__c = 'test1@campusconnect.com',
            Attendance_Percentage__c = 0.85,
            Status__c = 'Regular'
        ));
        
        testStudents.add(new Student__c(
            Name = 'Test Student 2',
            Roll_No__c = 'TS002',
            Student_Email__c = 'test2@campusconnect.com',
            Attendance_Percentage__c = 0.65,
            Status__c = 'At Risk'
        ));
        
        testStudents.add(new Student__c(
            Name = 'Test Student 3',
            Roll_No__c = 'TS003',
            Student_Email__c = 'test3@campusconnect.com',
            Attendance_Percentage__c = 0.40,
            Status__c = 'Probation'
        ));
        
        insert testStudents;
        
        // Create test courses
        List<Course__c> testCourses = new List<Course__c>();
        testCourses.add(new Course__c(
            Name = 'Test Course 1',
            Course_Code__c = 'TC001',
            Credits__c = 3
        ));
        
        insert testCourses;
        
        // Create test student courses
        List<StudentCourse__c> testStudentCourses = new List<StudentCourse__c>();
        testStudentCourses.add(new StudentCourse__c(
            Student__c = testStudents[0].Id,
            Course__c = testCourses[0].Id,
            Enrollment_Status__c = 'Approved'
        ));
        
        insert testStudentCourses;
        
        // Create test events
        List<Event__c> testEvents = new List<Event__c>();
        testEvents.add(new Event__c(
            Event_Name__c = 'Test Event 1',
            Date__c = Date.today(),
            End_Date__c = DateTime.now().addHours(2),
            Location__c = 'Room 101',
            Status__c = 'Scheduled'
        ));
        
        insert testEvents;
        
        // Create test attendance records
        List<Attendance__c> testAttendance = new List<Attendance__c>();
        for (Integer i = 0; i < 5; i++) {
            testAttendance.add(new Attendance__c(
                Student__c = testStudents[0].Id,
                Date__c = Date.today().addDays(-i),
                Status__c = 'Present'
            ));
        }
        
        insert testAttendance;
    }
    
    /**
     * @description Test updateStudentStatus method
     */
    @isTest
    static void testUpdateStudentStatus() {
        Test.startTest();
        
        // Create students with different attendance percentages
        List<Student__c> students = new List<Student__c>();
        
        students.add(new Student__c(
            Name = 'Regular Student',
            Attendance_Percentage__c = 0.85
        ));
        
        students.add(new Student__c(
            Name = 'At Risk Student',
            Attendance_Percentage__c = 0.65
        ));
        
        students.add(new Student__c(
            Name = 'Probation Student',
            Attendance_Percentage__c = 0.40
        ));
        
        // Test the updateStudentStatus method
        StudentService.updateStudentStatus(students);
        
        Test.stopTest();
        
        // Verify status updates
        System.assertEquals('Regular', students[0].Status__c, 'Student with 85% attendance should be Regular');
        System.assertEquals('At Risk', students[1].Status__c, 'Student with 65% attendance should be At Risk');
        System.assertEquals('Probation', students[2].Status__c, 'Student with 40% attendance should be on Probation');
    }
    
    /**
     * @description Test autoEnrollStudents method
     */
    @isTest
    static void testAutoEnrollStudents() {
        List<Student__c> students = [SELECT Id FROM Student__c LIMIT 1];
        List<Course__c> courses = [SELECT Id FROM Course__c LIMIT 1];
        
        Test.startTest();
        
        // Create student course with approved status
        List<StudentCourse__c> studentCourses = new List<StudentCourse__c>();
        studentCourses.add(new StudentCourse__c(
            Student__c = students[0].Id,
            Course__c = courses[0].Id,
            Enrollment_Status__c = 'Approved'
        ));
        
        insert studentCourses;
        
        // Test auto enrollment
        StudentService.autoEnrollStudents(studentCourses);
        
        Test.stopTest();
        
        // Verify enrollment status changed to Enrolled
        StudentCourse__c updatedCourse = [SELECT Enrollment_Status__c FROM StudentCourse__c WHERE Id = :studentCourses[0].Id];
        System.assertEquals('Enrolled', updatedCourse.Enrollment_Status__c, 'Student should be auto-enrolled');
    }
    
    /**
     * @description Test calculatePerformanceScores method
     */
    @isTest
    static void testCalculatePerformanceScores() {
        List<Student__c> students = [SELECT Id FROM Student__c];
        Set<Id> studentIds = new Set<Id>();
        for (Student__c student : students) {
            studentIds.add(student.Id);
        }
        
        Test.startTest();
        
        Map<Id, Decimal> performanceScores = StudentService.calculatePerformanceScores(studentIds);
        
        Test.stopTest();
        
        // Verify performance scores were calculated
        System.assertNotEquals(null, performanceScores, 'Performance scores should not be null');
        System.assertEquals(students.size(), performanceScores.size(), 'Should have scores for all students');
        
        for (Decimal score : performanceScores.values()) {
            System.assert(score >= 0 && score <= 100, 'Performance score should be between 0 and 100');
        }
    }
    
    /**
     * @description Test getStudentsWithLowAttendance method
     */
    @isTest
    static void testGetStudentsWithLowAttendance() {
        Test.startTest();
        
        List<Student__c> lowAttendanceStudents = StudentService.getStudentsWithLowAttendance(75);
        
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, lowAttendanceStudents, 'Result should not be null');
        
        for (Student__c student : lowAttendanceStudents) {
            System.assert(student.Attendance_Percentage__c < 75, 'All students should have attendance < 75%');
        }
    }
    
    /**
     * @description Test getTodaysEvents method
     */
    @isTest
    static void testGetTodaysEvents() {
        Test.startTest();
        
        List<Event__c> todaysEvents = StudentService.getTodaysEvents();
        
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, todaysEvents, 'Result should not be null');
        
        for (Event__c event : todaysEvents) {
            System.assertEquals(Date.today(), event.Date__c, 'All events should be for today');
        }
    }
    
    /**
     * @description Test validateEventDates method
     */
    @isTest
    static void testValidateEventDates() {
        Test.startTest();
        
        // Test valid event dates
        List<Event__c> validEvents = new List<Event__c>();
        validEvents.add(new Event__c(
            Event_Name__c = 'Valid Event',
            Date__c = Date.today(),
            End_Date__c = DateTime.now().addHours(2)
        ));
        
        try {
            StudentService.validateEventDates(validEvents);
            System.assert(true, 'Valid event dates should not throw exception');
        } catch (Exception e) {
            System.assert(false, 'Valid event dates should not throw exception: ' + e.getMessage());
        }
        
        // Test invalid event dates
        List<Event__c> invalidEvents = new List<Event__c>();
        invalidEvents.add(new Event__c(
            Event_Name__c = 'Invalid Event',
            Date__c = Date.today(),
            End_Date__c = DateTime.now().addHours(-2)
        ));
        
        Boolean exceptionThrown = false;
        try {
            StudentService.validateEventDates(invalidEvents);
        } catch (StudentService.StudentServiceException e) {
            exceptionThrown = true;
        }
        
        System.assert(exceptionThrown, 'Invalid event dates should throw exception');
        
        Test.stopTest();
    }
    
    /**
     * @description Test sendExternalNotification future method
     */
    @isTest
    static void testSendExternalNotification() {
        List<Student__c> students = [SELECT Id FROM Student__c LIMIT 2];
        Set<Id> studentIds = new Set<Id>();
        for (Student__c student : students) {
            studentIds.add(student.Id);
        }
        
        Test.startTest();
        
        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        StudentService.sendExternalNotification(studentIds, 'TEST_NOTIFICATION');
        
        Test.stopTest();
        
        // Since it's a future method, we can't directly test the result
        // But we can verify no exceptions were thrown
        System.assert(true, 'Future method should execute without exceptions');
    }
    
    /**
     * @description Test exception handling
     */
    @isTest
    static void testExceptionHandling() {
        Test.startTest();
        
        // Test with null list to trigger exception
        Boolean exceptionThrown = false;
        try {
            StudentService.updateStudentStatus(null);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        
        System.assert(exceptionThrown, 'Exception should be thrown for null input');
        
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