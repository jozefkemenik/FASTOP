SET DEFINE OFF;

-- Delete "default" categories, keep user defined categories
DELETE FROM HICP_INDICATOR_CODE_CATEGORY WHERE CATEGORY_SID IN (SELECT CATEGORY_SID FROM HICP_CATEGORY WHERE OWNER = 'DEFAULT');
TRUNCATE TABLE HICP_CATEGORY_REL;
DELETE FROM HICP_CATEGORY WHERE OWNER = 'DEFAULT';


INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ORDER_BY)
    VALUES ('HEADLINE', 'Headline', 1);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ORDER_BY)
    VALUES ('HEADLINE_3', '3 digits', 100);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ROOT_INDICATOR_ID, BASE_INDICATOR_ID, ORDER_BY)
    VALUES ('HEAD_AGG_0', 'Aggregates 0', 'CP00', 'CP00', 1000);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ROOT_INDICATOR_ID, BASE_INDICATOR_ID, ORDER_BY)
    VALUES ('HEAD_AGG_5', 'Aggregates 5', '_AGG', 'CP00', 1001);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ROOT_INDICATOR_ID, BASE_INDICATOR_ID, ORDER_BY)
    VALUES ('HEAD_AGG_12', 'Aggregates 12', 'CP00', 'CP00', 1002);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ROOT_INDICATOR_ID, BASE_INDICATOR_ID, ORDER_BY)
    VALUES ('HEAD_3_ALL', 'All items', 'CP00', 'CP00', 1003);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ORDER_BY)
    VALUES ('HEADLINE_5', '5 digits', 101);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ROOT_INDICATOR_ID, BASE_INDICATOR_ID, ORDER_BY)
    VALUES ('HEAD_5_ALL', 'All items', 'CP00', 'CP00', 1007);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ORDER_BY)
    VALUES ('CORE_EC', 'Core [EC def = ex unp_food + energy]', 2);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ORDER_BY)
    VALUES ('CORE_EC_3', '3 digits', 102);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ROOT_INDICATOR_ID, BASE_INDICATOR_ID, ORDER_BY)
    VALUES ('CORE_EC_AGG_0', 'Aggregates 0', '_AGG', 'TOT_X_NRG_FOOD_NP', 1008);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ROOT_INDICATOR_ID, BASE_INDICATOR_ID, ORDER_BY)
    VALUES ('CORE_EC_3_ALL', 'All items', 'CP00', 'CP00', 1009);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ORDER_BY)
    VALUES ('CORE_EC_5', '5 digits', 103);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ROOT_INDICATOR_ID, BASE_INDICATOR_ID, ORDER_BY)
    VALUES ('CORE_EC_5_ALL', 'All items', 'CP00', 'CP00', 1011);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ORDER_BY)
    VALUES ('CORE_ECB', 'Core [ECB def = ex food + energy]', 3);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ORDER_BY)
    VALUES ('CORE_ECB_3', '3 digits', 104);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ROOT_INDICATOR_ID, BASE_INDICATOR_ID, ORDER_BY)
    VALUES ('CORE_ECB_AGG_0', 'Aggregates 0', '_AGG', 'TOT_X_NRG_FOOD', 1012);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ROOT_INDICATOR_ID, BASE_INDICATOR_ID, ORDER_BY)
    VALUES ('CORE_ECB_3_ALL', 'All items', 'CP00', 'CP00', 1013);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ORDER_BY)
    VALUES ('CORE_ECB_5', '5 digits', 105);

INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ROOT_INDICATOR_ID, BASE_INDICATOR_ID, ORDER_BY)
    VALUES ('CORE_ECB_5_ALL', 'All items', 'CP00', 'CP00', 1015);

COMMIT;
