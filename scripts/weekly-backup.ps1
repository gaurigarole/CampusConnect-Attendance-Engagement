# CampusConnect Weekly Backup Script
# Run this script every Sunday to backup key data

param(
    [string]$BackupPath = "C:\SalesforceProject\CampusConnect\backups\$(Get-Date -Format 'yyyy-MM-dd')"
)

# Create backup directory
New-Item -ItemType Directory -Path $BackupPath -Force

Write-Host "Starting CampusConnect Weekly Backup - $(Get-Date)" -ForegroundColor Green

# Export Student records
Write-Host "Exporting Student records..." -ForegroundColor Yellow
sf data export --query "SELECT Id, Name, First_Name__c, Last_Name__c, Email__c, Student_Number__c, Phone__c, Date_of_Birth__c, Status__c, Major__c, Year__c, GPA__c, External_Verification_Status__c, External_Verification_Date__c FROM Student__c" --output-file "$BackupPath\students_backup.csv"

# Export Course records
Write-Host "Exporting Course records..." -ForegroundColor Yellow
sf data export --query "SELECT Id, Name, Course_Code__c, Course_Name__c, Credits__c, Department__c, Semester__c, Year__c, Max_Enrollment__c, External_Course_Code__c, External_Credits__c, External_Sync_Date__c FROM Course__c" --output-file "$BackupPath\courses_backup.csv"

# Export Attendance records
Write-Host "Exporting Attendance records..." -ForegroundColor Yellow
sf data export --query "SELECT Id, Name, Student__c, Course__c, Date__c, Status__c, Notes__c FROM Attendance__c" --output-file "$BackupPath\attendance_backup.csv"

# Export Event records
Write-Host "Exporting Event records..." -ForegroundColor Yellow
sf data export --query "SELECT Id, Name, Event_Date__c, Event_Time__c, Event_Type__c, Location__c, Description__c, Max_Capacity__c, Status__c FROM Event__c" --output-file "$BackupPath\events_backup.csv"

# Export Faculty records
Write-Host "Exporting Faculty records..." -ForegroundColor Yellow
sf data export --query "SELECT Id, Name, First_Name__c, Last_Name__c, Email__c, Phone__c, Department__c, Title__c, Hire_Date__c FROM Faculty__c" --output-file "$BackupPath\faculty_backup.csv"

# Export Lecture records
Write-Host "Exporting Lecture records..." -ForegroundColor Yellow
sf data export --query "SELECT Id, Name, Course__c, Faculty__c, Date__c, Start_Time__c, End_Time__c, Location__c, Topic__c FROM Lecture__c" --output-file "$BackupPath\lectures_backup.csv"

# Export StudentCourse junction records
Write-Host "Exporting StudentCourse records..." -ForegroundColor Yellow
sf data export --query "SELECT Id, Name, Student__c, Course__c, Enrollment_Date__c, Status__c, Grade__c FROM StudentCourse__c" --output-file "$BackupPath\studentcourse_backup.csv"

# Export API Usage Log records (last 30 days)
Write-Host "Exporting API Usage Log records..." -ForegroundColor Yellow
sf data export --query "SELECT Id, Name, Service_Name__c, Endpoint__c, Response_Code__c, Response_Time_MS__c, Call_DateTime__c FROM API_Usage_Log__c WHERE Call_DateTime__c >= LAST_N_DAYS:30" --output-file "$BackupPath\api_usage_backup.csv"

# Create backup summary
$BackupSummary = @"
CampusConnect Data Backup Summary
Generated: $(Get-Date)
Backup Location: $BackupPath

Files Created:
- students_backup.csv
- courses_backup.csv
- attendance_backup.csv
- events_backup.csv
- faculty_backup.csv
- lectures_backup.csv
- studentcourse_backup.csv
- api_usage_backup.csv (last 30 days)

Backup completed successfully.
Next backup scheduled for: $(Get-Date (Get-Date).AddDays(7) -Format 'yyyy-MM-dd')

To restore data, use Data Loader or Data Import Wizard with these CSV files.
"@

$BackupSummary | Out-File -FilePath "$BackupPath\backup_summary.txt"

Write-Host "Backup completed successfully!" -ForegroundColor Green
Write-Host "Backup location: $BackupPath" -ForegroundColor Cyan
Write-Host "Summary file: $BackupPath\backup_summary.txt" -ForegroundColor Cyan

# Optional: Compress backup folder
if (Get-Command Compress-Archive -ErrorAction SilentlyContinue) {
    $ZipPath = "$BackupPath.zip"
    Compress-Archive -Path $BackupPath -DestinationPath $ZipPath -Force
    Write-Host "Backup compressed to: $ZipPath" -ForegroundColor Cyan
}
