#-------------------------------------------------------------------------------------------------
# Import Ameco PH data
# -----------------------------
# parametres : argv[] - all parameters are optional
# sys.argv[1] = path to the input data file, default ./ameco_r.txt
# sys.argv[2] = round sid for which to load the data, current round by default
#-------------------------------------------------------------------------------------------------
import sys
import os
import cx_Oracle

if len(sys.argv) > 2:
    print ('usage:', __file__, '[input data file] [round sid]' )
    sys.exit()
else:
    input_file = sys.argv[1] if len(sys.argv) > 1 else './ameco_r.txt'
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
    sql = "select core_getters.getCurrentRoundSid() from dual"
    myRes = fetchOneRecord(conn, sql)
    if myRes == None:
        print ('Error getting current round')
        return -1
    else:
        print (f'Retrieved current round: {myRes[0]}')
        return myRes[0]

def getCountryId( conn, iso ):
    sql = "select geo_area_id from geo_areas where codeiso3 = :iso"
    myRes = fetchOneRecord(conn, sql, iso = iso)
    if myRes == None:
        return ''
    else:
        return myRes[0]

def getIndicatorSid( conn, id ):
    sql = "select indicator_sid from indicators where indicator_id = :id and source = 'AMECO'"
    myRes = fetchOneRecord(conn, sql, id = id)
    if myRes == None:
        return -1
    else:
        return myRes[0]

def cleanDB( conn, round_sid ):
    mySql = "delete from AMECO_INDIC_DATA where ROUND_SID = :round"
    myCursor = conn.cursor()
    myCursor.execute( mySql, round = round_sid )
    conn.commit()


#
# Main routine
# --------------------------------------------------------------------
user = os.getenv('USERNAME')
conn = cx_Oracle.connect('FASTOP', os.getenv('FASTOP_DB_PASSWORD'), os.getenv('FASTOP_DB'))

if round_sid == 0:
    round_sid = get_current_round(conn)


with open( input_file, 'r' ) as myFile:

    cleanDB( conn, round_sid )

    for myLine in myFile.readlines():

        myRec = myLine.split(";")
        code, _, start_year = myRec[:3]
        code_elements = code.split(".")
        country_iso = code_elements[0]
        indicator_id = ".".join(code_elements[1:6])
        values = ','.join(myRec[4:])
        
        indicator_sid = getIndicatorSid( conn, indicator_id )
        country_id = getCountryId( conn, country_iso )

        if len(country_id) > 0 and indicator_sid != -1:
            print ( f'country_id={country_id}, indicator={indicator_id} ({indicator_sid}), val={values}' )

            mySql = """
                INSERT INTO AMECO_INDIC_DATA (
                    country_id, round_sid, indicator_sid, start_year, vector, last_change_date, last_change_user
                )
                VALUES (
                    :country, :round, :indicator, :start_year, :vector, SYSDATE, :username
                )
            """
            myCursor = conn.cursor()    
            myCursor.execute( mySql,
                country = country_id,
                round = round_sid,
                indicator = indicator_sid,
                start_year = start_year,
                vector = values,
                username = user
            )
            conn.commit()
