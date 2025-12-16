# Test Plan

## Introduction

This document provides a basic test plan that verifies as much application
functionality as feasible.

The intention is to provide basic assurance that the application is functional,
and guard against regressions.

**The document is not intended to be an exhaustive test plan.**

## Test Plan Assumptions

This test plan assumes that the user can log in via CAS as as administrator.

The test plan steps are specified using URLs for the Kubernetes "test"
namespace, as that seems to be the most useful. Unless otherwise specified,
test steps should work in the local development environment as well.

## Student Applications Test Plan

### 1) Student Applications Home Page

1.1) In a web browser, go to

<https://student-applications-test.lib.umd.edu/>

The Student Applications home page will be displayed.

1.2) On the Student Applications home page, verify that:

* The UMD favicon is displayed in the browser tab, and that the text in
  the browser tab is "Student Applications"
* The appropriate SSDR environment banner is displayed.
* The page contains an "Apply!" button.

1.3) At the bottom of the page, verify that the footer has a "Web Accessibility"
link.

1.3.1) Left-click the "Web Accessibility"
link. Verify that the web accessibility page on the university website is
displayed.

1.3.2) Go back to the Student Applications home Page

### 2) Student Applications Submission

The Student Application submission process is a multi-step form where the
user fills out all the required fields on a particular page before proceeding
to the next. The user is allowed to go back to previous steps at any time.

The submission must be completed during one browser session -- there is no
functionality for saving a submission and resuming it later.

Once an application is submitted, an email is sent to the user acknowledging
the submission.

Once submitted, the submission cannot be accessed or edited by the user.

There may be multiple semesters available to apply for. Each submission is for
a particular semester, so if a user wishes to apply for multiple semesters,
they must make a separate submission for each semester.

At each step, the application prevents the user from going to the next step if
any required fields have not been filled out, highlighting the missing fields.

#### 2.1) "New Student Application" page

2.1.1) On the Student Applications home page left-click the "Apply!" button. The
"New Student Application" page will be displayed. Verify that the page
displays the following fields:

* Directory ID
* Which semester are you applying for?

2.1.2) On the "New Student Application" page, immediately left-click the
"Continue" button. Verify that a "Please review the problems below" notification
message is displayed, and the "Directory ID" and
"Which semester are you applying for?" are highlighted in red, with the
following error explanations:

* Directory ID - `can't be blank`
* "Which semester are you applying for?" -
  `Please indicate which semester you are applying for.`

2.1.3) Fill out the fields:

| Field | Value |
| ----- | ----- |
| Directory ID | `test_student` |
| Which semester are you applying for? | \<Choose the first value> |

2.1.4) Left-click the "Continue" button. Verify that the "Contact Information"
page is displayed.

#### 2.2) "Contact Information" page

2.2.1) On the "Contact Information" page, in each section, verify that all of
the fields are present and fill out them out as indicated:

* **Basic Information**

  | Field | Value |
  | ----- | ----- |
  | First name | `Test` |
  | Last name  | `Student` |
  | Email | \<Enter your email address> |
  | Major | `Testing Major` |
  | Class Status | `Undergraduate` |
  | Expected Graduation Year | \<Choose one of the values> |
  | Are you in a Federal Work Study program? | `No` |

* **Addresses**

  | Field | Value |
  | ----- | ----- |
  | Address type | `local` (Cannot be changed) |
  | Street Address 1 | `Local Test Street Address 1` |
  | Street Address 2 | `Local Test Street Address 2` |
  | City | `Test City` |
  | State | `TN` |
  | Postal code | `12345` |
  | Country | `United States` |

* **Phone Number**

  | Field | Value |
  | ----- | ----- |
  | Number | `123-456-7890` |
  | Phone type | `local` |

* **Preferred Libraries**

  \<Left-click `McKeldin` to select it>

* **How Did You Hear About Us?**

  \<Select `Other` from the drop-down list>

2.2.2) Add an additional address by left-clicking the "Add a Permanent Address"
link in the "Addresses" header. Verify that an additional address section is
added. and fill out the fields as follows:

| Field | Value |
| ----- | ----- |
| Address type | `permanent` (Cannot be changed) |
| Street Address 1 | `Permanent Test Street Address 1` |
| Street Address 2 | `Permanent Test Street Address 2` |
| City | `Permanent Test City` |
| State | `PT` |
| Postal code | `456789` |
| Country | `Antarctica` |

2.2.3) Left-click the "Continue" button. Verify that the "Work Experience" page
is displayed.

#### 2.3) "Work Experience" page

2.3.1) On the "Work Experience" page, left-click the "Add Work Experience" link
in the panel header, and the fill out the following fields:

| Field | Value |
| ----- | ----- |
| Name of Employer | `Test Employer` |
| Position Title | `Test Position Title` |
| Dates of employment | `2021-2025` |
| Location | `Test Employment Location` |
| Duties | `Test Duties` |
| Is this position library related? | `Yes` |

2.3.2) Left-click the "Add Work Experience" link in the panel header, and verify
that a second "Work Experience" section is added.

2.3.3) Remove the second (empty) work experience section by left-clicking the
"Remove" link in the section. Verify that the section is removed.

2.3.4) Left-click the "Continue" button. Verify that the "Skills" page
is displayed.

#### 2.4) "Skills" page

2.4.1) On the "Skills" page, do the following:

* Skills - Left-click `Computer Experience`
* List Additional Skills - Left-click the "Add Skill" link, and in the resulting
  textbox, enter `Testing Skills`

2.4.2) Left-click the "Continue" button. Verify that the "Availability" page is
displayed.

#### 2.5) "Availability" page

2.5.1) On the "Availability" page, do the following:

* Total Available Hours Per Week - Enter `2` in "Available hours per week"
* "Select date and times available" - Left-click the cell in the table for
Sunday at 12am. Verify that a checkbox is displayed in the cell, and that the
cell background is green.

2.5.2) Left-click the "Continue" button. Verify that
an error notification is displayed, and that the "Available hours per week"
field is highlighted with a message
`can't be greater than the number of available times provided.`

2.5.3) In the "Select date and times available" table, left-click the cell for
Monday at 12am.

2.5.4) Left-click the "Continue" button. Verify that the "Resume" page is
displayed.

#### 2.6) "Resume" page

2.6.1) On the "Resume" page, left-click the "Choose a file..." button. Verify
that a file dialog is shown.

2.6.2) In the file dialog, select a PDF for upload. On the "Resume" page,
verify that a "Submit (C:\fakepath\\\<FILENAME>)" button is displayed, where
\<FILENAME> is the name of the selected file.

2.6.3) Left-click the "Submit (C:\fakepath\\\<FILENAME>)" button. Verify that
the button is replaced by a "Success!" button (which cannot be clicked).

2.6.4) Left-click the "Continue" button. Verify that the "Confirmation" page
is displayed.

#### 2.7) "Confirmation" page

2.7.1) On the "Confirmation" page, verify that the following information is
present in each section:

* **Applicant Info**

  | Field | Value |
  | ----- | ----- |
  | Directory ID | test_student |
  | Semester Applying For | \<The semester that was chosen> |

* **Contact Info**

  | Field | Value |
  | ----- | ----- |
  | First name | `Test` |
  | Last name  | `Student` |
  | Email | \<Your email address> |
  | Major | `Testing Major` |
  | Class status | Undergraduate |
  | Graduation year | \<The graduation year that was chosen> |
  | Local Address | `Local Test Street Address 1` |
  |               | `Local Test Street Address 2` |
  |               | `Test City, TN 12345` |
  |               | `US` |
  | Permanent Address | `Permanent Test Street Address 1` |
  |                   | `Permanent Test Street Address 2` |
  |                   | `Permanent Test City, PT 456789` |
  |                   | `AQ` |
  | Phone Numbers | `123-456-7890 ( local )` |
  | Preferred Libraries | `McKeldin` |
  | In federal work study | `No` |
  | How did you hear about us? | Other |

* **Work Experience**

  | Field | Value |
  | ----- | ----- |
  | Employer Name | `Test Employer` |
  | Position Title  | `Test Position Title` |
  | Dates | `2021-2025` |
  | Location | `Test Employment Location` |
  | Duties | `Test Duties` |
  | Library related | `Yes` |

* **Skills**

  * `Computer Experience`
  * `Testing Skills`

* **Availability**

  * Available hours per week - `2`

  In the table, verify that the first two cells in the first row (corresponding
  to Sunday 12am, and Monday 12am) are selected (with a checkbox on a green
  background).

* **Resume**

  Verify that there is a "View \<FILENAME>" link, where \<FILENAME> is the
  name of the file that was uploaded.

2.7.2) Left-click the "View \<FILENAME>" link in the "Resume" section. Verify
that the PDF can be downloaded/viewed (in Firefox, the PDF may immediately open
to be viewed, in Chrome, it may need to be downloaded first).

2.7.3) In the "Additional Comments" section on the "Confirmation" page, enter
`Test Additional Comment`

2.7.4) In the "Confirmation" section at the bottom of the page:

* "I certify that all information on this application is accurate and recognize
it is subject to verification." - Left-click the checkbox to select it
* "Please type your name as it will serve as a digital signature" - Enter
`Test Student`

2.7.5) Left-click the "Submit" button. Verify that a "Thank You!" page is
displayed, with a "Submitted!" notification.

2.7.6) After a few minutes, verify an email was sent to the email provided in
the submission, with the salutation addressed to "Test Student".

**Note:** If running in the local development environment, an email will *not*
be received.

#### 2.8) Application Resubmission

2.8.1) Close the browser window.

2.8.2) In a new browser window, go to

<https://student-applications-test.lib.umd.edu/>

The Student Applications home page will be displayed.

2.8.3) On the Student Applications home page, left-click the "Apply!" button.

2.8.4) On the "New Student Application" page, enter the directory id and
semester used in the submission in the previous steps:

| Field | Value |
| ----- | ----- |
| Directory ID | `test_student` |
| Which semester are you applying for? | \<Choose the first value> |

then left-click the "Continue" button.

Verify that an error notification is displayed indicating that the directory
id has already submitted an application, and that only one application
submission is allowed per semester, with contact information for assistance.

2.8.5) Close the browser window.

### 3) Student Applications Admin Interface

#### 3.1) Admin Home page

3.1.1) In a web browser, go to

<https://student-applications-test.lib.umd.edu/prospects/>

After logging in via CAS, verify that the Student Applications admin interface
home page is displayed.

3.1.2) On the Student Applications admin home page, verify that a table of
existing applications is displayed.

#### 3.2) Admin Applicant Detail Page

3.2.1) On the admin home page, left-click the "Filter" button. Verify that a
"Filter Applications" modal dialog is displayed.

3.2.2) In the "Filter Applications modal" dialog, enter `Student` in the
"Last Name" field of the "Contact Information" section, then left-click the
"Filter" button in the bottom-left corner of the dialog.

The dialog will be dismissed, and the admin home page will be displayed. Verify
that the table has been updated to only display applicants with a last name of
"Student". Verify that the application made by the "Student, Test" in the
previous steps is one of the applicants listed (may be the only one).

3.2.3) Left-click the "Name" link of the "Student, Test" entry from the previous
steps.  An applicant detail page will be displayed. Verify that:

* the information displayed is correct (based on the entries made in the
previous steps)

At the bottom of the page verify that there is:

* an "Edit Submission" button
* An "Admin Section" panel with a "Hired" toggle switch and an "HR Comments"
textbox.

In the "Resume" section, left-click the "View" link and verify that the PDF can
be downloaded/viewed (in Firefox, the PDF may immediately open to be viewed, in
Chrome, it may need to be downloaded first).

3.2.4) Left-click the "Edit Submission" button. A single page form with all of
the applicant's information should be displayed. Change the "Class Status"
field to "Graduate" using the drop-down.

Left-click the "Save" button at the bottom of the page.

3.2.5) Verify that the admin home page is displayed, with a notification that
"Student, Test application has been updated".

Note: The filter settings are *not* retained, so that table will again display
all applicants.

#### 3.3) Additional Filter testing

3.3.1) On the admin home page,left-click the "Filter" button. In the modal
dialog:

* Last Name: `St%`
* Skills: <Left-click "Computer Experience" to select it>
* Available Time: <Left-click the Sunday 12am checkbox to select it>

and then left-click the "Filter" button.

3.3.2) On the admin home page, verify that "Student, Test" is one of the
entries in the filtered table. Verify that the "Class Status" for is now
"Graduate" (from the change made in the previous step).

Assuming that there is more than one entry in the table, left-click one of the
*other* entries and in the detail page verify that:

* the last name begins with "St"
* "Computer Experience" is one of the listed skills
* the "Availability" table has the Sunday, 12am checkbox selected.

3.11) Left-click the "Review Applications" link in the navigation bar to
return to the admin home page.

#### 3.4) Application Deletion

3.4.1) On the admin home page, left-click the "Filter" button. In the modal
dialog:

* Directory id: `test_student`

and then left-click the "Filter" button.

3.4.2) On the admin home page verify that "Student, Test" is the only applicant
listed.

3.4.3) Left-click the checkbox next to the "Student, Test" entry to select it.

3.4.4) Left-click the "Delete" button at the top of the table. A configuration
dialog will be displayed listing the application to be deleted. Left-click the
"Delete Applications" button in the dialog to confirm.

After confirming, verify that the table entry briefly displays with a red
background, and then is removed, and that the table is now empty.

3.4.5) Left-click the "Review Applications" link in the navigation bar to
return to the unfiltered table on the admin home page.

#### 3.5) List Configuration

3.5.1) On the admin home page, left-click the "List Configuration" link in
the navigation bar. Verify that the page shows the following as expandable
panels:

* Skills
* Libraries
* Graduation Years
* How Did You Hear About Us
* Semesters
* Class Statuses

3.5.2) Left-click the "Semesters" panel to expand it.

3.5.3) In the expanded "Semesters" panel, left-click the toggle for the
one of the semesters listed as "Off" to change it to "On".

3.5.4) Open a second web browser window, go to

<https://student-applications-test.lib.umd.edu/>

The Student applications home page will be displayed.

3.5.5) On the Student applications home page in the second browser window,
left-click the "Apply!" button. Verify on the "New Student Application" page
that semester that as toggled is now listed as one of the semesters.

3.5.6) In the expanded "Semesters" panel in the first browser window, left-click
the toggle for the semester again to it to "Off".

3.5.7) On the Student applications home page in the second browser window,
refresh the page, and verify that the semester is *not* listed as one of the
semesters.

Close the second browser window.

#### 3.6) User Management

3.6.1) Left-click the "User Management" link in the navigation bar. Verify that
a page showing a table of authorized users is displayed.

Verify that the table that the following fields:

* An "x" button to delete the user.
* User ID
* User Name
* Administrator Status (as a toggle button).

3.6.2) On the user management page, left-click the "+" button. Verify that a
"New User" modal dialog is displayed with two fields:

* Cas directory
* Name

Dismiss the dialog without making any changes by left-clicking the "Close"
button.

3.6.3) Verify that at the top of the page is a banner indicating that you
are an admin user, with a "Disable Admin" button.

Left-click the "Disable Admin" button. The admin home page will be displayed.

3.6.3) On the admin home page, verify that there is a notification indicating
that you have temporarily disable admin functionality. Also verify that
in the navigation bar the only links are:

* Review Applications
* Sign Out

3.6.4) Left-click one of the applicants in the table. On the resulting detail
page, verify that the page has an "Edit Submission" button at the bottom of
the page but does **not** have an "Admin" panel with a "Hired"
toggle and an "HR Comments" textbox.
