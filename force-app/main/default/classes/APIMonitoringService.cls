public with sharing class APIMonitoringService {
    
    private static final String API_USAGE_CUSTOM_SETTING = 'CampusConnect_API_Usage';
    
    public static void logAPICall(String serviceName, String endpoint, Integer responseCode, Long responseTime) {
        try {
            // Create custom object record to track API usage
            API_Usage_Log__c logRecord = new API_Usage_Log__c(
                Service_Name__c = serviceName,
                Endpoint__c = endpoint,
                Response_Code__c = responseCode,
                Response_Time_MS__c = responseTime,
                Call_DateTime__c = System.now()
            );
            insert logRecord;
            
            // Update daily counters
            updateDailyUsageCounters(serviceName);
            
        } catch (Exception e) {
            System.debug('Error logging API call: ' + e.getMessage());
        }
    }
    
    private static void updateDailyUsageCounters(String serviceName) {
        String todayKey = serviceName + '_' + System.today().format();
        
        // Use custom settings or custom metadata to track daily limits
        List<AggregateResult> todaysCalls = [
            SELECT COUNT(Id) callCount
            FROM API_Usage_Log__c 
            WHERE Service_Name__c = :serviceName 
            AND DAY_ONLY(Call_DateTime__c) = TODAY
        ];
        
        if (!todaysCalls.isEmpty()) {
            Integer callCount = (Integer) todaysCalls[0].get('callCount');
            
            // Check against daily limits (configurable per service)
            Integer dailyLimit = getDailyLimit(serviceName);
            
            if (callCount >= dailyLimit * 0.9) { // 90% threshold
                sendAPILimitWarning(serviceName, callCount, dailyLimit);
            }
        }
    }
    
    private static Integer getDailyLimit(String serviceName) {
        // Default limits - could be stored in custom settings
        Map<String, Integer> limits = new Map<String, Integer>{
            'StudentVerificationAPI' => 1000,
            'CourseManagementAPI' => 500
        };
        
        return limits.get(serviceName) != null ? limits.get(serviceName) : 100;
    }
    
    private static void sendAPILimitWarning(String serviceName, Integer currentCount, Integer dailyLimit) {
        // Send email or create task for admin notification
        System.debug('API Limit Warning: ' + serviceName + ' has used ' + currentCount + ' of ' + dailyLimit + ' daily calls');
        
        // Could implement email notification here
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{'admin@campusconnect.edu'});
        email.setSubject('CampusConnect API Usage Warning');
        email.setPlainTextBody('Service ' + serviceName + ' has reached ' + 
                              ((currentCount * 100) / dailyLimit) + '% of daily API limit.');
        
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        } catch (Exception e) {
            System.debug('Failed to send API warning email: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAPIUsageStats() {
        Map<String, Object> stats = new Map<String, Object>();
        
        try {
            List<AggregateResult> todaysUsage = [
                SELECT Service_Name__c serviceName, COUNT(Id) callCount
                FROM API_Usage_Log__c 
                WHERE DAY_ONLY(Call_DateTime__c) = TODAY
                GROUP BY Service_Name__c
            ];
            
            for (AggregateResult result : todaysUsage) {
                String serviceName = (String) result.get('serviceName');
                Integer callCount = (Integer) result.get('callCount');
                Integer dailyLimit = getDailyLimit(serviceName);
                
                stats.put(serviceName, new Map<String, Object>{
                    'callCount' => callCount,
                    'dailyLimit' => dailyLimit,
                    'percentageUsed' => (callCount * 100) / dailyLimit
                });
            }
        } catch (Exception e) {
            System.debug('Error getting API usage stats: ' + e.getMessage());
        }
        
        return stats;
    }
}
