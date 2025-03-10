/* Formatted on 15-09-2020 14:00:53 (QP5 v5.313) */
DROP TABLE FDMS_CTY_SCALES CASCADE CONSTRAINTS;

CREATE TABLE FDMS_CTY_SCALES(
   COUNTRY_ID  VARCHAR2(12)
               NOT NULL
               CONSTRAINT FDMS_CTY_SCALES_UNQ UNIQUE
               CONSTRAINT FDMS_CTY_SCALES_CTY_FK REFERENCES GEO_AREAS(GEO_AREA_ID)
 , SCALE_SID   NUMBER(8)
               NOT NULL
               CONSTRAINT FDMS_CTY_SCALES_SCALE_FK REFERENCES FDMS_SCALES(SCALE_SID)
);
