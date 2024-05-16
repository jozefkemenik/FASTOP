SET DEFINE OFF;
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, IS_SEARCHABLE, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (1, 1, 'Export volumes CD',
    FDMS_TCE.getTceReportIndicatorSid('OXGN.6.0.30.0'), 'T',
    FDMS_TCE.getTceReportIndicatorSid('OXSN.6.0.30.0'), 'T',
    FDMS_TCE.getTceReportIndicatorSid('OXGS.6.0.30.0'), 'T');
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, IS_SEARCHABLE, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (2, 1, 'Export market TP',
    FDMS_TCE.getTceReportIndicatorSid('OXGN.6.0.30.0'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('OXSN.6.0.30.0'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('OXGS.6.0.30.0'), 'W');
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, IS_SEARCHABLE, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (3, 1, 'Export performance',
    FDMS_TCE.getTceReportIndicatorSid('OXGN.6.0.30.371'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('OXSN.6.0.30.371'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('OXGS.6.0.30.371'), 'W');
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, IS_SEARCHABLE, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (4, 1, 'Import prices CD ({CURRENCY})',
    FDMS_TCE.getTceReportIndicatorSid('PMGN.6.0.0.0'), 'T',
    FDMS_TCE.getTceReportIndicatorSid('PMSN.6.0.0.0'), 'T',
    FDMS_TCE.getTceReportIndicatorSid('PMGS.6.0.0.0'), 'T');
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, IS_SEARCHABLE, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (5, 1, 'Import prices TP ({CURRENCY})',
    FDMS_TCE.getTceReportIndicatorSid('PMGN.6.0.0.0'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('PMSN.6.0.0.0'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('PMGS.6.0.0.0'), 'W');
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (6, 'Difference',
    FDMS_TCE.getTceReportIndicatorSid('PMGNDIFF.6.0.0.0'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('PMSNDIFF.6.0.0.0'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('PMGSDIFF.6.0.0.0'), 'W');
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY)
 values
   (7);
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, IS_SEARCHABLE, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (8, 1, 'Relative export price',
    FDMS_TCE.getTceReportIndicatorSid('PXGN.6.0.30.212'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('PXSN.6.0.30.212'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('PXGS.6.0.30.212'), 'W');
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY)
 values
   (9);
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, IS_SEARCHABLE, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (10, 1, 'Import prices CD (USD)',
    FDMS_TCE.getTceReportIndicatorSid('PMGN.6.0.30.0'), 'T',
    FDMS_TCE.getTceReportIndicatorSid('PMSN.6.0.30.0'), 'T',
    FDMS_TCE.getTceReportIndicatorSid('PMGS.6.0.30.0'), 'T');
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, IS_SEARCHABLE, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (11, 1, 'Import prices TP (USD)',
    FDMS_TCE.getTceReportIndicatorSid('PMGN.6.0.30.0'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('PMSN.6.0.30.0'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('PMGS.6.0.30.0'), 'W');
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, IS_SEARCHABLE, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (12, 1, 'Export volumes intra-EU CD',
    FDMS_TCE.getTceReportIndicatorSid('OXGN.6.0.30.998'), 'EU',
    FDMS_TCE.getTceReportIndicatorSid('OXSN.6.0.30.998'), 'EU',
    FDMS_TCE.getTceReportIndicatorSid('OXGS.6.0.30.998'), 'EU');
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, IS_SEARCHABLE, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (13, 1, 'Export volumes extra-EU CD',
    FDMS_TCE.getTceReportIndicatorSid('OXGN.6.0.30.998'), 'WE',
    FDMS_TCE.getTceReportIndicatorSid('OXSN.6.0.30.998'), 'WE',
    FDMS_TCE.getTceReportIndicatorSid('OXGS.6.0.30.998'), 'WE');
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY)
 values
   (14);
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY)
 values
   (15);
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, IS_SEARCHABLE, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (16, 1, 'Export market TP (total)',
    FDMS_TCE.getTceReportIndicatorSid('OXGN.6.0.30.0'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('OXSN.6.0.30.0'), 'W',
    FDMS_TCE.getTceReportIndicatorSid('OXGS.6.0.30.0'), 'W');
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, IS_SEARCHABLE, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (17, 1, 'Export market TP (intra-EU)',
    FDMS_TCE.getTceReportIndicatorSid('OXGN.6.0.30.0'), 'EU',
    FDMS_TCE.getTceReportIndicatorSid('OXSN.6.0.30.0'), 'EU',
    FDMS_TCE.getTceReportIndicatorSid('OXGS.6.0.30.0'), 'EU');
insert into FDMS_TCE_REPORT_DEFINITION
   (ORDER_BY, IS_SEARCHABLE, DESCR,
    GN_INDICATOR_SID, GN_DATA_TYPE,
    SN_INDICATOR_SID, SN_DATA_TYPE,
    GS_INDICATOR_SID, GS_DATA_TYPE)
 values
   (18, 1, 'Export market TP (extra-EU)',
    FDMS_TCE.getTceReportIndicatorSid('OXGN.6.0.30.0'), 'WE',
    FDMS_TCE.getTceReportIndicatorSid('OXSN.6.0.30.0'), 'WE',
    FDMS_TCE.getTceReportIndicatorSid('OXGS.6.0.30.0'), 'WE');
commit;
