/**
 * @description Reusable service class for Student-related operations
 * @author CampusConnect Development Team
 * @date 2025
 */
public with sharing class StudentService {
    
    // Constants for status values
    public static final String STATUS_REGULAR = 'Regular';
    public static final String STATUS_AT_RISK = 'At Risk';
    public static final String STATUS_PROBATION = 'Probation';
    
    // Attendance thresholds
    public static final Decimal PROBATION_THRESHOLD = 50.0;
    public static final Decimal AT_RISK_THRESHOLD = 75.0;
    
    /**
     * @description Updates student status based on attendance percentage
     * @param students List of Student records to update
     */
    public static void updateStudentStatus(List<Student__c> students) {
        try {
            for (Student__c student : students) {
                if (student.Attendance_Percentage__c != null) {
                    if (student.Attendance_Percentage__c < PROBATION_THRESHOLD) {
                        student.Status__c = STATUS_PROBATION;
                    } else if (student.Attendance_Percentage__c < AT_RISK_THRESHOLD) {
                        student.Status__c = STATUS_AT_RISK;
                    } else {
                        student.Status__c = STATUS_REGULAR;
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error updating student status: ' + e.getMessage());
            throw new StudentServiceException('Failed to update student status: ' + e.getMessage());
        }
    }
    
    /**
     * @description Auto-enrolls students in courses if enrollment status is approved
     * @param studentCourses List of StudentCourse records to process
     */
    public static void autoEnrollStudents(List<StudentCourse__c> studentCourses) {
        try {
            List<StudentCourse__c> coursesToUpdate = new List<StudentCourse__c>();
            
            for (StudentCourse__c sc : studentCourses) {
                if (sc.Enrollment_Status__c == 'Approved' && sc.Student__c != null && sc.Course__c != null) {
                    sc.Enrollment_Status__c = 'Enrolled';
                    coursesToUpdate.add(sc);
                }
            }
            
            if (!coursesToUpdate.isEmpty()) {
                update coursesToUpdate;
                System.debug('Auto-enrolled ' + coursesToUpdate.size() + ' students in courses');
            }
        } catch (Exception e) {
            System.debug('Error auto-enrolling students: ' + e.getMessage());
            throw new StudentServiceException('Failed to auto-enroll students: ' + e.getMessage());
        }
    }
    
    /**
     * @description Calculates student performance score based on attendance and other factors
     * @param studentIds Set of Student IDs to calculate performance for
     * @return Map of Student ID to Performance Score
     */
    public static Map<Id, Decimal> calculatePerformanceScores(Set<Id> studentIds) {
        Map<Id, Decimal> performanceScores = new Map<Id, Decimal>();
        
        try {
            // Query students with related data
            List<Student__c> students = [
                SELECT Id, Name, Attendance_Percentage__c, Status__c,
                       (SELECT Id, Status__c FROM Attendance_Records__r WHERE Date__c = LAST_N_DAYS:30)
                FROM Student__c 
                WHERE Id IN :studentIds
                LIMIT 200
            ];
            
            for (Student__c student : students) {
                Decimal performanceScore = 0;
                
                // Base score from attendance percentage
                if (student.Attendance_Percentage__c != null) {
                    performanceScore += student.Attendance_Percentage__c;
                }
                
                // Bonus points for recent attendance
                Integer recentAttendanceCount = 0;
                for (Attendance__c attendance : student.Attendance_Records__r) {
                    if (attendance.Status__c == 'Present') {
                        recentAttendanceCount++;
                    }
                }
                performanceScore += (recentAttendanceCount * 2); // 2 points per recent attendance
                
                // Status modifier
                if (student.Status__c == STATUS_REGULAR) {
                    performanceScore += 10;
                } else if (student.Status__c == STATUS_AT_RISK) {
                    performanceScore -= 5;
                } else if (student.Status__c == STATUS_PROBATION) {
                    performanceScore -= 15;
                }
                
                // Cap the score between 0 and 100
                performanceScore = Math.max(0, Math.min(100, performanceScore));
                performanceScores.put(student.Id, performanceScore);
            }
            
        } catch (Exception e) {
            System.debug('Error calculating performance scores: ' + e.getMessage());
            throw new StudentServiceException('Failed to calculate performance scores: ' + e.getMessage());
        }
        
        return performanceScores;
    }
    
    /**
     * @description Gets students with low attendance for reporting
     * @param attendanceThreshold Minimum attendance percentage threshold
     * @return List of students below the threshold
     */
    public static List<Student__c> getStudentsWithLowAttendance(Decimal attendanceThreshold) {
        try {
            return [
                SELECT Id, Name, Roll_No__c, Student_Email__c, Attendance_Percentage__c, Status__c
                FROM Student__c 
                WHERE Attendance_Percentage__c < :attendanceThreshold
                AND Student_Email__c != null
                ORDER BY Attendance_Percentage__c ASC
                LIMIT 100
            ];
        } catch (Exception e) {
            System.debug('Error querying low attendance students: ' + e.getMessage());
            throw new StudentServiceException('Failed to query low attendance students: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets events scheduled for today
     * @return List of today's events
     */
    public static List<Event__c> getTodaysEvents() {
        try {
            Date today = Date.today();
            return [
                SELECT Id, Event_Name__c, Date__c, End_Date__c, Location__c, Status__c, Organizer__c
                FROM Event__c 
                WHERE Date__c = :today
                OR (Date__c <= :today AND End_Date__c >= :today)
                ORDER BY Date__c ASC
                LIMIT 50
            ];
        } catch (Exception e) {
            System.debug('Error querying today\'s events: ' + e.getMessage());
            throw new StudentServiceException('Failed to query today\'s events: ' + e.getMessage());
        }
    }
    
    /**
     * @description Validates event dates to prevent end date before start date
     * @param events List of Event records to validate
     */
    public static void validateEventDates(List<Event__c> events) {
        for (Event__c event : events) {
            if (event.End_Date__c != null && event.Date__c != null) {
                DateTime startDateTime = DateTime.newInstance(event.Date__c, Time.newInstance(0, 0, 0, 0));
                if (event.End_Date__c <= startDateTime) {
                    throw new StudentServiceException('Event End Date must be after Start Date for event: ' + event.Event_Name__c);
                }
            }
        }
    }
    
    /**
     * @description Sends notification to external system (Future method)
     * @param studentIds Set of Student IDs to notify about
     * @param notificationType Type of notification to send
     */
    @future(callout=true)
    public static void sendExternalNotification(Set<Id> studentIds, String notificationType) {
        try {
            // Simulate external API call
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.campusconnect.com/notifications');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            
            Map<String, Object> payload = new Map<String, Object>{
                'studentIds' => new List<Id>(studentIds),
                'notificationType' => notificationType,
                'timestamp' => DateTime.now().format()
            };
            
            req.setBody(JSON.serialize(payload));
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                System.debug('External notification sent successfully');
            } else {
                System.debug('External notification failed: ' + res.getBody());
            }
            
        } catch (Exception e) {
            System.debug('Error sending external notification: ' + e.getMessage());
            // Log error but don't throw exception in future method
        }
    }
    
    /**
     * @description Custom exception class for StudentService
     */
    public class StudentServiceException extends Exception {}
}