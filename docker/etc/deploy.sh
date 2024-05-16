#!/bin/bash

# program arguments:
# $1 = release version
# $2 = app to deploy, optional

cd $FASTOP/deploy

if [[ ($# -lt 2 || $2 == 'lib') && -f lib.deploy.tar.gz ]] ; then
    echo deploying fastop libraries...
    rm -rf $FASTOP/scopax/*lib
    tar xpzf lib.deploy.tar.gz -C $FASTOP/scopax
    rm lib.deploy.tar.gz
    sed -i "s/\"version\".*/\"version\": \"$1\",/" $FASTOP/scopax/lib/package.json
fi

if [[ ($# -lt 2 || $2 == 'python-lib') && -f python-lib.deploy.tar.gz ]]; then
    echo deploying python-lib...
    rm -rf $FASTOP/python/lib/fastoplib
    tar xpzf python-lib.deploy.tar.gz -C $FASTOP
    rm python-lib.deploy.tar.gz
fi

if [[ ($# -lt 2 || $2 == 'fdmsstar') && -f fdmsstar.deploy.tar.gz ]]; then
    echo deploying fdmsstar...
    rm -rf $FASTOP/python/fdmsstar
    tar xpzf fdmsstar.deploy.tar.gz -C $FASTOP
    rm fdmsstar.deploy.tar.gz
    sed -i "s/appVersion =.*/appVersion = \'$1\'/" $FASTOP/python/fdmsstar/config.py
fi

if [[ ($# -lt 2 || $2 == 'eucam') && -f eucam.deploy.tar.gz ]]; then
    echo deploying eucam...
    rm -rf $FASTOP/python/lib/EUCAM_light
    rm -rf $FASTOP/python/eucam
    tar xpzf eucam.deploy.tar.gz -C $FASTOP
    rm eucam.deploy.tar.gz
    sed -i "s/appVersion =.*/appVersion = \'$1\'/" $FASTOP/python/eucam/config.py
fi

if [[ ($# -lt 2 || $2 == 'sdmx') && -f sdmx.deploy.tar.gz ]]; then
    echo deploying sdmx...
    rm -rf $FASTOP/python/sdmx
    tar xpzf sdmx.deploy.tar.gz -C $FASTOP
    rm sdmx.deploy.tar.gz
    sed -i "s/appVersion =.*/appVersion = \'$1\'/" $FASTOP/python/sdmx/config.py
fi

if [[ ($# -lt 2 || $2 == 'fpcalc') && -f fpcalc.deploy.tar.gz ]]; then
    echo deploying fpcalc...
    rm -rf $FASTOP/python/fpcalc
    tar xpzf fpcalc.deploy.tar.gz -C $FASTOP
    rm fpcalc.deploy.tar.gz
    sed -i "s/appVersion =.*/appVersion = \'$1\'/" $FASTOP/python/fpcalc/config.py
fi

if [[ ($# -lt 2 || $2 == 'fplm') && -f fplm.deploy.tar.gz ]]; then
    echo deploying fplm...
    rm -rf $FASTOP/python/fplm
    tar xpzf fplm.deploy.tar.gz -C $FASTOP
    rm fplm.deploy.tar.gz
    sed -i "s/appVersion =.*/appVersion = \'$1\'/" $FASTOP/python/fplm/config.py
fi

if [[ ($# -lt 2 || $2 == 'hicp') && -f hicp.deploy.tar.gz ]]; then
    echo deploying hicp...
    rm -rf $FASTOP/python/hicp
    tar xpzf hicp.deploy.tar.gz -C $FASTOP
    rm hicp.deploy.tar.gz
    sed -i "s/appVersion =.*/appVersion = \'$1\'/" $FASTOP/python/hicp/config.py
fi

if [[ ($# -lt 2 || $2 == 'amecodownload') && -f amecodownload.deploy.tar.gz ]]; then
    echo deploying ameco-download...
    rm -rf $FASTOP/python/amecodownload
    tar xpzf amecodownload.deploy.tar.gz -C $FASTOP
    rm amecodownload.deploy.tar.gz
    sed -i "s/appVersion =.*/appVersion = \'$1\'/" $FASTOP/python/amecodownload/config.py
fi

if [[ ($# -lt 2 || $2 == 'neer') && -f neer.deploy.tar.gz ]]; then
    echo deploying neer...
    rm -rf $FASTOP/python/neer
    tar xpzf neer.deploy.tar.gz -C $FASTOP
    rm neer.deploy.tar.gz
    sed -i "s/appVersion =.*/appVersion = \'$1\'/" $FASTOP/python/neer/config.py
fi

for f in *.deploy.tar.gz; do
    [ -e "$f" ] || continue
    APP=`echo $f | cut -d . -f 1`
    [[ $# -lt 2 || $2 == $APP ]] || continue
    echo deploying $APP...
    rm -rf $FASTOP/scopax/gateway/static/$APP
    rm -rf $FASTOP/scopax/$APP/dist
    tar xpzf $f -C $FASTOP/scopax
    packageJson=`tar tpzf $f | grep package.json`
    if [ -n "$packageJson" ]; then
        sed -i "s/\"version\".*/\"version\": \"$1\",/" $FASTOP/scopax/$packageJson
    fi
    versionJs=`tar tpzf $f | grep version.js`
    if [ -n "$versionJs" ]; then
        sed -i "s/const version.*/const version = \"$1\"/" $FASTOP/scopax/$versionJs
    fi
    rm -f $f
done

echo deployment DONE
