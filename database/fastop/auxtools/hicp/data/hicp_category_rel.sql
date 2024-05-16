SET DEFINE OFF;


INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'HEADLINE') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'HEADLINE_3') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'HEADLINE_3') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'HEAD_AGG_0') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'HEADLINE_3') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'HEAD_AGG_5') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'HEADLINE_3') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'HEAD_AGG_12') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'HEADLINE_3') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'HEAD_3_ALL') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'HEADLINE') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'HEADLINE_5') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'HEADLINE_5') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'HEAD_AGG_0') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'HEADLINE_5') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'HEAD_AGG_5') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'HEADLINE_5') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'HEAD_AGG_12') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'HEADLINE_5') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'HEAD_5_ALL') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_EC') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_EC_3') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_EC_3') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_EC_AGG_0') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_EC_3') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_EC_3_ALL') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_EC') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_EC_5') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_EC_5') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_EC_AGG_0') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_EC_5') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_EC_5_ALL') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_ECB') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_ECB_3') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_ECB_3') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_ECB_AGG_0') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_ECB_3') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_ECB_3_ALL') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_ECB') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_ECB_5') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_ECB_5') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_ECB_AGG_0') as child_category_sid
   FROM dual;     

INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_ECB_5') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = 'CORE_ECB_5_ALL') as child_category_sid
   FROM dual;     

COMMIT;
