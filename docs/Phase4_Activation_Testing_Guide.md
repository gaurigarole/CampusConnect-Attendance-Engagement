# Phase 4 Activation & Testing Guide

## 🚀 Task 1: Activate Flows and Configure Settings

### Step 1: Activate Flows in Salesforce

#### Navigate to Flow Builder
1. Login to your Salesforce org: `gaurigarole19559@agentforce.com`
2. Go to **Setup** (gear icon) → **Flow Builder**
3. Or use Quick Find: Search "Flows" → Click **Flows**

#### Activate Student Attendance Alert Flow
1. Find `Student_Attendance_Alert_Flow` in the list
2. Click on the flow name
3. Click **Activate** button (top right)
4. Confirm activation
5. ✅ **Status should show: "Active"**

#### Activate Event Status Update Flow  
1. Find `Event_Status_Update_Flow` in the list
2. Click on the flow name
3. Click **Activate** button (top right)
4. Confirm activation
5. ✅ **Status should show: "Active"**

### Step 2: Verify Workflow Rules are Active

#### Check Student Workflow Rule
1. Setup → **Workflow Rules**
2. Find `Student__c.Low_Attendance_Alert_Rule`
3. Verify status is **Active**
4. If inactive, click **Activate**

### Step 3: Verify Email Deliverability Settings

#### Check Email Settings
1. Setup → **Email Administration** → **Deliverability**
2. Ensure **System email** is set to "All email"
3. Check **Access level** allows email sending

#### Verify Email Template
1. Setup → **Email Templates**
2. Navigate to **CampusConnect_Templates** folder
3. Verify `Low_Attendance_Alert` template exists
4. Click **Preview** to test template rendering

---

## 🧪 Task 2: Test Automation Scenarios

### Test Scenario 1: Low Attendance Alert Automation

#### Create Test Student Record
1. Go to **Student** tab
2. Click **New**
3. Fill in required fields:
   - **Name**: "Test Student - John Doe"
   - **Roll No**: "TEST001"
   - **Student Email**: Your email address (to receive test alert)
   - **Attendance Percentage**: `70` (below 75% threshold)
4. Click **Save**

#### Expected Results ✅
- **Status__c** should automatically update to "At Risk"
- Email alert should be sent to the student email address
- Check your email inbox for the alert

#### Verify Automation Worked
1. Refresh the Student record page
2. Check that **Status** field shows "At Risk"
3. Go to Setup → **Email Logs** to verify email was sent
4. Check Setup → **Debug Logs** for flow execution details

### Test Scenario 2: Event Status Update Automation

#### Create Test Event Record
1. Go to **Event** tab
2. Click **New**
3. Fill in required fields:
   - **Event Name**: "Test Event - Past Event"
   - **Date** (Start Date): Yesterday's date
   - **End Date**: Yesterday's date (later time)
   - **Status**: "Scheduled"
4. Click **Save**

#### Expected Results ✅
- **Status__c** should automatically update to "Completed"
- Flow should trigger on record save

#### Verify Automation Worked
1. Refresh the Event record page
2. Check that **Status** field shows "Completed"
3. Go to Setup → **Flow Builder** → **Event_Status_Update_Flow** → **Run History**
4. Verify successful flow execution

### Test Scenario 3: Validation Rules Testing

#### Test Attendance Future Date Validation
1. Go to **Attendance** tab
2. Click **New**
3. Fill in fields:
   - **Date**: Tomorrow's date (future date)
   - **Status**: "Present"
4. Click **Save**

#### Expected Results ✅
- **Error message** should appear: "Attendance cannot be marked for future dates"
- Record should NOT save
- User should be returned to edit mode

#### Test Event Date Validation
1. Go to **Event** tab
2. Click **New**
3. Fill in fields:
   - **Event Name**: "Invalid Event"
   - **Date** (Start): Today
   - **End Date**: Yesterday (before start date)
4. Click **Save**

#### Expected Results ✅
- **Error message** should appear: "Event End Date must be after the Start Date"
- Record should NOT save

### Test Scenario 4: Email Template Functionality

#### Test Email Template Rendering
1. Setup → **Email Templates**
2. Open `CampusConnect_Templates/Low_Attendance_Alert`
3. Click **Preview**
4. Select a Student record to merge data
5. Verify merge fields populate correctly:
   - `{!Student__c.Name}`
   - `{!Student__c.Attendance_Percentage__c}`
   - `{!Student__c.Status__c}`

#### Expected Results ✅
- Template should render with actual student data
- No merge field errors
- Professional email formatting

---

## 📊 Testing Checklist

### Flow Activation ✅
- [ ] Student_Attendance_Alert_Flow is Active
- [ ] Event_Status_Update_Flow is Active
- [ ] Workflow rules are Active

### Automation Testing ✅
- [ ] Low attendance triggers status update to "At Risk"
- [ ] Email alert sent for low attendance
- [ ] Event status auto-updates to "Completed"
- [ ] Future date attendance validation works
- [ ] Event date validation works
- [ ] Email template renders correctly

### System Verification ✅
- [ ] Debug logs show successful flow execution
- [ ] Email logs show successful delivery
- [ ] No system errors in Setup → System Overview

---

## 🔧 Troubleshooting Guide

### If Flows Don't Trigger
1. **Check Flow Status**: Ensure flows are "Active"
2. **Review Trigger Conditions**: Verify field values meet criteria
3. **Debug Logs**: Enable debug logs for your user
4. **Field Permissions**: Ensure user has edit access to trigger fields

### If Emails Don't Send
1. **Deliverability Settings**: Check Setup → Email Administration
2. **Email Logs**: Review Setup → Email Logs for errors
3. **Template Access**: Verify email template is available
4. **User Permissions**: Check "Send Email" permission

### If Validation Rules Don't Fire
1. **Rule Status**: Ensure validation rules are "Active"
2. **Formula Logic**: Test formula in Developer Console
3. **Field Types**: Verify field data types match formula
4. **User Permissions**: Check if user bypasses validation

---

## 📈 Success Metrics

After testing, you should see:
- **100%** flow execution success rate
- **Email delivery** within 1-2 minutes
- **Validation rules** preventing invalid data entry
- **Automatic status updates** working correctly

---

## 🎯 Next Steps After Testing

1. **Create More Test Data**: Test with multiple students and events
2. **User Training**: Train faculty on new automated features
3. **Monitor Performance**: Check system performance weekly
4. **Gather Feedback**: Collect user feedback for improvements

---

## 📋 Phase 4 Completion Verification

### All Components Working ✅
- [ ] Validation rules prevent bad data
- [ ] Flows execute automatically
- [ ] Email alerts reach recipients
- [ ] Status fields update correctly
- [ ] System logs show no errors

### Ready for Production ✅
- [ ] All test scenarios pass
- [ ] Performance is acceptable
- [ ] Users are trained
- [ ] Documentation is complete

**🎉 Phase 4 Complete!** Your CampusConnect system now has full process automation working correctly.
