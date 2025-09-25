public with sharing class AtRiskStudentEventPublisher {
    
    public static void publishAtRiskNotification(String studentId, String riskLevel, Decimal attendancePercentage) {
        AtRiskStudentNotification__e event = new AtRiskStudentNotification__e(
            StudentId__c = studentId,
            RiskLevel__c = riskLevel,
            AttendancePercentage__c = attendancePercentage
        );
        
        Database.SaveResult result = EventBus.publish(event);
        
        if (!result.isSuccess()) {
            System.debug('Failed to publish at-risk student event: ' + result.getErrors());
        } else {
            System.debug('Successfully published at-risk student event for: ' + studentId);
        }
    }
    
    public static void evaluateStudentRisk(String studentId) {
        try {
            // Calculate attendance percentage for the student
            List<AggregateResult> attendanceStats = [
                SELECT COUNT(Id) totalRecords
                FROM Attendance__c 
                WHERE Student__c = :studentId
                AND Date__c >= LAST_N_DAYS:30
            ];
            
            List<AggregateResult> presentStats = [
                SELECT COUNT(Id) presentCount
                FROM Attendance__c 
                WHERE Student__c = :studentId
                AND Status__c = 'Present'
                AND Date__c >= LAST_N_DAYS:30
            ];
            
            if (!attendanceStats.isEmpty() && !presentStats.isEmpty()) {
                AggregateResult stats = attendanceStats[0];
                AggregateResult presentResult = presentStats[0];
                Integer total = (Integer) stats.get('totalRecords');
                Integer present = (Integer) presentResult.get('presentCount');
                
                if (total > 0) {
                    Decimal attendancePercentage = (Decimal.valueOf(present) / Decimal.valueOf(total)) * 100;
                    String riskLevel = 'Low';
                    
                    if (attendancePercentage < 50) {
                        riskLevel = 'Critical';
                    } else if (attendancePercentage < 70) {
                        riskLevel = 'High';
                    } else if (attendancePercentage < 85) {
                        riskLevel = 'Medium';
                    }
                    
                    if (riskLevel != 'Low') {
                        publishAtRiskNotification(studentId, riskLevel, attendancePercentage);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error evaluating student risk: ' + e.getMessage());
        }
    }
}
