# CampusConnect Data Import Guide

## Data Import Wizard (50 Demo Students)

### Steps:
1. **Navigate to Setup → Data Import Wizard**
2. **Choose "Custom Objects" → "Students"**
3. **Select "Add new records"**
4. **Upload file**: `data/demo-students.csv`
5. **Map fields**:
   - First_Name__c → First Name
   - Last_Name__c → Last Name
   - Email__c → Email
   - Student_Number__c → Student Number
   - Phone__c → Phone
   - Date_of_Birth__c → Date of Birth
   - Status__c → Status
   - Major__c → Major
   - Year__c → Year
   - GPA__c → GPA
6. **Review and Start Import**

## Data Loader (Bulk Records)

### Prerequisites:
- Install Salesforce Data Loader
- Configure connection to your org
- Ensure Student and Course records exist before importing Attendance

### Import Events (50 records):
1. **Open Data Loader → Insert**
2. **Select Object**: Event__c
3. **Choose CSV file**: `data/bulk-events.csv`
4. **Map fields** and **Insert**

### Import Attendance (100+ records):
1. **First, export Student and Course IDs**:
   ```sql
   SELECT Id, Student_Number__c FROM Student__c
   SELECT Id, Course_Code__c FROM Course__c
   ```
2. **Update `bulk-attendance.csv`** with actual Salesforce IDs
3. **Data Loader → Insert**
4. **Select Object**: Attendance__c
5. **Choose updated CSV file** and **Insert**

## Field Mapping Reference

### Student Fields:
- `First_Name__c` - Text(50)
- `Last_Name__c` - Text(50)
- `Email__c` - Email(100)
- `Student_Number__c` - Text(20) - External ID
- `Phone__c` - Phone(20)
- `Date_of_Birth__c` - Date
- `Status__c` - Picklist (Active, Inactive, Graduated, Withdrawn)
- `Major__c` - Text(100)
- `Year__c` - Picklist (Freshman, Sophomore, Junior, Senior)
- `GPA__c` - Number(3,2)

### Event Fields:
- `Name` - Text(80)
- `Event_Date__c` - Date
- `Event_Time__c` - Time
- `Event_Type__c` - Picklist
- `Location__c` - Text(100)
- `Description__c` - Long Text Area
- `Max_Capacity__c` - Number(18,0)
- `Status__c` - Picklist

### Attendance Fields:
- `Student__c` - Lookup(Student__c)
- `Course__c` - Lookup(Course__c)
- `Date__c` - Date
- `Status__c` - Picklist (Present, Absent, Late, Excused)
- `Notes__c` - Long Text Area

## Data Validation

After import, verify:
1. **Student records** have unique Student Numbers
2. **Email addresses** are valid and unique
3. **Attendance records** link to existing Students and Courses
4. **Event dates** are in the future for scheduled events
5. **Duplicate rules** are preventing duplicate entries

## Troubleshooting

### Common Issues:
- **Date format errors**: Use YYYY-MM-DD format
- **Lookup failures**: Ensure referenced records exist
- **Duplicate detection**: Check duplicate rules are active
- **Field mapping**: Verify API names match exactly

### Error Resolution:
1. **Download error file** from import results
2. **Fix data issues** in CSV
3. **Re-import** corrected records
4. **Use Data Loader** for complex lookups
