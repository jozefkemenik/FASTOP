/* Formatted on 12/2/2019 13:52:10 (QP5 v5.252.13127.32847) */
DROP TABLE MN_MENU_MENU_ITEMS;

CREATE TABLE MN_MENU_MENU_ITEMS
(
   MENU_SID        NUMBER (8)
                      NOT NULL
                      CONSTRAINT MN_MENU_MENU_ITEMS_MENU_FK
                          REFERENCES MN_MENU_REPO (MENU_REPO_SID)
,  MENU_ITEM_SID   NUMBER (8)
                      NOT NULL
                      CONSTRAINT MN_MENU_MENU_ITEMS_SUBMENU_FK
                          REFERENCES MN_MENU_REPO (MENU_REPO_SID)
,  ORDER_BY        NUMBER (2)
,  CONSTRAINT MN_MENU_MENU_ITEMS_UNQ UNIQUE (MENU_SID, MENU_ITEM_SID)
);