trigger StudentIntegrationTrigger on Student__c (after insert, after update) {
    
    if (Trigger.isAfter) {
        Set<String> studentsToVerify = new Set<String>();
        Set<String> studentsToEvaluate = new Set<String>();
        
        for (Student__c student : Trigger.new) {
            // Trigger verification for new students
            if (Trigger.isInsert) {
                studentsToVerify.add(student.Id);
            }
            
            // Evaluate risk when attendance-related fields change
            if (Trigger.isUpdate) {
                Student__c oldStudent = Trigger.oldMap.get(student.Id);
                if (student.Status__c != oldStudent.Status__c || 
                    student.Email__c != oldStudent.Email__c) {
                    studentsToEvaluate.add(student.Id);
                }
            }
        }
        
        // Process verification callouts asynchronously
        if (!studentsToVerify.isEmpty()) {
            for (String studentId : studentsToVerify) {
                Student__c student = [SELECT Email__c, Student_Number__c FROM Student__c WHERE Id = :studentId LIMIT 1];
                StudentVerificationService.verifyStudentAsync(studentId, student.Email__c, student.Student_Number__c);
            }
        }
        
        // Evaluate at-risk status
        if (!studentsToEvaluate.isEmpty()) {
            for (String studentId : studentsToEvaluate) {
                AtRiskStudentEventPublisher.evaluateStudentRisk(studentId);
            }
        }
    }
}
