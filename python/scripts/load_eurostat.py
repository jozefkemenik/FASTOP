#-------------------------------------------------------------------------------------------------
# Import Eurostat data
# -----------------------------
# parametres : argv[] - all parameters are optional
# sys.argv[1] = indicator name - sert pour le nom du fichier tsv, default: 'gov_10a_main'
# sys.argv[2] = path to the input data file folder, current folder by default
# sys.argv[3] = round sid for which to load the data, current SCP round by default
#-------------------------------------------------------------------------------------------------
import sys
import os
import cx_Oracle

if len(sys.argv) > 4:
    print ('usage:', __file__, '[indicator name] [input data path] [round sid]' )
    sys.exit()
else:
    in_indicator = sys.argv[1] if len(sys.argv) > 1 else 'gov_10a_main'
    file_path = sys.argv[2] if len(sys.argv) > 2 else '.'
    round_sid = int(sys.argv[3]) if len(sys.argv) > 3 else 0

print(in_indicator, file_path, round_sid)

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

def get_round_year( conn, round_sid ):
    sql = "select year from rounds where round_sid = :round"
    myRes = fetchOneRecord(conn, sql, round = round_sid)
    if myRes == None:
        print (f'Invalid round: {round_sid}')
        return -1
    else:
        print (f'Retrieved round year: {myRes[0]}')
        return myRes[0]

def isCountry( conn, cty ):
    sql = "select count(*) from countries where country_id = :cty"
    myRes = fetchOneRecord(conn, sql, cty = cty)
    return myRes[0]

def getIndicatorSid( conn, id ):
    sql = "select indicator_sid from indicators where indicator_id = :id"
    myRes = fetchOneRecord(conn, sql, id = id)
    if myRes == None:
        return -1
    else:
        return myRes[0]

#
# Main routine
# --------------------------------------------------------------------
user = os.getenv('USERNAME')
db = os.getenv('FASTOP_DB')
print(f'Connecting to {db}')
conn = cx_Oracle.connect('FASTOP', os.getenv('FASTOP_DB_PASSWORD'), db)

if round_sid == 0:
    round_sid = get_current_round(conn)
valueYear = get_round_year(conn, round_sid) - 1


with open( os.path.join( file_path, in_indicator + '.tsv'), 'r' ) as myFile:

    myHeader = myFile.readline()
    print(myHeader)
    myYear= myHeader.split().index(str(valueYear))

    for myLine in myFile.readlines():
        
        myRec = myLine.split()
        myKey = myRec[0].split(",")
        freq,unit,sector,ESA,country_id = myKey
        indicator_id = in_indicator + "." + ESA + "." + unit + "." + sector

        myRes = myKey
        myRes.append( myRec[myYear] )
        indicator_sid = getIndicatorSid( conn, indicator_id )

        if isCountry( conn, country_id )> 0 and indicator_sid != -1 and round_sid != -1:
            cell_value = myRec[myYear].split()[0]
            if cell_value != ":" and cell_value != "b" and cell_value != "p" and cell_value != "z":
                val = float(cell_value)
            else:
                val = None

            print ( f'country_id={country_id}, - indicator_sid={indicator_sid}, val={val}' )
            mySql = """
                INSERT INTO ESTAT_INDIC_DATA (
                    round_sid, indicator_sid, country_id, year, na_item, sector, unit, value, last_change_user, last_change_date
                )
                VALUES (
                    :round, :indicator, :country, :year, :na_item, :sector, :unit, :value, :username, SYSDATE
                )
            """
            myCursor = conn.cursor()    
            myCursor.execute( mySql,
                round = round_sid,
                indicator = indicator_sid,
                country = country_id,
                year = valueYear,
                na_item = ESA,
                sector = sector,
                unit = unit,
                value = val,
                username = user
            )
            conn.commit()
