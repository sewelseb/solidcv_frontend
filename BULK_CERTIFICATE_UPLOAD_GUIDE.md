# Bulk Certificate Upload - Excel Template Format

## Overview

The bulk certificate upload feature allows education institutions to create multiple certificates at once by uploading an Excel file containing student and certificate information.

## Required Excel Format

### Column Headers (First Row)

Your Excel file must include the following columns in the first row:

| Column | Required | Description | Example |
|--------|----------|-------------|---------|
| Student Email | ✅ Required | Valid email address of the student | john.doe@university.edu |
| Student Firstname | ✅ Required | First name of the student | John |
| Student Lastname | ✅ Required | Last name of the student | Doe |
| Certificate Title | ✅ Required | Name/title of the certificate | Bachelor of Computer Science |
| Issue Date | ❌ Optional | Date when certificate was issued (YYYY-MM-DD) | 2024-06-15 |
| Description | ❌ Optional | Additional details about the certificate | Graduated with honors |
| Garde/Score | ❌ Optional | Grade or score achieved | A+ / 95% / 3.8 GPA |
| Certificate File Name | ❌ Optional | Reference name for the certificate file | john_doe_bcs_2024.pdf |

### Example Excel Structure

```
| Student Email           | Student Firstname | Student Lastname | Certificate Title             | Issue Date | Description        | Garde/Score | Certificate File Name |
|------------------------|------------------|------------------|-------------------------------|------------|-------------------|-------------|----------------------|
| john.doe@uni.edu       | John             | Doe              | Bachelor of Computer Science  | 2024-06-15 | Graduated with honors | A+    | john_doe_bcs_2024.pdf |
| jane.smith@uni.edu     | Jane             | Smith            | Master of Data Science        | 2024-05-20 | Research focus    | A     | jane_smith_mds_2024.pdf |
| bob.wilson@uni.edu     | Bob              | Wilson           | Certificate in Web Development| 2024-04-10 |                   | B+    | bob_wilson_webdev_2024.pdf |
```

## File Requirements

- **File Format**: Excel (.xlsx or .xls)
- **Maximum Size**: 10MB
- **Maximum Records**: 1000 certificates per upload
- **Encoding**: UTF-8 (for international characters)

## Validation Rules

### Student Email
- Must be a valid email format (contains @ and domain)
- Will be used to match existing users or create new ones

### Student Firstname
- Cannot be empty
- Should be the first name of the student

### Student Lastname
- Cannot be empty
- Should be the last name of the student

### Certificate Title
- Cannot be empty
- Should describe the certificate/diploma/degree

### Issue Date (Optional)
- Must be in YYYY-MM-DD format
- If not provided, current date will be used
- Cannot be a future date

## Upload Process

1. **Download Template**: Click "Download Excel Template" to get the official template file from `/assets/excel-template/certificate-bulk-template.xlsx`
2. **Fill Template**: Add your student and certificate data to the downloaded template
3. **File Selection**: Choose your completed Excel file using the file picker
4. **Validation**: The system will validate each row and show any errors
5. **Preview**: Review the certificates to be created
6. **Creation**: Confirm to create all valid certificates

## Error Handling

The system will show specific errors for each row:

- ❌ **Invalid Email**: "Invalid email format"
- ❌ **Missing Firstname**: "Student firstname is required"
- ❌ **Missing Lastname**: "Student lastname is required"
- ❌ **Missing Certificate**: "Certificate title is required"
- ❌ **Invalid Date**: "Invalid date format. Use YYYY-MM-DD"

## Tips for Success

1. **Use the first row for headers** - The system expects column names in the first row
2. **Check email formats** - Ensure all email addresses are valid
3. **Consistent naming** - Use consistent column names (case-insensitive)
4. **Test with small batches** - Start with a few records to test the format
5. **Remove empty rows** - Delete any completely empty rows

## Alternative Column Names

The system recognizes various column name formats:

**Email**: `email`, `student email`, `studentemail`
**Firstname**: `firstname`, `first name`, `student firstname`, `fname`
**Lastname**: `lastname`, `last name`, `student lastname`, `lname`, `surname`
**Certificate**: `certificate`, `certificate title`, `certificatetitle`, `cert title`
**Date**: `date`, `issue date`, `issuedate`, `issued date`
**Description**: `description`, `desc`, `details`
**Grade**: `grade`, `score`, `result`, `mark`, `garde`, `garde/score`
**Filename**: `filename`, `file name`, `certificate file name`, `cert filename`

## Troubleshooting

### Common Issues

1. **"Required columns not found"**
   - Ensure your first row contains the required column headers
   - Check spelling of column names

2. **"Excel file is empty"**
   - Make sure your file contains data beyond the header row
   - Check that the file isn't corrupted

3. **"Invalid date format"**
   - Use YYYY-MM-DD format (e.g., 2024-06-15)
   - Leave date field empty if unknown

4. **"Invalid email format"**
   - Ensure emails contain @ symbol and valid domain
   - Remove any extra spaces

### Getting Help

If you continue to experience issues:
1. Download the template file for the correct format
2. Verify your Excel file matches the template structure
3. Contact technical support with your specific error message

## Security & Privacy

- All uploaded data is encrypted during transmission
- Files are processed securely and not stored permanently
- Student data is handled according to privacy regulations
- Certificates are linked to blockchain for verification