# CampusConnect – Student Attendance & Engagement Hub

This repository contains Phase 3 deliverables for CampusConnect implemented as Salesforce DX metadata. Phase 3 focuses on Record Types, Page Layouts, Compact Layouts, Relationships, and documentation to improve usability and the data model.

## ✅ Phase 3 Summary

- ✅ `Lecture__c` custom object with two Record Types: `Online_Lecture`, `Offline_Lecture` (controls `Mode__c` picklist).
- ✅ Junction object `StudentCourse__c` (many-to-many Student ↔ Course) with two Master-Detail fields.
- ✅ Master-Detail: `Attendance__c.Student__c` (Attendance record belongs to Student).
- ✅ Lookup: `Lecture__c.Faculty__c` (Lecture assigned to a Faculty).
- ✅ Hierarchical relationship field on User: `Supervisor__c`.
- ✅ User role picklist: `Campus_Role__c` (Student, Faculty, Administrator) to emulate User Record Type variability.
- ✅ Page Layouts: Student, Faculty, Course, Lecture, plus three User layouts (Student/Faculty/Administrator).
- ✅ Compact Layouts: Student, Faculty, Lecture and assigned to their objects.
- ✅ Tabs added: `Lecture__c`, `StudentCourse__c`.
- ✅ Sharing models aligned: detail/junction set to ControlledByParent where applicable.

Notes
- The standard User object does not support Record Types in Salesforce. To meet the “Student / Faculty / Administrator on User” requirement, this project provides a `Campus_Role__c` picklist and three dedicated User page layouts. Assign these layouts to profiles to get per-role experiences.
- “Business Processes” only apply to specific standard objects (Leads, Cases, Opportunities, Solutions). They aren’t applicable to `Lecture__c`.

## Repository Structure (Phase 3 highlights)

- `force-app/main/default/objects/Lecture__c/`
  - `Lecture__c.object-meta.xml`
  - `fields/Mode__c.field-meta.xml`, `fields/Faculty__c.field-meta.xml`, `fields/Scheduled_At__c.field-meta.xml`
  - `recordTypes/Online_Lecture.recordType-meta.xml`, `recordTypes/Offline_Lecture.recordType-meta.xml`
  - `compactLayouts/Lecture_Compact.compactLayout-meta.xml`
- `force-app/main/default/objects/StudentCourse__c/`
  - `StudentCourse__c.object-meta.xml`
  - `fields/Student__c.field-meta.xml` (MD to Student__c)
  - `fields/Course__c.field-meta.xml` (MD to Course__c)
- `force-app/main/default/objects/Attendance__c/fields/Student__c.field-meta.xml` (MD to Student__c)
- `force-app/main/default/objects/Student__c/fields/` includes `Roll_No__c`, `Attendance_Percentage__c`
- `force-app/main/default/objects/Faculty__c/compactLayouts/Faculty_Compact.compactLayout-meta.xml`
- `force-app/main/default/layouts/`
  - `Student__c-Student Layout.layout-meta.xml` (shows Attendance and StudentCourse related lists)
  - `Faculty__c-Faculty Layout.layout-meta.xml` (shows related `Lecture__c` list)
  - `Course__c-Course Layout.layout-meta.xml` (shows `StudentCourse__c` related list)
  - `Lecture__c-Lecture Layout.layout-meta.xml`
  - `User-Student User Layout.layout-meta.xml`, `User-Faculty User Layout.layout-meta.xml`, `User-Administrator User Layout.layout-meta.xml`
- `force-app/main/default/tabs/Lecture__c.tab-meta.xml`, `tabs/StudentCourse__c.tab-meta.xml`
- `force-app/main/default/objects/User/fields/` contains `Campus_Role__c`, `Supervisor__c`

## Relationships Implemented (with examples)

- Lookup: `Lecture__c.Faculty__c`
  - Example: A lecture “Intro to AI” is linked to Faculty “Dr. Rao”.
- Master-Detail: `Attendance__c.Student__c`
  - Example: Attendance entries roll up under each Student (sharing controlled by parent).
- Hierarchical (User → User): `User.Supervisor__c`
  - Example: Administrator supervises Faculty, Faculty supervises Student assistants.
- Junction: `StudentCourse__c` between `Student__c` and `Course__c`
  - Example: A student is enrolled in many courses, and each course has many students.

## Page Layouts

- Student__c – shows core student info plus related lists:
  - Attendance__c (fields: Name, Course, Date, Status)
  - StudentCourse__c (fields: Name, Course)
- Faculty__c – shows core faculty info and related Lectures (Mode, Scheduled At)
- Course__c – shows related StudentCourse junction records
- Lecture__c – shows Mode, Faculty, Scheduled At
- User – three layouts (Student, Faculty, Administrator) surface `Campus_Role__c` and `Supervisor__c`

## Compact Layouts

- Student_Compact – Name, Roll No, Attendance %, Email
- Faculty_Compact – Name, Department, Email, Phone
- Lecture_Compact – Name, Mode, Faculty, Scheduled At

## Setup & Deployment

1) Authenticate to your Dev org

Using the newer `sf` CLI:
sf org login web -a campusconnect-dev

Or using legacy `sfdx` CLI:
sfdx force:auth:web:login -a campusconnect-dev

2) Deploy all metadata in this repo (source format)

Using `sf` CLI:
sf project deploy start -d force-app -o campusconnect-dev

Or using `sfdx` CLI:
sfdx force:source:deploy -p force-app -u campusconnect-dev

3) Profile & layout assignments

- User Record Types are not supported. Use the `Campus_Role__c` picklist to categorize users.
- Assign the three User page layouts to the appropriate profiles (Student, Faculty, Administrator) via Setup:
  - Setup → Object Manager → User → Page Layouts → Page Layout Assignment → Edit Assignment
  - Map profiles to `User-Student User Layout`, `User-Faculty User Layout`, `User-Administrator User Layout`.
- If you maintain dedicated custom profiles for Student/Faculty/Admin, also confirm object permissions for Student__c, Faculty__c, Course__c, Lecture__c, Attendance__c, StudentCourse__c.

4) Assign Lecture record types to profiles

- Setup → Object Manager → Lecture → Record Types → Assign to Profiles
- Ensure both `Online_Lecture` and `Offline_Lecture` are visible to relevant profiles.

## Schema Builder Diagram (add to repo)

Use Schema Builder to visualize objects and relationships:
- Setup → Object Manager → Schema Builder
- Include: Student__c, Faculty__c, Course__c, Lecture__c, Attendance__c, StudentCourse__c, User
- Take a screenshot and save it as `docs/Phase3_Schema.png`
- Commit the file to this repository and reference it in issues/PRs.

## How Phase 3 Improves CampusConnect

- ✅ Clear role-driven UX via User layouts and Campus_Role picklist
- ✅ Faster record previews with compact layouts
- ✅ Accurate data model for attendance and enrollment with MD and junction relationships
- ✅ Better reporting with Lectures linked to Faculty and Students linked to Courses
- ✅ Governance-ready metadata with SFDX source and deploy scripts

---

## 🚀 Phase 4: Process Automation (NEW)

Phase 4 implements comprehensive process automation using Salesforce's declarative tools:

- ✅ **Validation Rules**: Attendance future date checks, event date validation
- ✅ **Record-Triggered Flows**: Attendance alerts, event status updates
- ✅ **Screen Flows**: Faculty attendance marking interface
- ✅ **Approval Processes**: Course enrollment and special leave approvals
- ✅ **Email Alerts**: Low attendance notifications, faculty alerts
- ✅ **Field Updates**: Automatic status updates based on business rules
- ✅ **Tasks & Notifications**: Faculty follow-up tasks, student event reminders

📖 **[View Complete Phase 4 Documentation](docs/Phase4_Process_Automation.md)**

### Quick Phase 4 Setup
1. Deploy the new metadata: `sf project deploy start -d force-app -o YourOrgAlias`
2. Activate flows in Setup → Flow Builder
3. Configure approval processes and assign approvers
4. Test automation with sample data

---

If you have any questions or want to extend to Phase 5 (e.g., Lightning Web Components, custom apps, or advanced integrations), open an issue or start a new phase work item.

---

## 🚀 Phase 6: User Interface Development

This phase adds a Campus Dashboard, searchable students and events, an At-Risk students view, and a Utility Bar for quick actions.

### Components Added

- `force-app/main/default/lwc/studentSearchLWC/` – Search by Name or Roll No; color indicators for Status; row actions to View or Select; sortable columns.
- `force-app/main/default/lwc/atRiskStudentsLWC/` – Card view of students with `Status__c = At Risk` including email and attendance %.
- `force-app/main/default/lwc/eventSearchLWC/` – Search events by date range; enroll the selected student (creates an `Attendance__c`); sortable columns.
- `force-app/main/default/lwc/upcomingEventsLWC/` – Lists scheduled events in next 7 days.
- `force-app/main/default/lwc/attendanceDistributionLWC/` – Progress rings showing Regular vs At Risk vs Probation counts.
- `force-app/main/default/lwc/campusDashboardLWC/` – Container dashboard coordinating student selection and event enrollment.
- `force-app/main/default/lwc/dashboardQuickLinksLWC/` – Quick links for New Student and New Attendance.
- `force-app/main/default/lwc/attendanceQuickCreateLWC/` – Utility bar quick create form for Attendance; also available as an Event record quick action.
- `force-app/main/default/lwc/quickNotesLWC/` – Utility bar notes and Help link.

### Apex

- `force-app/main/default/classes/StudentController.cls` – `searchStudents`, `getAtRiskStudents`, `getAttendanceDistribution` (+ tests in `StudentControllerTest.cls`).
- `force-app/main/default/classes/EventController.cls` – `searchEvents`, `getScheduledEventsWithin7Days`, `enrollStudentInEvent` (+ tests in `EventControllerTest.cls`).

### Lightning Pages

- App Page: `force-app/main/default/flexipages/Campus_Dashboard.flexipage-meta.xml` (uses `campusDashboardLWC`).
- Home Page: `force-app/main/default/flexipages/Campus_Home.flexipage-meta.xml` (assign as Home for the app).
- Student Record Page: `force-app/main/default/flexipages/Student_Record_Page.flexipage-meta.xml` (Highlights + Related Lists).
- Event Record Page: `force-app/main/default/flexipages/Event_Record_Page.flexipage-meta.xml` (Highlights + Related Lists).
- Utility Bar: `force-app/main/default/flexipages/Campus_UtilityBar.flexipage-meta.xml` (Quick Notes, Attendance Quick Create). Linked in `applications/CampusConnect.app-meta.xml`.

### Deploy

1. Authenticate to your org (if not already):
   - `sf org login web -a campusconnect-dev`
2. Deploy all metadata:
   - `sf project deploy start -d force-app -o campusconnect-dev`
3. Run Apex tests (ensures >75% coverage):
   - `sf apex run test -o campusconnect-dev -c -r human -w 10`

### Activate in Lightning App Builder

1. Campus Home as Home page
   - Setup → App Builder → Open `Campus Home` → Activate → Assign as App Default → Choose `CampusConnect`.
2. Campus Dashboard App Page (optional tab)
   - Setup → App Builder → Open `Campus Dashboard` → Save (you can create a Lightning Page tab to add to nav if desired).
3. Record pages
   - Setup → App Builder → Open `Student Record Page` → Activate → Assign as App Default for `CampusConnect`.
   - Setup → App Builder → Open `Event Record Page` → Activate → Assign as App Default for `CampusConnect`.
4. Utility Bar
   - The application `CampusConnect` already references `Campus_UtilityBar`. Confirm under Setup → App Manager → CampusConnect → Edit → Utility Bar.

### Navigation & Tabs

- The `CampusConnect` app navigation is ordered with `Home` first, then `Students`, `Attendance Records`, `Faculties`, `Courses`, `Events`, `Lectures`, and `StudentCourse__c`.

### Usage Tips

- On the dashboard, select a student in `StudentSearchLWC`, then use `EventSearchLWC` to enroll them—this creates an `Attendance__c` and navigates you to it.
- Quick actions live in the Utility Bar: create attendance and take notes; the card links to Salesforce Help.
