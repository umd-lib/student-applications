# URL Paths

## Introduction

This document describes the URL paths used by the application.

## Historical Context

Through v4.1.0, the main URL paths used by the application were:

* `/` - The application home page.
* `/prospects/new` - used by students in submitting applications
* `/prospects` - the admin endpoint, protected by CAS login
* `/resumes` - used by student to view their submitted application only, used
  by admin users to view any resume
* `/users` - The user management page (admin functionality)
* `/configuration` - The list configuration management page (Semesters,
  Skills, Class Statuses, Graduation Years, etc.) (admin functionality)

In April 2026 (see LIBITD-2704), the decision was made to split the user
and admin functionality into separate URL paths, with the admin paths only
accessible from on-campus or via VPN when off-campus.

## Current URL Paths

For users (i.e. applying students) the main URL paths are:

* `/` - The application home page.
* `/prospects/new` - used by students in submitting applications
* `/resumes` - used by student to view their submitted application only. Can
  only view their own resume

All user-facing paths are available from off-campus, without a VPN.

The administrative interface uses the following URL paths:

* `/admin/prospects` - The main page for reviewing applications
* `/admin/users` - The user management page
* `/admin/configuration` - The list configuration management page (Semesters,
  Skills, Class Statuses, Graduation Years, etc.)
* `/resumes` - administrative users are allowed to view any submitted resume
* `/admin` - redirects to `/admin/prospects` as a convenience

All `/admin` paths are only accessible from on-campus or via VPN when
off-campus.

The `/resumes` path is available from off-campus, without a VPN, because it is
also used by students to view their uploaded resumes. The ResumesController
has checks to ensure that students can only view their own submitted resumes.

## Path Redirects

### /admin

The `/admin` path automatically redirects to `/admin/prospects` as a convenience
for admin users. This behavior is handled in "config/routes.rb"

### /prospects

The behavior of the `/prospects` endpoint depends on the user's current state.
The following redirect behavior is intended to preserve the historical
(v4.1.0 and earlier) behavior of the system as much as possible.

If an application submission session is in progress, the `/prospects` endpoint
redirects to `/prospects/new` which uses the "prospect_params" in the session to
display the in-progress submission. This behavior is designed to preserve the
student's application even if they do a hard refresh of the page when submitting
an application, and is handled by the `ensure_auth` method in
"app/controllers/application_controller.rb"

If a submission is not in progress (i.e., the browser goes directly to
`/prospects`), then the browser redirects to `/admin/prospects`. This is
provided as a convenience to admin users who are attempting to access the
admin interface at its historical URL path. This behavior is handled in
"config/routes.rb"
