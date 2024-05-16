# Azure environment

Url: https://vmdataorbis.westeurope.cloudapp.azure.com/fastop/menu/
Host: vmdataorbis.westeurope.cloudapp.azure.com  
Port: 2122    
User: orbis-dev
Admin rights: Robert.TARASIUK@ec.europa.eu

For connecting with putty from EC network you need to also configure proxy:  
in Putty settings go to Connection->Proxy, use http proxy, ps-bxl-usr.cec.eu.int, port: 8012.  

Environment variables:  
  - $FASTOP -> directory with fastop files  
  - $DOCKER -> directory with docker files
  - $ORACLE_HOME -> oracle instant client location  
  - $ORADATA -> oracle data folder (used by the oracle container)  

Environment variables used by the containers are defined in $FASTOP/etc/fastop_profile  

Folders:  
- $FASTOP/etc - contains only fastop_profile with all necessary environment variables
- $FASTOP/source - contains all sources needed to build images. Use the utility script **"git-source.sh"** to clone necessary sources and create the tar.gz file. Then copy the file to the orbis server and extract to $FASTOP/source folder.
- $FASTOP/oracle - contains oracle server data files and oracle instant client used by the 'data-access' container (da)

# Building docker images

Image must be built from the orbis machine from folder: $FASTOP/source.   

## 1. Python

    docker image build --build-arg FASTOP_API_KEY=$FASTOP_API_KEY --tag ecfin/ecfin_python_azure:1.5 -f ./fastop/docker/azure/python.dockerfile .

## 2. Node

    docker image build --build-arg FASTOP_API_KEY=$FASTOP_API_KEY --build-arg FASTOP_SECRET=$FASTOP_SECRET --tag ecfin/ecfin_node_azure:1.5 -f ./fastop/docker/azure/node.dockerfile .

## 3. Oracle express

Oracle express dockerfile source: https://github.com/oracle/docker-images/tree/main/OracleDatabase/SingleInstance  
Current version used is 21.3 express edition. All configuration files were copied from the github to fastop repo.

### 3.1 Build image

    cd $DOCKER/oracle-xe/
    ./buildContainerImage.sh -x -v 21.3.0

### 3.2 Run image to configure the database

**<main_db_pass>** - specify the main database password and run the following command:  

    docker run --name fastop_xe21 --cpuset-cpus="0-7" -p 1521:1521 -p 5500:5500 -e ORACLE_PWD=<main_db_pass> -v $ORADATA:/opt/oracle/oradata oracle/database:21.3.0-xe

* --cpuset-cpus="0-7": this option is needed to  let the oracle installer configure correctly the TARGET_SGA memory

Wait until the database setup is done.
When you see text like "DATABASE IS READY TO USE!" press Ctrl+C to exit the process.

### 3.2.1 Create fastop user and configure data-pump

If the container is not already running start it:  
    
    docker start fastop_xe21

Run to the container's bash console:

    docker exec -it fastop_xe21 bash
 
Run sqlplus using the **<main_db_pass>** created in step 3.2:  

    sqlplus sys/<main_db_pass>@XEPDB1 as sysdba

From the sqlplus console run following sql commands providing the password for the 'fastop' user:  

**<fastop_pass>** - specify the password that will be used by the 'fastop' user (the user used to connect to the db from the application)  
This password must be then defined in $FASTOP/etc/fastop_profile as **FASTOP_DB_PASSWORD** env variable.
                     
    ALTER SESSION SET CONTAINER = XEPDB1;
    CREATE USER fastop IDENTIFIED BY <fastop_pass>;
    GRANT CONNECT, RESOURCE, DBA TO fastop;
    GRANT UNLIMITED TABLESPACE TO fastop;
    GRANT CREATE SESSION TO fastop;
    ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;

Run following sql commands to configure data-pump:  

    CREATE OR REPLACE DIRECTORY DATADIR AS '/opt/oracle/oradata/files/dbin';
    GRANT READ, WRITE ON DIRECTORY DATADIR TO SYSTEM;

Exit sqlplus by running command:

    exit

### 3.2.3 Run data-pump import

Dump file must be copied on orbis machine to: $ORADATA/files/dbin  

Start the 'fastop_xe21' container and run the import tool providing:

**<dump_file_name>** - name of the dump file  
**<encryption_password>** - encryption password used during data export 

    docker exec -it fastop_xe21 bash
    impdp system/<main_db_pass>@XEPDB1 DIRECTORY=datadir DUMPFILE=<dump_file_name> transform=segment_attributes:n exclude=cluster,indextype,db_link logfile=import_fastop.log ENCRYPTION_PASSWORD=<encryption_password>  
    exit
When the import is done, stop the container and remove it:

    docker stop fastop_xe21    
    docker rm fastop_xe21  

### 4. Cleanup

To remove some docker temporary images run command:  

    docker system prune  


# Run services

    cd $DOCKER
    docker-compose up -d

Data-access waits for the fastop_db (oracle xe) container 20s. Check in the logs if the data-access was started successfully:  

    docker-compose logs da

If the data-access could not connect to the database try to restart the container:  

    docker restart da

### Logs

Display all logs:  

    docker-compose logs

Display logs for a specific container:  

    docker-compose logs da

or with 'follow' flag:

    docker-compose logs -f da

### sqlplus

Once the docker-compose command was executed you can attach to the 'fastop_db' container with sqlplus:

**<fastop_pass>** - fastop user password from step 3.2.1

    docker exec -ti fastop_db sqlplus fastop/<fastop_pass>@XEPDB1

# Data-pump

Host: ecfindp-p.cc.cec.eu.int  
Port: 22  
User: ecfindba  
Password: keepass U:\!DEV_Bxl\Keepass\Fastop.kdbx

After logging-in with ssh you need to provide the ORACLE_HOME folder.  
Use following location:  /ec/sw/oracle/client/product/19.6.0.0/

Run export command providing:

**<fastop_prod_pass>** - password for the FASTOP production database (SCOPAX_ECFIN_01_P)  
**<dump_file_name>** - name of the dump file, e.g. fastop_prod_24_05.dmp  
**<encryption_password>** - encryption password  

Optional:  
- LOGFILE - you can provide your logfile name  
- JOB_NAME - job name can be used to trace the status of the job  


    expdp fastop/<fastop_prod_pass>@SCOPAX_ECFIN_01_P DIRECTORY=SCOPAX_DBOUT SCHEMAS=fastop DUMPFILE=<dump_file_name> LOGFILE=fastop_export.log ENCRYPTION=DATA_ONLY ENCRYPTION_MODE=PASSWORD ENCRYPTION_PASSWORD=<encryption_password> EXCLUDE=DB_LINK JOB_NAME=scopax_prod_export

Exported file will be stored in: **$ORACLE_DBOUT** 

# Restore database

Start the fastop_db service:

    docker-compose up -d fastop_db
 
    docker exec -ti fastop_db sqlplus sys/<main_db_pass>@XEPDB1 as sysdba  
 
Then execute SQL commands:  

    SHUTDOWN IMMEDIATE;
    STARTUP RESTRICT;
    ALTER SESSION SET CONTAINER = XEPDB1;
    DROP USER fastop CASCADE;
    CREATE USER fastop IDENTIFIED BY <fastop_pass>;
    GRANT CONNECT, RESOURCE, DBA TO fastop;
    GRANT UNLIMITED TABLESPACE TO fastop;
    GRANT CREATE SESSION TO fastop;
	SHUTDOWN IMMEDIATE;
	STARTUP;

    exit

Then import the db from data-pump dump file: (run the container's bash)

    docker exec -ti fastop_db bash

And run the import command:

    impdp system/<main_db_pass>@XEPDB1 DIRECTORY=datadir DUMPFILE=<dump_file_name> transform=segment_attributes:n exclude=cluster,indextype,db_link logfile=import_fastop.log ENCRYPTION_PASSWORD=<encryption_password>

