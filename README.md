# 🎓 CampusConnect
![Salesforce](https://img.shields.io/badge/Salesforce-Lightning-blue)  
![API Version](https://img.shields.io/badge/API%20Version-Latest-brightgreen)  
![License](https://img.shields.io/badge/License-Educational-orange)  

CampusConnect is a next-gen **Salesforce CRM solution** for higher education that streamlines **student management, faculty coordination, attendance tracking, and event engagement**.  
Built with **Lightning Web Components (LWC)**, powerful **Apex automation**, and **real-time dashboards**, it empowers campuses with smarter decision-making.  

---
## 🎥 Project Demo  
📺 **Live Demo Video:** [CampusConnect System Walkthrough](https://drive.google.com/file/d/1CBoI1GV6qiP_kZP-8bwXLvo7M5cogsb2/view?usp=drivesdk)  

*Watch the complete system demonstration showcasing all features, user interfaces, and workflows in action.*  

---
## 📊 Project Status  

✅ **Production Ready** – Fully deployed and operational with >90% test coverage  

- **Core System:** Student & faculty records, courses, lectures, and attendance workflows  
- **Automation:** Email alerts for <75% attendance, duplicate record validation  
- **Dashboards:** Real-time attendance distribution, at-risk monitoring, event search  
- **Data Imports:** Preloaded with **50 students, 50 faculty, 50 attendance records, 50 events**  

---
## 📌 Project Overview

CampusConnect centralizes student data, automates attendance tracking, and integrates **external verification systems**. Built using **Lightning Web Components (LWC)**, **Apex classes**, and Salesforce automation tools, it delivers a **scalable and user-friendly solution** for educational institutions. 🏫

---

## 🌟 Core System Features
- **Attendance Management:** Real-time tracking, alerts for at-risk students, and automated notifications.
- **Event Management:** Event creation, registration workflows, and post-event feedback collection.
- **AI Insights:** Student risk scoring, engagement prediction, and attendance analytics.
- **Automation:** Apex triggers for capacity, attendance updates, and task creation.
- **Analytics:** Real-time dashboards and reports for administrators and faculty.
- **Integration:** Web-to-Lead forms, batch processing, and email notifications.

---

## 📚 Documentation & Guides
- **Phase 1:** Requirements & Analysis → `Phase 1/Phase_1.pdf`
- **Phase 2:** Data Model & Architecture → `Phase 2/Phase_2.pdf`
- **Phase 3:** Business Logic & Automation → `Phase 3/Phase_3.pdf`
- **Phase 4:** Batch Processing & Scheduling → `Phase 4/`
- **Phase 5:** Testing & Quality Assurance → `Phase 5/`
- **Phase 6:** User Interface Development → `Phase 6/`
- **Phase 7:** Integration & Workflows → `Phase 7/`
- **Phase 8:** Deployment & Data Management → `Phase 8/`
- **Phase 9:** Analytics & Security → `Phase 9/`
- **Phase 10:** AI Insights & Optimization → `Phase 10/`
- **Security Guide:** `docs/Security_Configuration_Guide.md`
- **Data Management:** `data/Data_Loader_Configuration_Guide.md`
- **Sample Data:** `data/sample_data.csv`

---

## 🏢 Project Overview
**Industry:** Higher Education / Campus Management  
**Project Type:** B2C Salesforce CRM Implementation  
**Target Users:** Teachers, Students, Administrators, Academic Coordinators  

**Problem Statement:**  
Educational institutions struggle with manual attendance tracking, fragmented event management, and lack of actionable insights. This causes:

- Mismanagement of student engagement and attendance  
- Poor visibility into academic performance  
- Delays in notifications and feedback loops  
- Inefficient lead nurturing for events and courses  

**CampusConnect Solution:**  
A unified Salesforce platform that automates attendance, events, and engagement with AI-driven insights and seamless UI.

---

## 🚀 Key Features

### 📊 Core Data Model
- **Student__c:** Tracks student details, preferences, and attendance history  
- **Attendance__c:** Daily attendance tracking with status and notes  
- **Event__c:** Complete lifecycle of campus events, capacity, and registration  
- **Registration__c:** Junction object connecting students with events  
- **Feedback__c:** Event feedback and ratings  
- **AI_Insights__c:** Stores AI-generated risk scores and engagement predictions  

### ⚡ Intelligent Automation
- **AttendanceTrigger:** Auto updates student attendance and alerts faculty  
- **EventRegistrationBatch:** Bulk student registrations with validation  
- **SmartEmailSystem:** Dynamic emails based on attendance and registration  
- **TaskCreation:** Automatic task assignments for follow-ups  
- **LeadConversion:** Convert prospects/registrations to student records automatically  

### 🎨 Modern User Interface (Lightning Web Components)
- **attendanceDashboard:** Real-time student attendance analytics  
- **eventRegistration:** Bulk event registration with CSV import  
- **lowAttendanceAlerts:** Proactive alerts for low attendance events  
- **studentSelector:** AI-powered student targeting for notifications  

### 🤖 AI-Powered Features
- **Student Risk Scoring:** Predict at-risk students using historical attendance & engagement  
- **Event Recommendations:** Suggest events based on student interests  
- **Capacity Optimization:** Predict optimal student-event allocations  
- **A/B Testing Framework:** Optimize registration workflows and notifications  

### 📧 Marketing & Engagement
- **Web-to-Lead Integration:** Capture prospective students or event attendees  
- **Email Campaigns:** Targeted invitations, reminders, and follow-ups  
- **Lead Nurturing:** Automatic workflows for engagement & conversion  

### 📈 Analytics & Reporting
- **Dashboards:** Real-time attendance and event performance  
- **Custom Reports:** Attendance trends, student engagement, event registrations  
- **Revenue & Capacity Tracking:** Track event fees and capacity utilization  

### 🔐 Enterprise Security
- **Role-Based Access:** Admin, Teacher, Coordinator roles with granular permissions  
- **GDPR Compliance:** Data privacy and consent management  
- **IP Restrictions:** Security for admin and sensitive access  

---

## 📁 Project Structure
CampusConnect/
├── force-app/main/default/
│ ├── classes/
│ │ ├── AttendanceTriggerHandler.cls
│ │ ├── EventRegistrationBatch.cls
│ │ ├── StudentRiskAnalyzer.cls
│ │ └── SmartEmailSystem.cls
│ ├── lwc/
│ │ ├── attendanceDashboard/
│ │ ├── eventRegistration/
│ │ ├── lowAttendanceAlerts/
│ │ └── studentSelector/
│ ├── objects/
│ │ ├── Student__c/
│ │ ├── Attendance__c/
│ │ ├── Event__c/
│ │ ├── Registration__c/
│ │ └── Feedback__c/
│ ├── triggers/
│ │ └── AttendanceTrigger.trigger
│ ├── flexipages/
│ │ └── Event_Record_Page.flexipage-meta.xml
│ ├── permissionsets/
│ │ ├── CampusConnect_Admin.permissionset-meta.xml
│ │ └── CampusConnect_Manager.permissionset-meta.xml
│ └── flows/
│ └── Send_Event_Invitations.flow-meta.xml
├── Phase 1/
├── Phase 2/
├── Phase 3/
├── Phase 4/
├── Phase 5/
├── Phase 6/
├── Phase 7/
├── Phase 8/
├── Phase 9/
├── Phase 10/
├── config/
├── data/
├── docs/
├── manifest/
├── scripts/
└── temp_flows/

---

## 💡 Usage Examples

### Attendance Management
```apex
// Mark student present
Attendance__c att = new Attendance__c(
    Student__c = 'a01...',
    Event__c = 'a02...',
    Status__c = 'Present',
    Date__c = Date.today()
);
insert att;

Bulk Event Registration

List<Registration__c> regs = EventRegistrationBatch.registerStudents(studentIds, eventId, false);
AI Risk Scoring

StudentRiskAnalyzer.calculateRisk(studentIds);
Email Notifications

SmartEmailSystem.sendAttendanceAlerts(studentIds);
🔧 Deployment & Configuration
Prerequisites
Salesforce CLI (sf)

Salesforce Dev Hub

Node.js 18+ and npm

Quick Start

# Login to Dev Hub
sf org login web --alias DevHub --set-default-dev-hub

# Create Scratch Org
sf org create scratch --definition-file config/project-scratch-def.json --alias CampusConnectScratch --duration-days 7 --set-default

# Deploy source
sf project deploy start --target-org CampusConnectScratch

# Assign Permission Sets
sf org assign permset --name CampusConnect_Admin --target-org CampusConnectScratch

# Open org
sf org open --target-org CampusConnectScratch
Post-Deploy Configuration
Assign roles & permissions

Configure Lightning Record Pages

Enable weekly summary scheduler

🟢 Colorful Action Buttons (Markdown Style)
🌟 Dashboard    📝 Attendance    📅 Events    📊 Analytics    ⚡ AI Insights

🆘 Support
For help:

Review documentation in Phase [1-10]/

Salesforce Trailhead for LWC and Apex

Developer Console for debugging

🤝 Contributing
Fork the repository

Create a feature branch: git checkout -b feature/amazing-feature

Commit changes: git commit -m 'Add amazing feature'

Push: git push origin feature/amazing-feature

Open a Pull Request

📄 License
CampusConnect is provided for educational and enterprise demonstration purposes.

Built with ❤️ using Salesforce Lightning Platform


**Email:** gaurigarole19@gmail.com  

---

