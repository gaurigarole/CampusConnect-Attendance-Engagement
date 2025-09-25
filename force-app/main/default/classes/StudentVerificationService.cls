public with sharing class StudentVerificationService {
    
    @future(callout=true)
    public static void verifyStudentAsync(String studentId, String email, String studentNumber) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:StudentVerificationAPI/verify');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            
            Map<String, Object> requestBody = new Map<String, Object>{
                'studentId' => studentId,
                'email' => email,
                'studentNumber' => studentNumber,
                'source' => 'CampusConnect'
            };
            req.setBody(JSON.serialize(requestBody));
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Boolean isVerified = (Boolean) responseData.get('verified');
                
                // Update student record with verification status
                Student__c student = new Student__c(
                    Id = studentId,
                    External_Verification_Status__c = isVerified ? 'Verified' : 'Failed',
                    External_Verification_Date__c = System.now()
                );
                update student;
                
                System.debug('Student verification completed: ' + studentId + ' - ' + isVerified);
            }
        } catch (Exception e) {
            System.debug('Student verification error: ' + e.getMessage());
            // Log error to custom object or send notification
        }
    }
    
    public static void syncCourseData(String courseId) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:CourseManagementAPI/courses/' + courseId);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> courseData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                
                Course__c course = new Course__c(
                    Id = courseId,
                    External_Course_Code__c = (String) courseData.get('courseCode'),
                    External_Credits__c = (Decimal) courseData.get('credits'),
                    External_Sync_Date__c = System.now()
                );
                update course;
            }
        } catch (Exception e) {
            System.debug('Course sync error: ' + e.getMessage());
        }
    }
}
