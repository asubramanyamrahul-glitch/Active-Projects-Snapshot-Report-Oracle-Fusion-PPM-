# Active Projects Snapshot Report (Oracle Fusion PPM)

## Overview

This repository contains a SQL-based report designed to provide a clean and practical snapshot of active projects within Oracle Fusion PPM.

The goal is simple: bring together the most important project details into a single, easy-to-consume dataset that can be used for reporting, dashboards, or downstream processing.

Instead of pulling scattered data from multiple places, this query centralizes everything into one view — making it much easier for PMO teams, analysts, and finance users to understand what’s going on across projects.

---

## What This Report Covers

The report focuses on active and in-progress projects and includes:

* Project identifiers (ID, Number, Name)
* Current project status (user-friendly, not codes)
* Start and completion dates
* Assigned Project Manager
* Business Unit context

Think of it as a “current state of projects” snapshot — useful for both operational tracking and reporting.

---

## Data Sources Used

The query pulls data from a few key Oracle Fusion tables/views:

* **Projects View** – Main source of project data
* **Project Status Translation Table** – Converts status codes into readable names
* **Business Unit View** – Provides BU names
* **Project Parties + Roles + Person Names** – Used to identify and display the Project Manager

Each additional join exists purely to enrich the base project data with something more meaningful for end users.

---

## Key Logic Explained

### 1. Base Dataset

The report starts with the main projects view, which already includes most of the core attributes like project number, name, dates, and status code.

### 2. Status Translation

Project status is stored as a code, so it’s joined with a translation table to show a readable name instead.

### 3. Business Unit Mapping

Projects are linked to an organization. This is mapped to a Business Unit name for reporting clarity.

### 4. Project Manager Identification

The Project Manager is derived by:

* Looking at project party assignments
* Filtering for the “Project Manager” role
* Pulling the person’s full name from the HR tables (with date-effective logic)

### 5. Filtering

The query intentionally limits results to:

* Non-template projects
* Projects in relevant lifecycle stages (Draft, Approved, Active)

### 6. Ordering

Results are sorted by project number to keep things predictable and easy to scan.

---

## Output Structure

Each row in the result represents a project and includes:

* `PROJECT_ID`
* `PROJECT_NUMBER`
* `PROJECT_NAME`
* `PROJECT_STATUS`
* `START_DATE`
* `FINISH_DATE`
* `PROJECT_MANAGER`
* `BUSINESS_UNIT`

---

## Usage

This query is flexible and can be used in different ways:

* As a BI Publisher (BIP) data source
* For APEX-based dashboards or reports
* As a staging dataset for ETL or integrations
* For ad-hoc analysis by functional teams

---

## Notes & Considerations

* Some projects may not have a Project Manager assigned — those fields will appear as null.
* If multiple Project Managers exist, the current logic may return more than one row per project (this can be refined if needed).
* Status codes and role names can vary slightly depending on your Fusion setup.

---

## Possible Enhancements

If you plan to extend this:

* Add financial metrics (cost, budget, revenue)
* Include project classification or type
* Filter by Business Unit dynamically
* Add “primary” Project Manager logic if multiple exist
* Include project health/status indicators

---

## Final Thoughts

This isn’t meant to be overly complex — just something reliable and practical that solves a common reporting need.

If you’re working in Oracle Fusion PPM, you’ll probably end up building something like this anyway. This just gives you a solid starting point.
