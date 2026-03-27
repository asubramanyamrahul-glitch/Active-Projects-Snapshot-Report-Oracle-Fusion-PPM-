# Active Projects Snapshot – Oracle Fusion PPM BI Publisher Report

## Purpose
This BI Publisher (BIP) report produces an “Active Projects Snapshot” dataset from **Oracle Fusion PPM**. It consolidates key project master attributes—project identity, status, dates, project manager, and business unit—into a single extract that is suitable for analytics, reconciliation, and downstream integrations (for example, loading into an APEX table). [1](https://docs.oracle.com/en/database/oracle/apex/24.1/aeapi/BLOB2CLOBBASE64-Function.html)[2](https://apps2cloudfusion.blogspot.com/p/invoke-bip-report-using-webservices.html)

---

## What the SQL is trying to achieve
The query is designed to return **one row per project** (where possible) with:
- **Project identifiers** (PROJECT_ID, PROJECT_NUMBER, PROJECT_NAME) for stable tracking and filtering. [1](https://docs.oracle.com/en/database/oracle/apex/24.1/aeapi/BLOB2CLOBBASE64-Function.html)[3](https://docs.oracle.com/cd/E37097_01/doc.42/e35127/GUID-9AB4FBA6-4E9F-4EC7-9093-9DF9422F06A6.htm)  
- A **user-friendly status name** (PROJECT_STATUS_NAME) instead of only the internal status code. [4](https://oracle-base.com/articles/misc/apex_web_service-consuming-soap-and-rest-web-services)[5](https://docs.cloud.oracle.com/en/database/oracle/application-express/24.1/aeapi/APEX_WEB_SERVICE.html)  
- **Start and finish dates** (START_DATE, COMPLETION_DATE) for timeline reporting. [1](https://docs.oracle.com/en/database/oracle/apex/24.1/aeapi/BLOB2CLOBBASE64-Function.html)[3](https://docs.oracle.com/cd/E37097_01/doc.42/e35127/GUID-9AB4FBA6-4E9F-4EC7-9093-9DF9422F06A6.htm)  
- The **Project Manager’s display name** by identifying the project party with the “Project Manager” role and resolving it to a person name record. [6](https://rittmanmead.com/blog/2023/02/oracle-apex-reporting-using-bi-publisher-server/)[7](https://github.com/MADHAN957/APEX_SOAPCALL_BIREPORT)  
- The **Business Unit name** by joining the project org context to the BU view. [2](https://apps2cloudfusion.blogspot.com/p/invoke-bip-report-using-webservices.html)[1](https://docs.oracle.com/en/database/oracle/apex/24.1/aeapi/BLOB2CLOBBASE64-Function.html)  

---

## Report Output Columns (what you will see and why)
The report returns the following columns:

### 1) `PROJECT_ID`
- **Source:** `PJF_PROJECTS_ALL_VL.PROJECT_ID` [1](https://docs.oracle.com/en/database/oracle/apex/24.1/aeapi/BLOB2CLOBBASE64-Function.html)  
- **Why it matters:** System-generated unique identifier used for joins, drill-down, integration keys, and troubleshooting.

### 2) `PROJECT_NUMBER`
- **Source:** `PJF_PROJECTS_ALL_VL.SEGMENT1` [1](https://docs.oracle.com/en/database/oracle/apex/24.1/aeapi/BLOB2CLOBBASE64-Function.html)[3](https://docs.oracle.com/cd/E37097_01/doc.42/e35127/GUID-9AB4FBA6-4E9F-4EC7-9093-9DF9422F06A6.htm)  
- **Why it matters:** Business-facing identifier (what functional users search and recognize).

### 3) `PROJECT_NAME`
- **Source:** `PJF_PROJECTS_ALL_VL.NAME` [1](https://docs.oracle.com/en/database/oracle/apex/24.1/aeapi/BLOB2CLOBBASE64-Function.html)  
- **Why it matters:** User-friendly label displayed in UI and reports.

### 4) `PROJECT_STATUS`
- **Source:** `PJF_PROJECT_STATUSES_TL.PROJECT_STATUS_NAME` [4](https://oracle-base.com/articles/misc/apex_web_service-consuming-soap-and-rest-web-services)[5](https://docs.cloud.oracle.com/en/database/oracle/application-express/24.1/aeapi/APEX_WEB_SERVICE.html)  
- **Why it matters:** Converts the internal status **code** (`PROJECT_STATUS_CODE`) into a readable **status name** for business users.

### 5) `START_DATE`
- **Source:** `PJF_PROJECTS_ALL_VL.START_DATE` [1](https://docs.oracle.com/en/database/oracle/apex/24.1/aeapi/BLOB2CLOBBASE64-Function.html)[3](https://docs.oracle.com/cd/E37097_01/doc.42/e35127/GUID-9AB4FBA6-4E9F-4EC7-9093-9DF9422F06A6.htm)  
- **Why it matters:** Enables timeline analysis, filtering, and sorting.

### 6) `FINISH_DATE`
- **Source:** `PJF_PROJECTS_ALL_VL.COMPLETION_DATE` [1](https://docs.oracle.com/en/database/oracle/apex/24.1/aeapi/BLOB2CLOBBASE64-Function.html)[3](https://docs.oracle.com/cd/E37097_01/doc.42/e35127/GUID-9AB4FBA6-4E9F-4EC7-9093-9DF9422F06A6.htm)  
- **Why it matters:** Used for schedule/end-date reporting (planned/defined completion date depending on setup).

### 7) `PROJECT_MANAGER`
- **Source:** `PER_PERSON_NAMES_F.FULL_NAME` resolved from project parties/roles [7](https://github.com/MADHAN957/APEX_SOAPCALL_BIREPORT)[6](https://rittmanmead.com/blog/2023/02/oracle-apex-reporting-using-bi-publisher-server/)  
- **Why it matters:** Provides ownership and accountability (PMO reporting typically requires this).

### 8) `BUSINESS_UNIT`
- **Source:** `FUN_ALL_BUSINESS_UNITS_V.BU_NAME` [2](https://apps2cloudfusion.blogspot.com/p/invoke-bip-report-using-webservices.html)  
- **Why it matters:** Enables BU-level reporting and slicing.

---

## Data Sources Used (tables/views) and why each is used

### A) `PJF_PROJECTS_ALL_VL` (alias `p`) — Driver view
- **Role in report:** Primary source of project master attributes: ID, number, name, status code, dates, org context, template flag. [1](https://docs.oracle.com/en/database/oracle/apex/24.1/aeapi/BLOB2CLOBBASE64-Function.html)[3](https://docs.oracle.com/cd/E37097_01/doc.42/e35127/GUID-9AB4FBA6-4E9F-4EC7-9093-9DF9422F06A6.htm)  
- **Why this object:** `_VL` is a reporting-friendly secured view that includes display fields like `NAME` alongside core project attributes. [1](https://docs.oracle.com/en/database/oracle/apex/24.1/aeapi/BLOB2CLOBBASE64-Function.html)  

> Note: The base table `PJF_PROJECTS_ALL_B` stores non-translatable project fields (e.g., `SEGMENT1`, `PROJECT_STATUS_CODE`, `START_DATE`, `COMPLETION_DATE`). [3](https://docs.oracle.com/cd/E37097_01/doc.42/e35127/GUID-9AB4FBA6-4E9F-4EC7-9093-9DF9422F06A6.htm)  

### B) `PJF_PROJECT_STATUSES_TL` (alias `st`) — Status translation
- **Role in report:** Converts `PROJECT_STATUS_CODE` to a readable `PROJECT_STATUS_NAME`. [4](https://oracle-base.com/articles/misc/apex_web_service-consuming-soap-and-rest-web-services)[5](https://docs.cloud.oracle.com/en/database/oracle/application-express/24.1/aeapi/APEX_WEB_SERVICE.html)  
- **Why `LANGUAGE = USERENV('LANG')`:** Ensures the status name returned matches the session language (translated value). [4](https://oracle-base.com/articles/misc/apex_web_service-consuming-soap-and-rest-web-services)[5](https://docs.cloud.oracle.com/en/database/oracle/application-express/24.1/aeapi/APEX_WEB_SERVICE.html)  

### C) `FUN_ALL_BUSINESS_UNITS_V` (alias `bu`) — Business Unit name
- **Role in report:** Resolves BU ID to BU name (`BU_NAME`). [2](https://apps2cloudfusion.blogspot.com/p/invoke-bip-report-using-webservices.html)  
- **Why this object:** It is the standard Fusion view for business unit identifiers and names. [2](https://apps2cloudfusion.blogspot.com/p/invoke-bip-report-using-webservices.html)  

### D) Project Manager subquery (`pm`) — role-based person resolution
This subquery finds the project manager and returns the manager’s full name by joining:
- **`PJF_PROJECT_PARTIES` (`ppp`)**: identifies people/parties assigned to the project. [6](https://rittmanmead.com/blog/2023/02/oracle-apex-reporting-using-bi-publisher-server/)  
- **`PJF_PROJ_ROLE_TYPES_TL` (`prt`)**: identifies the party role name (filtered to `'Project Manager'`) with language support. [6](https://rittmanmead.com/blog/2023/02/oracle-apex-reporting-using-bi-publisher-server/)  
- **`PER_PERSON_NAMES_F` (`ppnf`)**: resolves the person ID to a readable name (`FULL_NAME`) and applies effective dating. [7](https://github.com/MADHAN957/APEX_SOAPCALL_BIREPORT)[6](https://rittmanmead.com/blog/2023/02/oracle-apex-reporting-using-bi-publisher-server/)  

**Why effective-date filtering is required**
`PER_PERSON_NAMES_F` is **date effective**, so filtering with `TRUNC(SYSDATE) BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE` ensures the current valid name is returned. [7](https://github.com/MADHAN957/APEX_SOAPCALL_BIREPORT)  

**Why `NAME_TYPE = 'GLOBAL'` is used**
It standardizes the returned name to the “Global” name type for consistent reporting across users and locales. [7](https://github.com/MADHAN957/APEX_SOAPCALL_BIREPORT)  
