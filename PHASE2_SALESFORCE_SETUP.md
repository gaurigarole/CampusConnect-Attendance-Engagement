# 📘 Phase 2: Salesforce Objects, Fields & Relationships  

## 1. Custom Objects Created  
1. **Campus Student**  
   - Label: Campus Student  
   - Plural Label: Campus Students  
   - API Name: `Campus_Student__c`  

2. **Faculty**  
   - Label: Faculty  
   - Plural Label: Faculties  
   - API Name: `Faculty__c`  

3. **Course**  
   - Label: Course  
   - Plural Label: Courses  
   - API Name: `Course__c`  

4. **Attendance**  
   - Label: Attendance  
   - Plural Label: Attendance Records  
   - API Name: `Attendance__c`  

5. **Event**  
   - Label: Event  
   - Plural Label: Events  
   - API Name: `Event__c`  

---

## 2. Fields for Each Object  

### 📍 Campus Student  
- **Name** (Auto)  
- Roll Number (Text)  
- Email (Email)  
- Phone Number (Phone)  
- Department (Picklist)  
- Year (Picklist: FE, SE, TE, BE)  

### 📍 Faculty  
- **Name** (Auto)  
- Faculty ID (Text)  
- Email (Email)  
- Phone (Phone)  
- Department (Picklist)  

### 📍 Course  
- **Name** (Auto)  
- Course Code (Text)  
- Credits (Number)  
- Department (Picklist)  
- Faculty Incharge (Lookup → Faculty)  

### 📍 Attendance  
- **Name** (Auto)  
- Date (Date)  
- Status (Picklist: Present, Absent, Late)  
- Student (Lookup → Campus Student)  
- Course (Lookup → Course)  

### 📍 Event  
- **Name** (Auto)  
- Event Type (Picklist: Seminar, Workshop, Competition, Fest)  
- Date (Date)  
- Venue (Text)  
- Organized By (Lookup → Faculty)  

---

## 3. Relationships Between Objects  

- **Attendance → Campus Student** (Lookup)  
- **Attendance → Course** (Lookup)  
- **Course → Faculty** (Lookup, “Course Incharge”)  
- **Event → Faculty** (Lookup, “Organizer”)  

This ensures:  
- Each **Attendance** record links to a Student + Course.  
- Each **Course** can have one Faculty incharge.  
- Each **Event** can be linked to one Faculty organizer.  

---

## 4. Tabs Created for Easy Navigation  

Custom tabs created:  
- Campus Student Tab  
- Faculty Tab  
- Course Tab  
- Attendance Tab  
- Event Tab  

👉 These tabs were **added to the Lightning App** so they appear in the navigation bar for quick access.  

---

## 5. Summary of Phase 2 Work  

✔️ Created 5 custom objects (Campus Student, Faculty, Course, Attendance, Event)  
✔️ Added necessary fields for each object  
✔️ Established relationships using Lookup fields  
✔️ Created custom tabs for each object  
✔️ Added tabs to the CampusConnect Lightning App for better navigation  

---

📂 This document is part of **Phase 2 implementation** for the Salesforce Project:  
**CampusConnect – Student Attendance & Engagement Hub**
