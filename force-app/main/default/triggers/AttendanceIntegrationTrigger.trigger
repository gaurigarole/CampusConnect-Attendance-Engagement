trigger AttendanceIntegrationTrigger on Attendance__c (after insert, after update) {
    
    if (Trigger.isAfter) {
        Set<String> studentsToEvaluate = new Set<String>();
        
        for (Attendance__c attendance : Trigger.new) {
            // Evaluate student risk when attendance is recorded or updated
            if (Trigger.isInsert || 
                (Trigger.isUpdate && attendance.Status__c != Trigger.oldMap.get(attendance.Id).Status__c)) {
                studentsToEvaluate.add(attendance.Student__c);
            }
        }
        
        // Evaluate at-risk status for affected students
        if (!studentsToEvaluate.isEmpty()) {
            for (String studentId : studentsToEvaluate) {
                AtRiskStudentEventPublisher.evaluateStudentRisk(studentId);
            }
        }
    }
}
