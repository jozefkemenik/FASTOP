#-------------------------------------------------------------------------------------------------
# Import Ameco PH data
# -----------------------------
# parametres : argv[] - all parameters are optional
# sys.argv[1] = path to the input data file, default ./AMECO_R.csv
# sys.argv[2] = round sid for which to load the data, current SCP round by default
#-------------------------------------------------------------------------------------------------
import sys
import os
import cx_Oracle

if len(sys.argv) > 2:
    print ('usage:', __file__, '[input data file] [round sid]' )
    sys.exit()
else:
    input_file = sys.argv[1] if len(sys.argv) > 1 else './AMECO_R.csv'
    round_sid = int(sys.argv[2]) if len(sys.argv) > 2 else 0

print(input_file, round_sid)

#
# subroutines
#-------------------------------------------------------------
def fetchRecords ( conn, sql, **kwargs ):
    myCursor = conn.cursor()
    myCursor.execute( sql, **kwargs )
    res = myCursor.fetchall()
    myCursor.close()
    return res

def fetchOneRecord ( conn, sql, **kwargs ):
    myCursor = conn.cursor()
    try:
        myCursor.execute( sql, **kwargs )
        res = myCursor.fetchone()
    except cx_Oracle.DatabaseError as exc:
        error, = exc.args
        print("Oracle-Error-Code:", error.code)
        print("Oracle-Error-Message:", error.message)
        return "", exc
    except cx_Oracle.Warning as w:
        warn, = w.args
        print("Oracle-warn:", warn)
        return "", w

    myCursor.close()
    return ( res )

def get_current_round( conn ):
    sql = "select core_getters.getCurrentRoundSid('SCP') from dual"
    myRes = fetchOneRecord(conn, sql)
    if myRes == None:
        print ('Error getting current round')
        return -1
    else:
        print (f'Retrieved current round: {myRes[0]}')
        return myRes[0]

def isCountry( conn, cty ):
    sql = "select count(*) from countries where country_id = :cty"
    myRes = fetchOneRecord(conn, sql, cty = cty)
    return myRes[0]

def getCountryId( conn, iso ):
    sql = "select geo_area_id from geo_areas where codeiso3 = :iso"
    myRes = fetchOneRecord(conn, sql, iso = iso)
    if myRes == None:
        return ''
    else:
        return myRes[0]

def getIndicatorSid( conn, id ):
    sql = "select indicator_sid from vw_fdms_indicators where indicator_id = :id and provider_id = 'AMECO_PH' and periodicity_id = 'A'"
    myRes = fetchOneRecord(conn, sql, id = id)
    if myRes == None:
        return -1
    else:
        return myRes[0]

def getScaleSid( conn, id ):
    sql = "select scale_sid from fdms_scales where scale_id = :id"
    myRes = fetchOneRecord(conn, sql, id = id)
    if myRes == None:
        return -1
    else:
        return myRes[0]

def cleanDB( conn, round_sid ):
    mySql = "delete from FDMS_AMECO_PH_DATA where ROUND_SID = :round"
    myCursor = conn.cursor()
    myCursor.execute( mySql, round = round_sid )
    conn.commit()

    mySql = """
        delete from FDMS_CTY_INDICATOR_SCALES where INDICATOR_SID in
            (select INDICATOR_SID from VW_FDMS_INDICATORS where PROVIDER_ID = 'AMECO_PH')
    """
    myCursor = conn.cursor()
    myCursor.execute( mySql )
    conn.commit()


#
# Main routine
# --------------------------------------------------------------------
user = os.getenv('USERNAME')
conn = cx_Oracle.connect('FASTOP', os.getenv('FASTOP_DB_PASSWORD'), os.getenv('FASTOP_DB'))

if round_sid == 0:
    round_sid = get_current_round(conn)


with open( input_file, 'r' ) as myFile:

    myHeader = myFile.readline()
    print(myHeader)
    cleanDB( conn, round_sid )

    for myLine in myFile.readlines():

        # myRec = myLine.split("\t")
        # country_id, indicator_id, scale = myRec[:3]
        # values = ','.join(myRec[3:39])  # years 1960-1995

        # scale_sid = getScaleSid( conn, scale[:-1].upper() )
        # indicator_sid = getIndicatorSid( conn, indicator_id )

        myRec = myLine.split(",")
        code, _, scale = myRec[:3]
        code_elements = code.split(".")
        country_iso = code_elements[0]
        indicator_id = f'{code_elements[5]}.{".".join(code_elements[1:5])}'
        values = ','.join(myRec[5:41])  # years 1960-1995
        
        scale_sid = getScaleSid( conn, scale[:-1].upper() )
        indicator_sid = getIndicatorSid( conn, indicator_id )
        country_id = getCountryId( conn, country_iso )

        if len(country_id) > 0 and indicator_sid != -1:
            print ( f'country_id={country_id}, indicator={indicator_id} ({indicator_sid}), scale_sid={scale_sid}, val={values}' )
            if scale_sid < 0:
                print( f'invalid scale: {scale}')
                continue

            mySql = """
                INSERT INTO FDMS_CTY_INDICATOR_SCALES (country_id, indicator_sid, scale_sid)
                VALUES (:country, :indicator, :scale)
            """
            myCursor = conn.cursor()    
            myCursor.execute( mySql,
                country = country_id,
                indicator = indicator_sid,
                scale = scale_sid,
            )
            conn.commit()

            mySql = """
                INSERT INTO FDMS_AMECO_PH_DATA (
                    country_id, round_sid, indicator_sid, start_year, timeserie_data, update_date, update_user
                )
                VALUES (
                    :country, :round, :indicator, 1960, :vector, SYSDATE, :username
                )
            """
            myCursor = conn.cursor()    
            myCursor.execute( mySql,
                country = country_id,
                round = round_sid,
                indicator = indicator_sid,
                vector = values,
                username = user
            )
            conn.commit()
