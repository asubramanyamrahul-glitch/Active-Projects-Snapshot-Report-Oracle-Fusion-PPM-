# Active Projects Snapshot Report (Oracle Fusion PPM)

## 1. Purpose of this Report

This report is designed to give a **clear and consolidated view of active projects** in Oracle Fusion PPM.

From a business perspective, it answers questions like:

* What projects currently exist in the system?
* What is their current status?
* Who is responsible for each project?
* Which Business Unit owns the project?
* What are the project timelines?

From a technical perspective, the query brings together **core project data + descriptive attributes** (status name, BU name, Project Manager) into a **single, report-ready dataset**.

This type of report is commonly used in:

* PMO dashboards
* Management reporting
* BI Publisher (BIP) outputs
* APEX reporting screens
* Data extracts for integrations

---

## 2. Tables and Views Used

### 2.1 `PJF_PROJECTS_ALL_VL` (Alias: `p`) — Main Driver

This is the **primary source table/view** for the report.

#### Why it is used:

* Contains all core project information
* Secured view (respects user access)
* Acts as the base dataset

#### Key Columns Used:

* `PROJECT_ID` → Unique system identifier
* `SEGMENT1` → Project Number (business identifier)
* `NAME` → Project Name
* `PROJECT_STATUS_CODE` → Status (code form)
* `START_DATE` → Project start date
* `COMPLETION_DATE` → Project finish date
* `ORG_ID` → Business Unit reference
* `TEMPLATE_FLAG` → Identifies templates vs actual projects

---

### 2.2 `PJF_PROJECT_STATUSES_TL` (Alias: `st`) — Status Translation

#### Why it is used:

Projects store only a **status code**, but users need a **readable status name**.

#### Key Columns Used:

* `PROJECT_STATUS_CODE` → Join key
* `PROJECT_STATUS_NAME` → Display value
* `LANGUAGE` → Ensures correct language translation

---

### 2.3 `FUN_ALL_BUSINESS_UNITS_V` (Alias: `bu`) — Business Unit

#### Why it is used:

To convert the organization ID into a **Business Unit name**.

#### Key Columns Used:

* `BU_ID` → Join key (mapped to `p.ORG_ID`)
* `BU_NAME` → Business Unit name

---

### 2.4 Project Manager Subquery (Alias: `pm`)

This is a derived dataset built using three tables:

---

#### a) `PJF_PROJECT_PARTIES` (Alias: `ppp`)

##### Why:

Stores **project team members and their roles**.

##### Key Columns:

* `PROJECT_ID`
* `PROJECT_ROLE_ID`
* `RESOURCE_SOURCE_ID` (links to person)

---

#### b) `PJF_PROJ_ROLE_TYPES_TL` (Alias: `prt`)

##### Why:

Used to identify the **role name** (e.g., "Project Manager").

##### Key Columns:

* `PROJECT_ROLE_ID`
* `PROJECT_ROLE_NAME`
* `LANGUAGE`

---

#### c) `PER_PERSON_NAMES_F` (Alias: `ppnf`)

##### Why:

Provides the **actual name of the person**.

##### Key Columns:

* `PERSON_ID`
* `FULL_NAME`
* `NAME_TYPE`
* `EFFECTIVE_START_DATE`
* `EFFECTIVE_END_DATE`

##### Special Logic:

* Filters for `NAME_TYPE = 'GLOBAL'`
* Applies effective date check using `SYSDATE`

---

## 3. Columns Selected in Final Output

| Column            | Source                   | Description                      |
| ----------------- | ------------------------ | -------------------------------- |
| `PROJECT_ID`      | `p.PROJECT_ID`           | Unique system identifier         |
| `PROJECT_NUMBER`  | `p.SEGMENT1`             | Business-friendly project number |
| `PROJECT_NAME`    | `p.NAME`                 | Name of the project              |
| `PROJECT_STATUS`  | `st.PROJECT_STATUS_NAME` | Readable status                  |
| `START_DATE`      | `p.START_DATE`           | Project start date               |
| `FINISH_DATE`     | `p.COMPLETION_DATE`      | Project completion date          |
| `PROJECT_MANAGER` | `pm.FULL_NAME`           | Assigned Project Manager         |
| `BUSINESS_UNIT`   | `bu.BU_NAME`             | Owning Business Unit             |

---

## 4. Join Logic Explained

### 4.1 Status Join

```sql
LEFT JOIN PJF_PROJECT_STATUSES_TL st
  ON st.PROJECT_STATUS_CODE = p.PROJECT_STATUS_CODE
 AND st.LANGUAGE = USERENV('LANG')
```

#### Why:

* Converts status code → readable name
* Uses session language for translation

#### Why LEFT JOIN:

* Ensures project is not dropped if translation is missing

---

### 4.2 Business Unit Join

```sql
LEFT JOIN FUN_ALL_BUSINESS_UNITS_V bu
  ON bu.BU_ID = p.ORG_ID
```

#### Why:

* Maps organization ID to BU name

#### Why LEFT JOIN:

* Keeps project even if BU mapping is unavailable

---

### 4.3 Project Manager Join

```sql
LEFT JOIN (subquery) pm
  ON pm.PROJECT_ID = p.PROJECT_ID
```

#### Why:

* Extracts only the resource with role = "Project Manager"
* Converts person ID → Full Name

#### Why LEFT JOIN:

* Some projects may not have a PM assigned

---

## 5. Filtering Conditions (WHERE Clause)

### 5.1 Exclude Templates

```sql
p.TEMPLATE_FLAG = 'N'
```

#### Why:

* Templates are not real projects
* Keeps only active/real project records

---

### 5.2 Status Filtering

```sql
p.PROJECT_STATUS_CODE IN ('APPROVED','ACTIVE','DRAFT')
```

#### Why:

Focuses on **in-progress lifecycle projects**:

* `DRAFT` → Initial stage
* `APPROVED` → Approved but not fully active
* `ACTIVE` → Currently running

---

## 6. Sorting Logic

```sql
ORDER BY p.SEGMENT1
```

#### Why:

* Orders by project number
* Makes output consistent and user-friendly

---

## 7. Final Output Behavior

* Each row represents **one project**
* Includes enriched descriptive data
* May return **NULL Project Manager** if not assigned
* May return **multiple rows per project** if multiple PM roles exist

---

## 8. Why This Report is Needed

This report is useful because:

* Oracle Fusion stores data in **normalized, technical structures**
* End users need **flattened, readable datasets**
* It reduces the need to join multiple tables repeatedly
* Provides a **ready-to-use dataset for reporting tools**

---

## 9. Where This Report is Typically Used

* BI Publisher (BIP) reports
* APEX dashboards
* Excel extracts for business users
* PMO tracking sheets
* Integration with external systems

---

## 10. Possible Enhancements

* Add Project Type / Category
* Include Financial data (Cost, Budget)
* Add Project Status Date
* Restrict to Primary Project Manager
* Add parameterized filters (BU, Status, Date range)

---

## 11. Summary

This query builds a **complete, business-friendly project dataset** by:

* Starting from core project data
* Enriching with status, BU, and manager details
* Filtering only relevant projects
* Delivering a clean and structured output

It serves as a strong base for any **project-level reporting or analytics use case** in Oracle Fusion PPM.

---
