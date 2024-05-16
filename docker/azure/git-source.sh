#!/bin/bash

git clone --depth 1 -b release/production https://citnet.tech.ec.europa.eu/CITnet/stash/scm/fastop/fastop.git source/fastop
git clone --depth 1 -b release/production https://citnet.tech.ec.europa.eu/CITnet/stash/scm/fdmsstar/fdmsstar.git source/fdmsstar
git clone --depth 1 -b release/production https://citnet.tech.ec.europa.eu/CITnet/stash/scm/ameco/ameco-download.git source/ameco-download
git clone --depth 1 -b release/production https://citnet.tech.ec.europa.eu/CITnet/stash/scm/ogpy/eucam.git source/eucam
git clone --depth 1 -b release/production https://citnet.tech.ec.europa.eu/CITnet/stash/scm/hicpecfin/hicp_python.git source/hicp_python
git clone --depth 1 -b release/production https://citnet.tech.ec.europa.eu/CITnet/stash/scm/neerpy/neer_py.git source/neer_py

tar cpzf source.tar.gz source
rm -rf source

