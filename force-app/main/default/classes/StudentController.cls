public with sharing class StudentController {
    @AuraEnabled(cacheable=true)
    public static List<Student__c> searchStudents(String searchTerm) {
        if (String.isBlank(searchTerm) || searchTerm.length() < 2) {
            return new List<Student__c>();
        }
        String q = '%' + String.escapeSingleQuotes(searchTerm) + '%';
        return [
            SELECT Id, Name, Roll_No__c, Status__c, Attendance_Percentage__c, Student_Email__c
            FROM Student__c
            WHERE Name LIKE :q OR Roll_No__c LIKE :q
            ORDER BY Name ASC
            LIMIT 100
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Student__c> getAtRiskStudents() {
        return [
            SELECT Id, Name, Roll_No__c, Status__c, Attendance_Percentage__c, Student_Email__c
            FROM Student__c
            WHERE Status__c = 'At Risk'
            ORDER BY Attendance_Percentage__c ASC, Name ASC
            LIMIT 100
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getAttendanceDistribution() {
        Map<String, Integer> dist = new Map<String, Integer>{
            'Regular' => 0,
            'At Risk' => 0,
            'Probation' => 0
        };
        for (AggregateResult ar : [SELECT Status__c s, COUNT(Id) c FROM Student__c GROUP BY Status__c]) {
            String s = (String)ar.get('s');
            Integer c = (Integer)ar.get('c');
            if (dist.containsKey(s)) dist.put(s, c);
        }
        return dist;
    }
}
