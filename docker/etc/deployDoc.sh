#!/bin/bash

# program arguments:
# $1 = release version
# $2 = doc to deploy, optional

cd $FASTOP/deployDoc

if [[ ($# -lt 2 || $2 == 'fdmsstar') && -f fdmsstar.doc.tar.gz ]]; then
    echo deploying fdmsstar documentation...
    rm -rf $FASTOP/python/fdmsstar/doc/*
    tar xpzf fdmsstar.doc.tar.gz -C .
    rm fdmsstar.doc.tar.gz
    sed -i "s/release = '1.0.0'/release = '$1'/" $FASTOP/deployDoc/fdmsstar/docs/conf.py

    . $FASTOP/python/.venv/bin/activate
    cd fdmsstar
    sphinx-apidoc -o docs .
    cd docs
    make Makefile html
    deactivate

    mkdir -p $FASTOP/python/fdmsstar/doc/html
    mv _build/html $FASTOP/python/fdmsstar/doc/
    cd $FASTOP
    rm -rf $FASTOP/deployDoc/fdmsstar
fi

if [[ ($# -lt 2 || $2 == 'neer') && -f neer.doc.tar.gz ]]; then
    echo deploying neer documentation...
    rm -rf $FASTOP/python/neer/doc/*
    tar xpzf neer.doc.tar.gz -C .
    rm neer.doc.tar.gz
    sed -i "s/release = '1.0.0'/release = '$1'/" $FASTOP/deployDoc/neer/docs/conf.py

    . $FASTOP/python/.venv/bin/activate
    cd neer
    sphinx-apidoc -o docs .
    cd docs
    make Makefile html
    deactivate

    mkdir -p $FASTOP/python/neer/doc/html
    mv _build/html $FASTOP/python/neer/doc/
    cd $FASTOP
    rm -rf $FASTOP/deployDoc/neer
fi

if [[ ($# -lt 2 || $2 == 'hicp') && -f hicp.doc.tar.gz ]]; then
    echo deploying hicp documentation...
    rm -rf $FASTOP/python/hicp/doc/*
    tar xpzf hicp.doc.tar.gz -C .
    rm hicp.doc.tar.gz
    sed -i "s/release = '1.0.0'/release = '$1'/" $FASTOP/deployDoc/hicp/docs/conf.py

    . $FASTOP/python/.venv/bin/activate
    cd hicp
    sphinx-apidoc -o docs .
    cd docs
    make Makefile html
    deactivate

    mkdir -p $FASTOP/python/hicp/doc/html
    mv _build/html $FASTOP/python/hicp/doc/
    cd $FASTOP
    rm -rf $FASTOP/deployDoc/hicp
fi


echo deployment DONE
