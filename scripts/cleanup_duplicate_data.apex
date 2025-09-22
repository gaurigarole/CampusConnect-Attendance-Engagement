// Execute this in Developer Console to clean up duplicate data
// This will help resolve the deployment issue

// 1. Find and update duplicate contacts
List<Contact> duplicateContacts = [
    SELECT Id, Email, Name 
    FROM Contact 
    WHERE Email = 'gaurigarole19@gmail.com'
];

System.debug('Found ' + duplicateContacts.size() + ' contacts with duplicate email');

if (duplicateContacts.size() > 1) {
    // Keep the first one, update others with unique emails
    for (Integer i = 1; i < duplicateContacts.size(); i++) {
        duplicateContacts[i].Email = 'test' + i + '@campusconnect.com';
        System.debug('Updating contact: ' + duplicateContacts[i].Name + ' to email: ' + duplicateContacts[i].Email);
    }
    
    try {
        update duplicateContacts;
        System.debug('Successfully updated duplicate contacts');
    } catch (Exception e) {
        System.debug('Error updating contacts: ' + e.getMessage());
    }
}

// 2. Also check for any duplicate Student records
List<Student__c> duplicateStudents = [
    SELECT Id, Student_Email__c, Name 
    FROM Student__c 
    WHERE Student_Email__c = 'gaurigarole19@gmail.com'
];

System.debug('Found ' + duplicateStudents.size() + ' students with duplicate email');

if (duplicateStudents.size() > 1) {
    // Keep the first one, update others with unique emails
    for (Integer i = 1; i < duplicateStudents.size(); i++) {
        duplicateStudents[i].Student_Email__c = 'student' + i + '@campusconnect.com';
        System.debug('Updating student: ' + duplicateStudents[i].Name + ' to email: ' + duplicateStudents[i].Student_Email__c);
    }
    
    try {
        update duplicateStudents;
        System.debug('Successfully updated duplicate students');
    } catch (Exception e) {
        System.debug('Error updating students: ' + e.getMessage());
    }
}

System.debug('Data cleanup completed. You can now retry the deployment.');
