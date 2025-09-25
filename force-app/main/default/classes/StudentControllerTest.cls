@IsTest
private class StudentControllerTest {

    @TestSetup
    static void setup() {
        List<Student__c> students = new List<Student__c>{
            new Student__c(Name='Test Student A', Roll_No__c='T001', Status__c='At Risk', Attendance_Percentage__c=60, Student_Email__c='a@test.com'),
            new Student__c(Name='Test Student B', Roll_No__c='T002', Status__c='Regular', Attendance_Percentage__c=85, Student_Email__c='b@test.com'),
            new Student__c(Name='Another One', Roll_No__c='X003', Status__c='Probation', Attendance_Percentage__c=40, Student_Email__c='c@test.com')
        };
        insert students;
    }

    @IsTest
    static void testSearchStudents() {
        Test.startTest();
        List<Student__c> results = StudentController.searchStudents('Test');
        Test.stopTest();
        System.assert(results.size() >= 2, 'Should find at least 2 students with name starting with Test');
        for (Student__c s : results) {
            System.assertNotEquals(null, s.Roll_No__c, 'Roll No should be selected');
        }
    }

    @IsTest
    static void testGetAtRiskStudents() {
        Test.startTest();
        List<Student__c> atRisk = StudentController.getAtRiskStudents();
        Test.stopTest();
        System.assertEquals(true, atRisk.size() >= 1, 'Should return at least one at-risk student');
        for (Student__c s : atRisk) {
            System.assertEquals('At Risk', s.Status__c, 'Status should be At Risk');
        }
    }

    @IsTest
    static void testGetAttendanceDistribution() {
        Test.startTest();
        Map<String, Integer> dist = StudentController.getAttendanceDistribution();
        Test.stopTest();
        System.assertEquals(true, dist.containsKey('Regular'));
        System.assertEquals(true, dist.containsKey('At Risk'));
        System.assertEquals(true, dist.containsKey('Probation'));
    }
}
