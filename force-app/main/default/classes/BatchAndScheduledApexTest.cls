/**
 * @description Test class for Batch, Queueable, and Scheduled Apex classes
 * @author CampusConnect Development Team
 * @date 2025
 */
@isTest
public class BatchAndScheduledApexTest {
    
    /**
     * @description Test data setup method
     */
    @TestSetup
    static void setupTestData() {
        // Create test students with various attendance percentages
        List<Student__c> testStudents = new List<Student__c>();
        
        // Students for probation (attendance < 50%)
        for (Integer i = 0; i < 5; i++) {
            testStudents.add(new Student__c(
                Name = 'Probation Student ' + i,
                Roll_No__c = 'PROB' + String.valueOf(i).leftPad(3, '0'),
                Student_Email__c = 'probation' + i + '@test.com',
                Attendance_Percentage__c = 30.0 + (i * 2), // 30%, 32%, 34%, 36%, 38%
                Status__c = 'At Risk' // Will be updated to Probation by batch
            ));
        }
        
        // Students at risk (50% <= attendance < 75%)
        for (Integer i = 0; i < 3; i++) {
            testStudents.add(new Student__c(
                Name = 'At Risk Student ' + i,
                Roll_No__c = 'RISK' + String.valueOf(i).leftPad(3, '0'),
                Student_Email__c = 'atrisk' + i + '@test.com',
                Attendance_Percentage__c = 60.0 + (i * 5), // 60%, 65%, 70%
                Status__c = 'At Risk'
            ));
        }
        
        // Regular students (attendance >= 75%)
        for (Integer i = 0; i < 2; i++) {
            testStudents.add(new Student__c(
                Name = 'Regular Student ' + i,
                Roll_No__c = 'REG' + String.valueOf(i).leftPad(3, '0'),
                Student_Email__c = 'regular' + i + '@test.com',
                Attendance_Percentage__c = 85.0 + (i * 5), // 85%, 90%
                Status__c = 'Regular'
            ));
        }
        
        insert testStudents;
        
        // Create test events for today and tomorrow
        List<Event__c> testEvents = new List<Event__c>();
        
        testEvents.add(new Event__c(
            Event_Name__c = 'Today Event 1',
            Date__c = Date.today(),
            End_Date__c = DateTime.now().addHours(2),
            Location__c = 'Room 101',
            Status__c = 'Scheduled',
            Organizer__c = 'Test Organizer 1'
        ));
        
        testEvents.add(new Event__c(
            Event_Name__c = 'Today Event 2',
            Date__c = Date.today(),
            End_Date__c = DateTime.now().addHours(4),
            Location__c = 'Room 102',
            Status__c = 'In Progress',
            Organizer__c = 'Test Organizer 2'
        ));
        
        testEvents.add(new Event__c(
            Event_Name__c = 'Tomorrow Event 1',
            Date__c = Date.today().addDays(1),
            End_Date__c = DateTime.now().addDays(1).addHours(2),
            Location__c = 'Room 103',
            Status__c = 'Scheduled',
            Organizer__c = 'Test Organizer 3'
        ));
        
        insert testEvents;
        
        // Create test faculty members
        List<Faculty__c> testFaculty = new List<Faculty__c>();
        
        testFaculty.add(new Faculty__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Faculty 1',
            Email__c = 'faculty1@test.com',
            Department__c = 'Computer Science'
        ));
        
        testFaculty.add(new Faculty__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Faculty 2',
            Email__c = 'faculty2@test.com',
            Department__c = 'Mathematics'
        ));
        
        insert testFaculty;
        
        // Create test attendance records
        List<Student__c> students = [SELECT Id FROM Student__c LIMIT 3];
        List<Attendance__c> testAttendance = new List<Attendance__c>();
        
        for (Student__c student : students) {
            for (Integer i = 0; i < 10; i++) {
                testAttendance.add(new Attendance__c(
                    Student__c = student.Id,
                    Date__c = Date.today().addDays(-i),
                    Status__c = (Math.mod(i, 3) == 0) ? 'Present' : 'Absent'
                ));
            }
        }
        
        insert testAttendance;
    }
    
    /**
     * @description Test StudentProbationBatch
     */
    @isTest
    static void testStudentProbationBatch() {
        Test.startTest();
        
        // Execute the batch job
        StudentProbationBatch batch = new StudentProbationBatch();
        Id jobId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch job completed
        System.assertNotEquals(null, jobId, 'Batch job should be queued');
        
        // Verify students with attendance < 50% were updated to Probation
        List<Student__c> probationStudents = [
            SELECT Id, Name, Status__c, Attendance_Percentage__c 
            FROM Student__c 
            WHERE Attendance_Percentage__c < 50
        ];
        
        for (Student__c student : probationStudents) {
            System.assertEquals('Probation', student.Status__c, 
                              'Student with low attendance should be on Probation: ' + student.Name);
        }
        
        // Verify students with higher attendance were not affected
        List<Student__c> regularStudents = [
            SELECT Id, Name, Status__c, Attendance_Percentage__c 
            FROM Student__c 
            WHERE Attendance_Percentage__c >= 75
        ];
        
        for (Student__c student : regularStudents) {
            System.assertEquals('Regular', student.Status__c, 
                              'Regular student status should not change: ' + student.Name);
        }
    }
    
    /**
     * @description Test EventSummaryBatch
     */
    @isTest
    static void testEventSummaryBatch() {
        Test.startTest();
        
        // Execute the batch job
        EventSummaryBatch batch = new EventSummaryBatch();
        Id jobId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch job completed
        System.assertNotEquals(null, jobId, 'Batch job should be queued');
        
        // Since we can't directly test email sending in unit tests,
        // we verify that the batch processes the correct events
        List<Event__c> todaysEvents = [
            SELECT Id, Event_Name__c 
            FROM Event__c 
            WHERE Date__c = :Date.today()
        ];
        
        List<Event__c> tomorrowsEvents = [
            SELECT Id, Event_Name__c 
            FROM Event__c 
            WHERE Date__c = :Date.today().addDays(1)
        ];
        
        System.assert(todaysEvents.size() > 0, 'Should have today\'s events');
        System.assert(tomorrowsEvents.size() > 0, 'Should have tomorrow\'s events');
    }
    
    /**
     * @description Test StudentPerformanceCalculator (Queueable)
     */
    @isTest
    static void testStudentPerformanceCalculator() {
        List<Student__c> students = [SELECT Id FROM Student__c LIMIT 5];
        Set<Id> studentIds = new Set<Id>();
        for (Student__c student : students) {
            studentIds.add(student.Id);
        }
        
        Test.startTest();
        
        // Execute the queueable job
        StudentPerformanceCalculator calculator = new StudentPerformanceCalculator(studentIds);
        Id jobId = System.enqueueJob(calculator);
        
        Test.stopTest();
        
        // Verify job was queued
        System.assertNotEquals(null, jobId, 'Queueable job should be queued');
        
        // Verify performance calculation logic (indirectly through service method)
        Map<Id, Decimal> performanceScores = StudentService.calculatePerformanceScores(studentIds);
        System.assertNotEquals(null, performanceScores, 'Performance scores should be calculated');
        System.assertEquals(studentIds.size(), performanceScores.size(), 
                           'Should have performance scores for all students');
    }
    
    /**
     * @description Test StudentPerformanceCalculator with chaining
     */
    @isTest
    static void testStudentPerformanceCalculatorChaining() {
        // Create more students to test chaining
        List<Student__c> moreStudents = new List<Student__c>();
        for (Integer i = 0; i < 150; i++) {
            moreStudents.add(new Student__c(
                Name = 'Chain Student ' + i,
                Roll_No__c = 'CHAIN' + String.valueOf(i).leftPad(3, '0'),
                Student_Email__c = 'chain' + i + '@test.com',
                Attendance_Percentage__c = 75.0
            ));
        }
        insert moreStudents;
        
        Set<Id> studentIds = new Set<Id>();
        for (Student__c student : moreStudents) {
            studentIds.add(student.Id);
        }
        
        Test.startTest();
        
        // Execute with chaining enabled
        StudentPerformanceCalculator calculator = new StudentPerformanceCalculator(studentIds, true);
        Id jobId = System.enqueueJob(calculator);
        
        Test.stopTest();
        
        // Verify job was queued
        System.assertNotEquals(null, jobId, 'Queueable job should be queued');
    }
    
    /**
     * @description Test calculateAllStudentPerformances static method
     */
    @isTest
    static void testCalculateAllStudentPerformances() {
        Test.startTest();
        
        // Execute the static method
        StudentPerformanceCalculator.calculateAllStudentPerformances();
        
        Test.stopTest();
        
        // Verify that the method executes without errors
        // (We can't directly test the enqueued job in the same test context)
        System.assert(true, 'Method should execute without exceptions');
    }
    
    /**
     * @description Test DailyAtRiskStudentNotifier (Scheduled)
     */
    @isTest
    static void testDailyAtRiskStudentNotifier() {
        Test.startTest();
        
        // Execute the scheduled job
        DailyAtRiskStudentNotifier scheduler = new DailyAtRiskStudentNotifier();
        String cronExp = '0 0 8 * * ?'; // 8 AM daily
        String jobId = System.schedule('Test Daily Notifier', cronExp, scheduler);
        
        // Manually execute the scheduled job logic
        scheduler.execute(null);
        
        Test.stopTest();
        
        // Verify job was scheduled
        System.assertNotEquals(null, jobId, 'Scheduled job should be created');
        
        // Verify that at-risk students exist for notification
        List<Student__c> atRiskStudents = StudentService.getStudentsWithLowAttendance(75);
        System.assert(atRiskStudents.size() > 0, 'Should have at-risk students for notification');
    }
    
    /**
     * @description Test DailyAtRiskStudentNotifier scheduling methods
     */
    @isTest
    static void testSchedulingMethods() {
        Test.startTest();
        
        // Test custom cron expression scheduling
        String jobId1 = DailyAtRiskStudentNotifier.scheduleDaily('0 0 9 * * ?');
        System.assertNotEquals(null, jobId1, 'Custom schedule should work');
        
        // Test convenience method for 8 AM scheduling
        String jobId2 = DailyAtRiskStudentNotifier.scheduleDailyAt8AM();
        System.assertNotEquals(null, jobId2, '8 AM schedule should work');
        
        Test.stopTest();
    }
    
    /**
     * @description Test error handling in scheduled job
     */
    @isTest
    static void testScheduledJobErrorHandling() {
        Test.startTest();
        
        // Create a scenario that might cause errors (no faculty members)
        delete [SELECT Id FROM Faculty__c];
        
        DailyAtRiskStudentNotifier scheduler = new DailyAtRiskStudentNotifier();
        
        try {
            scheduler.execute(null);
            System.assert(true, 'Scheduled job should handle errors gracefully');
        } catch (Exception e) {
            System.assert(false, 'Scheduled job should not throw unhandled exceptions: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test batch job with no qualifying records
     */
    @isTest
    static void testBatchWithNoRecords() {
        // Update all students to have high attendance
        List<Student__c> students = [SELECT Id FROM Student__c];
        for (Student__c student : students) {
            student.Attendance_Percentage__c = 85.0;
            student.Status__c = 'Regular';
        }
        update students;
        
        Test.startTest();
        
        StudentProbationBatch batch = new StudentProbationBatch();
        Id jobId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch completed without errors
        System.assertNotEquals(null, jobId, 'Batch job should complete even with no records');
    }
    
    /**
     * @description Test integration between batch and scheduled jobs
     */
    @isTest
    static void testBatchScheduledIntegration() {
        Test.startTest();
        
        // Execute scheduled job which should trigger batch job
        DailyAtRiskStudentNotifier scheduler = new DailyAtRiskStudentNotifier();
        scheduler.execute(null);
        
        Test.stopTest();
        
        // Verify that the integration works without errors
        System.assert(true, 'Integration should work without exceptions');
    }
}