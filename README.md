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
## 📁 Project Structure  

```plaintext
CampusConnect/
├── .husky/                # Husky config
├── .vscode/               # VS Code settings
├── Phase 1/               # Requirement Analysis
├── Phase 2/               # Data Model & System Design
├── Phase 3/               # Automation & Apex
├── Phase 4/               # Deployment
├── Phase 5/               # Testing
├── Phase 6/               # UI Development
├── Phase 7/               # LWC Components
├── Phase 8/               # Reports, Dashboards, Security
├── Phase 9/               # Final Documentation
├── config/                
├── data/                  # Demo datasets
├── docs/                  # Documentation files
├── force-app/main/default # Salesforce source files
├── manifest/              
├── scripts/               
├── temp_flows/            
├── .forceignore           
├── .gitignore             
├── .prettierignore        
├── .prettierrc            
├── README.md              
├── eslint.config.js       
├── jest.config.js         
├── package.json           
├── sf project deploy ...  
└── sfdx-project.json      


## 🌟 Key Features

- **Student Management** 👩‍🎓  
  - Add, view, and manage student records  
  - Track roll number, email, attendance %, and enrolled courses  

- **Event & Attendance Management** 📅  
  - Create and manage campus events  
  - Real-time attendance tracking with visual progress rings  
  - Low Attendance Alerts for students below 75%  

- **Integrations & Automation** 🔗  
  - Secure API-based verification for students and courses  
  - Platform Events for at-risk student notifications  
  - Change Data Capture for automated updates  

- **Data Management** 💾  
  - Bulk data import using Data Import Wizard & Data Loader  
  - Duplicate prevention rules to ensure data integrity  
  - Weekly automated backups with restore documentation  

- **Reporting & Dashboards** 📊  
  - Attendance distribution dashboards  
  - At-risk student reports  
  - Dynamic dashboards filtered by faculty  

- **Security & Access Control** 🔒  
  - Sharing rules for controlled record access  
  - Field-level security for sensitive data  
  - Session timeout & login IP restrictions  
  - Audit trail for tracking changes  

- **Deployment & DevOps** ⚡  
  - VS Code + SFDX for deployment  
  - Unmanaged packages for sandbox deployment  
  - Command-line & ANT migration tool support  

---

## 🧩 System Design

- **Front-end:** Lightning Web Components (LWC) for intuitive UI  
- **Back-end:** Apex classes for business logic & integrations  
- **Data Layer:** Salesforce objects (Student, Event, Attendance, Course)  
- **Automation:** Platform Events, Change Data Capture, Scheduled Jobs  
- **Integrations:** External APIs for verification & synchronization  

---

## 📋 User Guide

- **Campus Dashboard:** Attendance overview & at-risk students list  
- **Student Search:** View student profile, attendance, courses, and alerts  
- **Event Search:** Manage and enroll students in events  
- **Quick Actions:** Mark Attendance, Send Email  
- **Reports & Dashboards:** Analyze attendance trends and student risk  
- **Backup & Restore:** Run automated weekly backups to ensure data safety  

---

## 🎯 Benefits

- Centralized student & event management  
- Early identification of at-risk students  
- Secure and controlled data access  
- Scalable, professional Salesforce deployment  
- Automated processes reduce errors and improve efficiency  

---

## 📧 Contact

**Developer:** Gauri Garole  
**Email:** gaurigarole19@gmail.com  

---

