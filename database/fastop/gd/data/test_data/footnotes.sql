SET DEFINE OFF;

Insert into FASTOP.GD_FOOTNOTES
   (CTY_GRID_SID, 
    DESCR, 
    VERSION_TYPE_ID
   )
 Values
   (1, 
    'Footnote test 1', 
    'P');
Insert into FASTOP.GD_FOOTNOTES
   (CTY_GRID_SID, 
    DESCR, 
    VERSION_TYPE_ID
   )
 Values
   (1, 
    'Looong footnote test:', 
    'N');
COMMIT;
/
