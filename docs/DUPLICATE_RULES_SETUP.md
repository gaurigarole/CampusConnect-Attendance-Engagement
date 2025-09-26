# CampusConnect Duplicate Rules Setup Guide

## Manual Setup Required (UI-Based)

Duplicate Rules and Matching Rules have complex metadata dependencies that require manual setup through the Salesforce UI.

## Setup Instructions

### Step 1: Create Matching Rules

#### Student Email Matching Rule
1. **Setup → Duplicate Management → Matching Rules**
2. **New Rule → Student**
3. **Rule Details**:
   - Label: `Student Email Match Rule`
   - Rule Name: `Student_Email_Match_Rule`
   - Description: `Matching rule for student email addresses`
4. **Matching Criteria**:
   - Field: `Email`
   - Matching Method: `Exact`
   - Blank Value Behavior: `Null Not Allowed`
5. **Save & Activate**

#### Student Number Matching Rule
1. **Setup → Duplicate Management → Matching Rules**
2. **New Rule → Student**
3. **Rule Details**:
   - Label: `Student Number Match Rule`
   - Rule Name: `Student_Number_Match_Rule`
   - Description: `Matching rule for student numbers`
4. **Matching Criteria**:
   - Field: `Student Number`
   - Matching Method: `Exact`
   - Blank Value Behavior: `Null Not Allowed`
5. **Save & Activate**

#### Course Code Matching Rule
1. **Setup → Duplicate Management → Matching Rules**
2. **New Rule → Course**
3. **Rule Details**:
   - Label: `Course Code Match Rule`
   - Rule Name: `Course_Code_Match_Rule`
   - Description: `Matching rule for course codes`
4. **Matching Criteria**:
   - Field: `Course Code`
   - Matching Method: `Exact`
   - Blank Value Behavior: `Null Not Allowed`
5. **Save & Activate**

### Step 2: Create Duplicate Rules

#### Student Email Duplicate Rule
1. **Setup → Duplicate Management → Duplicate Rules**
2. **New Rule → Student**
3. **Rule Details**:
   - Label: `Student Email Duplicate Rule`
   - Description: `Prevents duplicate students based on email address`
   - Record-Level Security: `Enforce Sharing Rules`
4. **Conditions**:
   - Filter Logic: `1`
   - Condition 1: `Email NOT EQUAL TO [blank]`
5. **Actions**:
   - On Create: `Allow` (Show Alert)
   - On Edit: `Allow` (Show Alert)
   - Alert Text: `You are creating a duplicate student record. A student with this email already exists.`
6. **Matching Rules**:
   - Add: `Student Email Match Rule`
   - Fields to Match: `Email → Email`
7. **Save & Activate**

#### Student Number Duplicate Rule
1. **Setup → Duplicate Management → Duplicate Rules**
2. **New Rule → Student**
3. **Rule Details**:
   - Label: `Student Number Duplicate Rule`
   - Description: `Prevents duplicate students based on student number`
   - Record-Level Security: `Enforce Sharing Rules`
4. **Conditions**:
   - Filter Logic: `1`
   - Condition 1: `Student Number NOT EQUAL TO [blank]`
5. **Actions**:
   - On Create: `Block`
   - On Edit: `Block`
   - Alert Text: `Duplicate student number detected. Student numbers must be unique.`
6. **Matching Rules**:
   - Add: `Student Number Match Rule`
   - Fields to Match: `Student Number → Student Number`
7. **Save & Activate**

#### Course Code Duplicate Rule
1. **Setup → Duplicate Management → Duplicate Rules**
2. **New Rule → Course**
3. **Rule Details**:
   - Label: `Course Code Duplicate Rule`
   - Description: `Prevents duplicate courses based on course code`
   - Record-Level Security: `Enforce Sharing Rules`
4. **Conditions**:
   - Filter Logic: `1`
   - Condition 1: `Course Code NOT EQUAL TO [blank]`
5. **Actions**:
   - On Create: `Block`
   - On Edit: `Block`
   - Alert Text: `Duplicate course code detected. Course codes must be unique.`
6. **Matching Rules**:
   - Add: `Course Code Match Rule`
   - Fields to Match: `Course Code → Course Code`
7. **Save & Activate**

## Verification Steps

### Test Student Email Duplicate Detection
1. **Create a student** with email `test@university.edu`
2. **Try to create another student** with the same email
3. **Should show warning** but allow creation

### Test Student Number Duplicate Prevention
1. **Create a student** with student number `TEST001`
2. **Try to create another student** with the same student number
3. **Should block creation** with error message

### Test Course Code Duplicate Prevention
1. **Create a course** with course code `CS101`
2. **Try to create another course** with the same course code
3. **Should block creation** with error message

## Expected Results

After setup, you should have:
- ✅ **3 Active Matching Rules** (Student Email, Student Number, Course Code)
- ✅ **3 Active Duplicate Rules** (Student Email, Student Number, Course Code)
- ✅ **Email duplicates warned** but allowed
- ✅ **Student number duplicates blocked**
- ✅ **Course code duplicates blocked**

## Troubleshooting

### Common Issues:
- **Matching Rule not found**: Ensure matching rules are created and activated first
- **Fields not available**: Verify custom fields exist on the objects
- **Rules not triggering**: Check that rules are activated and conditions are met

### Validation:
- **Setup → Duplicate Management → Matching Rules**: Should show 3 active rules
- **Setup → Duplicate Management → Duplicate Rules**: Should show 3 active rules
- **Test with actual data**: Create test records to verify functionality

## Alternative: Validation Rules

If duplicate rules are not working as expected, you can use validation rules as a backup:

### Student Number Uniqueness (Validation Rule)
```
AND(
  NOT(ISBLANK(Student_Number__c)),
  VLOOKUP($ObjectType.Student__c.Fields.Student_Number__c, 
          $ObjectType.Student__c.Fields.Student_Number__c, 
          Student_Number__c) <> Id
)
```

### Course Code Uniqueness (Validation Rule)
```
AND(
  NOT(ISBLANK(Course_Code__c)),
  VLOOKUP($ObjectType.Course__c.Fields.Course_Code__c, 
          $ObjectType.Course__c.Fields.Course_Code__c, 
          Course_Code__c) <> Id
)
```

Note: Validation rules provide blocking behavior but less sophisticated matching than duplicate rules.
