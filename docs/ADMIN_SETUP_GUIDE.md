# CampusConnect Administrator Setup Guide
*Complete Configuration & Deployment Guide*

## 📋 Table of Contents
1. [Pre-Installation Requirements](#pre-installation-requirements)
2. [Installation Steps](#installation-steps)
3. [Initial Configuration](#initial-configuration)
4. [User Management](#user-management)
5. [Data Import](#data-import)
6. [Security Configuration](#security-configuration)
7. [System Maintenance](#system-maintenance)
8. [Troubleshooting](#troubleshooting)

---

## 🔧 Pre-Installation Requirements

### Salesforce Environment
- **Salesforce Edition:** Professional, Enterprise, or Developer Edition
- **API Access:** Required for integrations
- **Storage:** Minimum 1GB available data storage
- **User Licenses:** Sufficient licenses for all users

### Required Permissions
- **System Administrator** profile
- **Customize Application** permission
- **Manage Users** permission
- **Import Custom Objects** permission

### Browser Requirements
- **Chrome** 90+ (Recommended)
- **Firefox** 88+
- **Safari** 14+
- **Edge** 90+

---

## 🚀 Installation Steps

### Step 1: Deploy Metadata
```bash
# Using Salesforce CLI
sf project deploy start --source-dir force-app/main/default --target-org your-org-alias

# Using VS Code with Salesforce Extensions
# Right-click on force-app folder → SFDX: Deploy Source to Org
```

### Step 2: Verify Deployment
1. Check **Setup** → **Custom Objects** for:
   - Student__c
   - Course__c
   - Event__c
   - Attendance__c
   - Enrollment__c

2. Verify **Lightning Web Components**:
   - studentAttendanceGauge
   - studentAttendanceAlert
   - eventSearchLWC
   - quickNotesLWC
   - upcomingEventsLWC

3. Check **Flows**:
   - Student At Risk Notification Flow
   - Event Registration Flow
   - Attendance Alert Flow

### Step 3: Activate Lightning Pages
1. Go to **Setup** → **Lightning App Builder**
2. Find and activate:
   - Enhanced Student Record Page
   - Course Management Page
   - Event Dashboard Page

---

## ⚙️ Initial Configuration

### Custom Settings Configuration

**1. System Settings**
```
Setup → Custom Settings → CampusConnect Settings → Manage
- Attendance Threshold: 75%
- Alert Email Template: Low_Attendance_Alert
- Academic Year Start: September 1
- Default Time Zone: Your Institution's Time Zone
```

**2. Email Templates**
Navigate to **Setup** → **Email Templates** and configure:
- Low Attendance Alert Template
- Event Registration Confirmation
- Welcome New Student Template
- Faculty Assignment Notification

### Permission Sets
**Create and assign permission sets:**

**1. Faculty Permission Set**
```
Object Permissions:
- Student__c: Read, Edit (limited fields)
- Course__c: Read, Edit (assigned courses only)
- Attendance__c: Create, Read, Edit, Delete
- Event__c: Read

Field-Level Security:
- Restrict sensitive student information
- Allow attendance marking fields
```

**2. Student Permission Set**
```
Object Permissions:
- Student__c: Read (own record only)
- Course__c: Read (enrolled courses only)
- Attendance__c: Read (own records only)
- Event__c: Read

Field-Level Security:
- Hide administrative fields
- Allow profile updates for specific fields
```

### Record Types (Optional)
Create record types for different student categories:
- Undergraduate Students
- Graduate Students
- Exchange Students
- Part-time Students

---

## 👥 User Management

### Creating User Accounts

**For Faculty:**
1. **Setup** → **Users** → **New User**
2. Fill required information
3. Assign **Faculty** profile
4. Add to **Faculty** permission set
5. Set role hierarchy appropriately

**For Students:**
1. Use bulk user creation for efficiency
2. Assign **Student Community** profile
3. Enable **Self-Registration** if needed
4. Configure **Single Sign-On** (SSO) if available

### Profile Configuration

**Student Profile Settings:**
```
Object Permissions:
- Student__c: Read (own record)
- Course__c: Read (enrolled courses)
- Event__c: Read
- Attendance__c: Read (own records)

Tab Settings:
- Make relevant tabs visible
- Hide administrative tabs

App Permissions:
- CampusConnect Student App: Enabled
```

**Faculty Profile Settings:**
```
Object Permissions:
- Student__c: Read, Edit (assigned students)
- Course__c: Read, Edit (assigned courses)
- Attendance__c: Full access
- Event__c: Read, Create (department events)

Tab Settings:
- All CampusConnect tabs visible
- Reports and Dashboards access

App Permissions:
- CampusConnect Faculty App: Enabled
```

---

## 📊 Data Import

### Student Data Import

**Using Data Import Wizard:**
1. **Setup** → **Data Import Wizard**
2. Choose **Custom Objects** → **Students**
3. Upload `demo-students.csv`
4. Map fields correctly:
   ```
   CSV Column → Salesforce Field
   First_Name → First_Name__c
   Last_Name → Last_Name__c
   Email → Student_Email__c
   Roll_Number → Roll_No__c
   Phone → Phone__c
   DOB → Date_of_Birth__c
   Major → Major__c
   Year → Year__c
   Status → Status__c
   GPA → GPA__c
   ```

**Using Data Loader (Bulk):**
1. Download and install Salesforce Data Loader
2. Configure connection to your org
3. Use `Insert` operation for new records
4. Map CSV columns to Salesforce fields
5. Run the import and verify results

### Course Data Import
```csv
Course_Name__c,Course_Code__c,Credits__c,Department__c,Faculty__c
Introduction to Computer Science,CS101,3,Computer Science,faculty@university.edu
Calculus I,MATH101,4,Mathematics,mathprof@university.edu
English Composition,ENG101,3,English,englishprof@university.edu
```

### Event Data Import
```csv
Event_Name__c,Event_Date__c,Event_Type__c,Location__c,Capacity__c
Orientation Week,2024-08-15,Academic,Main Auditorium,500
Career Fair,2024-09-20,Career,Student Center,1000
Homecoming,2024-10-15,Social,Football Stadium,5000
```

---

## 🔒 Security Configuration

### Field-Level Security
**Sensitive Student Information:**
- Social Security Number: Admin only
- Financial Information: Admin and Finance only
- Medical Information: Admin and Health Services only
- Academic Records: Admin and Faculty only

### Sharing Rules
**Student Records:**
```
Criteria-Based Sharing:
- Students can see their own records
- Faculty can see students in their courses
- Advisors can see their assigned students
```

**Course Records:**
```
Criteria-Based Sharing:
- Faculty can see courses they teach
- Students can see courses they're enrolled in
- Department heads can see all department courses
```

### IP Restrictions
Configure IP restrictions for sensitive operations:
- Data export operations
- Bulk data modifications
- User management functions

### Login Hours
Set appropriate login hours for different user types:
- Students: 24/7 access
- Faculty: Extended hours during academic periods
- Administrators: Business hours with emergency access

---

## 🔧 System Maintenance

### Regular Maintenance Tasks

**Daily:**
- Monitor system performance
- Check error logs
- Verify data backup completion
- Review user login issues

**Weekly:**
- Run data quality reports
- Check storage usage
- Review security logs
- Update documentation

**Monthly:**
- Performance optimization
- User access review
- Archive old records
- System health check

### Backup Strategy
**Data Backup:**
- Weekly full data export
- Daily incremental backups
- Metadata backup before deployments
- Store backups in secure, offsite location

**Recovery Procedures:**
1. Identify scope of data loss
2. Restore from most recent backup
3. Validate data integrity
4. Communicate with users
5. Document incident and lessons learned

### Performance Monitoring
**Key Metrics to Monitor:**
- Page load times
- API response times
- Storage usage
- User adoption rates
- Error rates

**Tools:**
- Salesforce Optimizer
- Event Monitoring
- Login History
- Setup Audit Trail

---

## 🔍 Troubleshooting

### Common Issues and Solutions

**Deployment Failures:**
```
Error: Field does not exist
Solution: Verify field API names match exactly
Check field-level security settings
```

**Permission Errors:**
```
Error: Insufficient privileges
Solution: Check profile permissions
Verify permission set assignments
Review sharing rules
```

**Data Import Issues:**
```
Error: Required field missing
Solution: Check CSV file format
Verify field mappings
Ensure all required fields have values
```

**Performance Issues:**
```
Symptoms: Slow page loads, timeouts
Solutions: 
- Optimize SOQL queries
- Review workflow rules
- Check data skew
- Consider selective queries
```

### Support Escalation
**Level 1 - Self Service:**
- Check documentation
- Review error messages
- Verify configuration

**Level 2 - Internal Support:**
- Contact system administrator
- Review with technical team
- Check with vendor documentation

**Level 3 - External Support:**
- Salesforce Support Case
- Consultant engagement
- Community forums

---

## 📞 Support Contacts

**Primary Administrator:**
- Name: [Your Name]
- Email: admin@campusconnect.edu
- Phone: (555) 123-4567

**Technical Team:**
- Email: tech-support@campusconnect.edu
- Emergency: (555) 999-9999

**Salesforce Support:**
- Partner Portal: Available 24/7
- Phone Support: Based on support plan
- Community: Trailblazer Community

---

## 📚 Additional Resources

**Documentation:**
- Salesforce Administrator Guide
- Lightning Platform Basics
- Security Implementation Guide

**Training:**
- Trailhead Modules
- Salesforce Certification Paths
- CampusConnect Specific Training

**Best Practices:**
- Regular system audits
- User feedback collection
- Continuous improvement process
- Change management procedures

---

*Last Updated: September 2024*
*Version: 1.0*
*Next Review Date: December 2024*
