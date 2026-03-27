--BIP Report : 
  

SELECT
    p.PROJECT_ID                               AS PROJECT_ID,
    p.SEGMENT1                                 AS PROJECT_NUMBER,
    p.NAME                                     AS PROJECT_NAME,
    st.PROJECT_STATUS_NAME                     AS PROJECT_STATUS,
    p.START_DATE                               AS START_DATE,
    p.COMPLETION_DATE                          AS FINISH_DATE,
    pm.FULL_NAME                               AS PROJECT_MANAGER,
    bu.BU_NAME                                 AS BUSINESS_UNIT
FROM
    PJF_PROJECTS_ALL_VL p
    LEFT JOIN PJF_PROJECT_STATUSES_TL st
           ON st.PROJECT_STATUS_CODE = p.PROJECT_STATUS_CODE
          AND st.LANGUAGE = USERENV('LANG')
    LEFT JOIN FUN_ALL_BUSINESS_UNITS_V bu
           ON bu.BU_ID = p.ORG_ID
    LEFT JOIN (
        SELECT
            ppp.PROJECT_ID,
            ppnf.FULL_NAME
        FROM
            PJF_PROJECT_PARTIES ppp
            JOIN PJF_PROJ_ROLE_TYPES_TL prt
              ON prt.PROJECT_ROLE_ID = ppp.PROJECT_ROLE_ID
             AND prt.LANGUAGE = USERENV('LANG')
            JOIN PER_PERSON_NAMES_F ppnf
              ON ppnf.PERSON_ID = ppp.RESOURCE_SOURCE_ID
             AND ppnf.NAME_TYPE = 'GLOBAL'
             AND TRUNC(SYSDATE) BETWEEN ppnf.EFFECTIVE_START_DATE AND ppnf.EFFECTIVE_END_DATE
        WHERE
            prt.PROJECT_ROLE_NAME = 'Project Manager'
    ) pm
      ON pm.PROJECT_ID = p.PROJECT_ID
WHERE
    p.TEMPLATE_FLAG = 'N'
    AND p.PROJECT_STATUS_CODE IN ('APPROVED','ACTIVE','DRAFT')  
ORDER BY
    p.SEGMENT1
	
/*	
APPROVED

CLOSED

ACTIVE

DRAFT*/ 