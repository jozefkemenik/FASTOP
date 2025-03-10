/* Formatted on 11-02-2020 16:54:01 (QP5 v5.313) */
SET DEFINE OFF;

INSERT INTO INDICATOR_LISTS(INDICATOR_SID, WORKBOOK_GROUP_SID)
    SELECT I.INDICATOR_SID, G.WORKBOOK_GROUP_SID
      FROM INDICATOR_LISTS@SCOPAX L
           JOIN INDICATORS I ON I.INDICATOR_ID = L.INDICATOR_ID
           JOIN WORKBOOK_GROUPS G ON G.WORKBOOK_GROUP_ID = L.WORKBOOK_GROUP_ID;

COMMIT;