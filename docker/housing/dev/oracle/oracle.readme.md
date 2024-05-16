# Oracle-XE-21-Full on podman

**housing machine**: fp-py-d.cc.cec.eu.int  
**<ORACLE_PASSWORD>**: WcLbm0zuIP5xh0bn8eqT   
**<FASTOP_DB_PASSWORD>**: PkkeZNgNsRCVYHdsKPLp  

**<ORACLE_PASSWORD>** is the oracle system password  
**<FASTOP_DB_PASSWORD>** is the **fastop** schema password


## 1. New installation

### 1.1. Pull image

    podman pull docker.io/gvenzl/oracle-xe:21-full

### 1.2. Create oracle datapump directories 

    mkdir -p $FASTOP/oracle/oradata/files/dbin
    mkdir -p $FASTOP/oracle/oradata/files/dbout

Define $ORADATA in fastop_profile: $FASTOP/etc/fastop_profile:

    export ORADATA=$FASTOP/oracle/oradata/

### 1.3. Run container

    podman run -d -p 1521:1521 -e ORACLE_PASSWORD=<ORACLE_PASSWORD> --name oracleDev21c -v $ORADATA:/opt/oracle/oradata gvenzl/oracle-xe:21-full

After around 2 mins you should find this in the output:

    podman logs oracleDev21c


#########################
DATABASE IS READY TO USE!
#########################

### 1.4. Configure fastop db

#### 1.4.1. Run bash

    podman exec -it --user=oracle oracleDev21c bash

#### 1.4.2. Start sqlplus inside the container

    sqlplus sys/<ORACLE_PASSWORD>@XEPDB1 as sysdba

#### 1.4.3. Set up the db

    ALTER SESSION SET CONTAINER = XEPDB1;
    CREATE USER fastop IDENTIFIED BY <FASTOP_DB_PASSWORD>;
    GRANT CONNECT, RESOURCE, DBA TO fastop;
    GRANT UNLIMITED TABLESPACE TO fastop;
    GRANT CREATE SESSION TO fastop;
    ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;

Configure data-pump:

    CREATE OR REPLACE DIRECTORY DATADIR AS '/opt/oracle/oradata/files/dbin';
    GRANT READ, WRITE ON DIRECTORY DATADIR TO SYSTEM;

Exit the sqlplus:

    exit

#### 1.4.4. Import dump file

**<DUMP_FILE>**: e.g. fastop_prod_11_15_2023.dmp  
**<DUMP_ENCRYPTION_PASSWORD>**: password used to encrypt the file when dumping the source database

    impdp system/<ORACLE_PASSWORD>@XEPDB1 DIRECTORY=datadir DUMPFILE=<DUMP_FILE> transform=segment_attributes:n exclude=cluster,indextype,db_link logfile=import_fastop.log ENCRYPTION_PASSWORD=<DUMP_ENCRYPTION_PASSWORD>

### 1.5. Connect to new db

    export FASTOP_DB=fp-etl-d.cc.cec.eu.int:1521/XEPDB1
    export FASTOP_DB_PASSWORD='<FASTOP_DB_PASSWORD>'

## 2. Restore database

This step assumes that the container is already created and we just want to restore the database from the dump file.

#### 2.1 Run bash

    podman exec -it --user=oracle oracleDev21c bash

#### 2.2. Start sqlplus inside the container

    sqlplus sys/<ORACLE_PASSWORD>@XEPDB1 as sysdba

Then execute SQL commands:

    SHUTDOWN IMMEDIATE;
    STARTUP RESTRICT;
    ALTER SESSION SET CONTAINER = XEPDB1;
    DROP USER fastop CASCADE;
    CREATE USER fastop IDENTIFIED BY <FASTOP_DB_PASSWORD>;
    GRANT CONNECT, RESOURCE, DBA TO fastop;
    GRANT UNLIMITED TABLESPACE TO fastop;
    GRANT CREATE SESSION TO fastop;
	SHUTDOWN IMMEDIATE;
	STARTUP;

Exit the sqlplus:

    exit

#### 2.3. Import dump file

**<DUMP_FILE>**: e.g. fastop_prod_11_15_2023.dmp  
**<DUMP_ENCRYPTION_PASSWORD>**: password used to encrypt the file when dumping the source database

    impdp system/<ORACLE_PASSWORD>@XEPDB1 DIRECTORY=datadir DUMPFILE=<DUMP_FILE> transform=segment_attributes:n exclude=cluster,indextype,db_link logfile=import_fastop.log ENCRYPTION_PASSWORD=<DUMP_ENCRYPTION_PASSWORD>
