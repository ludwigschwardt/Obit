#!/bin/sh
# Script/Notes for installing 3rd party software for Obit
# Need to set LD_LIBRARY_PATH PYTHON_PATH
#------------------------------------------------------------------------------
#  Which libraries wanted
doPLPLOT=yes
doCFITSIO=yes
doGLIB=yes
doFFTW=yes
doGSL=yes
doZLIB=yes
doMOTIF=yes
doPYTHON=yes
doWWW=no
doCURL=yes
doXMLRPC=yes
doBoost=yes
doWVR=yes

# Check command line arguments
arg=$1
if test $arg = -without; then
    for x in $@; do
	if test $x = PLPLOT;  then doPLPLOT=no;fi
	if test $x = CFITSIO; then doCFITSIO=no;fi
	if test $x = GLIB;    then doGLIB=no; fi
	if test $x = FFTW;    then doFFTW=no; fi
	if test $x = GSL;     then doGSL=no; fi
	if test $x = ZLIB;    then doZLIB=no; fi
	if test $x = MOTIF;   then doMOTIF=no; fi
	if test $x = PYTHON;  then doPYTHON=no; fi
	if test $x = WWW;     then doWWW=no; fi
	if test $x = CURL;    then doCURL=no; fi
	if test $x = XMLRPC;  then doXMLRPC=no; fi
	if test $x = BOOST;   then doBOOST=no; fi
	if test $x = WVR;     then doWVR=no; fi
    done
fi
if test $arg = -help; then
    echo "Build Obit software"
    echo "Third party software may be deselected with -without and any of the following"
    echo "to use a version of the package installed in a standard place"
    echo "PLPLOT - graphics library"
    echo "CFITSIO - FITS library"
    echo "GLIB - GNU extensions to c"
    echo "FFTW - Fourier transform package"
    echo "GSL - GNU Scientific Library"
    echo "ZLIB - Compression library"
    echo "MOTIF - Motif graphics library"
    echo "PYTHON - Python"
    echo "WWW - Internet protocol library"
    echo "CURL - Internet URL library"
    echo "XMLRPC - XMLRPC network protocol library"
    echo "BOOST  - library to make c++ into a usable language (for WVR)"
    echo "WVR  - Bojan Nikolic ALMA WVR library"
fi
echo "doPLPLOT $doPLPLOT"
echo "doCFITSIO $doCFITSIO"
echo "doGLIB $doGLIB"
echo "doFFTW $doFFTW"
echo "doGSL $doGSL"
echo "doZLIB $doZLIB"
echo "doMOTIF $doMOTIF"
echo "doPYTHON $doPYTHON"
echo "doWWW $doWWW"
echo "doCURL $doCURL"
echo "doXMLRPC $doXMLRPC"
echo "doBoost $doBoost"
echo "doWVR $doWVR"

# Base address
BASE3=`pwd`; export BASE3

# Set compiler
CC=/usr/bin/gcc; export CC
CXX=/usr/bin/g++; export CXX

# Obit base directory
OBIT=$BASE3/../Obit;export OBIT

# Set paths
PYTHONPATH=$OBIT/python;export PYTHONPATH
LD_LIBRARY_PATH=$BASE3/lib; export LD_LIBRARY_PATH
PATH=$PATH:$BASE3/bin;export PATH
PKG_CONFIG_PATH=$BASE3/lib/pkgconfig/

# Third party software:

# gsl
if test $doGSL = yes; then
    cd $BASE3
# cleanup
    rm -f -r gsl-1.13
    tar xzvf tarballs/gsl-1.13.tar.gz
    cd gsl-1.13
    ./configure --prefix=$BASE3 
    make clean all install
    make clean
fi

# plplot
if test $doPLPLOT = yes; then
    cd $BASE3
# cleanup
    rm -f -r plplot-5.8.0
    tar xzvf tarballs/plplot-5.8.0.tar.gz
    cd  plplot-5.8.0
    ./configure --prefix=$BASE3/ -enable-java=no --enable-tcl=no \
	--without--python --with-double=no
    make clean all
    make install
    make clean
fi

# cfitsio
if test $doCFITSIO = yes; then
# cleanup
    cd $BASE3
    rm -f -r cfitsio
    tar xzvf tarballs/cfitsio3100.tar.gz
    cd cfitsio
    ./configure --prefix=$BASE3/ 
    make clean all install
    make clean
fi


# glib , needs pkgconfig
if test $doGLIB = yes; then
    cd $BASE3
# pkgconfig
    rm -f -r pkgconfig-0.14.0
    tar xzvf tarballs/pkgconfig-0.14.0.tar.gz
    cd pkgconfig-0.14.0
    ./configure --prefix=$BASE3/
    make clean all install
# cleanup
    cd $BASE3
    rm -f -r glib-2.2.0
    tar xzvf tarballs/glib-2.2.0.tar.gz
    cd glib-2.2.0
    ./configure --prefix=$BASE3/
    make clean all install
# Link headers where they can be found at compile time
#ln -s $BASE3/include/glib-2.0/*.h  $BASE3/include
#ln -s $BASE3/lib/glib-2.0/include/*.h  $BASE3/include
#    make clean
fi

# fftw3
if test $doFFTW = yes; then
    cd $BASE3
# cleanup
    rm -f -r fftw-3.1.2
    tar xzvf tarballs/fftw-3.1.2.tar.gz
    cd fftw-3.1.2
# Use --enable-threads for multithreaded
    ./configure --prefix=$BASE3/ --with-gcc --enable-shared --enable-float
    make clean all install
fi

# zlib
if test $doZLIB = yes; then
    cd $BASE3
# cleanup
    rm -f -r zlib-1.2.3  
    tar xzvf tarballs/zlib-1.2.3.tar.gz
    cd zlib-1.2.3
    ./configure --prefix=$BASE3
    make clean all 
    make install
    make clean
fi

# Open Motif
if test $doMOTIF = yes; then
    cd $BASE3
    # cleanup
    rm -f -r openmotif-2.3.0
    tar xzvf tarballs/openmotif-2.3.0.tar.gz
    cd openmotif-2.3.0
    ./configure --prefix=$BASE3
    make clean all 
    make install
    make clean
fi

# Python
if test $doPYTHON = yes; then
    cd $BASE3
# cleanup
    rm -f -r Python-2.7.1
    tar xzvf tarballs/Python-2.7.1.tgz
    cd Python-2.7.1
    # Build shared object python library
    ./configure --prefix=$BASE3 --enable-shared 
    make clean all 
    make install
    # Build executable interpreter without a shared library. 
    # LD_LIBRARY_PATH is not needed to start the interpreter.
    ./configure --prefix=$BASE3
    make clean all
    make install
# Link Python executable
    if test -f $BASE3/bin/python2.7; then
        ln -s $BASE3/bin/python2.7 $BASE3/../bin/python
    fi
    if test -f $BASE3/bin/python; then
       ln -s  $BASE3/bin/python $BASE3/../bin/python
    fi
    make clean
fi

# WWW (must have zlib installed in a standard location)
#if test $doWWW = yes; then
#    cd $BASE3
## cleanup
#    rm -f -r w3c-libwww-5.4.0
#    tar xzvf tarballs/w3c-libwww-5.4.0.tgz
#    cd w3c-libwww-5.4.0
#    ./configure --prefix=$BASE3 --with-zlib=$BASE3/lib/libz.a
#    make clean all 
#    make install
#    make clean
#fi

# curl
if test $doCURL = yes; then
    cd $BASE3
# cleanup
    rm -f -r curl-7.17.0
    tar xzvf tarballs/curl-7.17.0.tar.gz
    cd curl-7.17.0
    ./configure --prefix=$BASE3 --with-zlib=$BASE3/lib
    make clean all install
# Link headers where they can be found at compile time
    ln -s $BASE3/include/curl/*.h  $BASE3/include
    make clean
fi

# xmlrpc 
# Note: this needs libwww installed and libwww-config in the path
# Also needs libcurl
#setenv PATH "$PATH : $BASE3/bin"
if test $doXMLRPC = yes; then
    cd $BASE3
# cleanup
    rm -f -r xmlrpc-c-1.06.18
    tar xzvf tarballs/xmlrpc-c-1.06.18.tgz
    cd xmlrpc-c-1.06.18
# Optionally use ObitSystem www, curl
    curl_opt=" --disable-curl-client "
    if test $doCURL = yes; then
        curl_opt=" CURL_CONFIG=$BASE3/bin/curl-config "
    fi
    libwww_opt=" --disable-libwww-client"
    if test $doWWW = yes; then
        libwww_opt=" LIBWWW_CONFIG=$BASE3/bin/libwww-config "
    fi
    ./configure --prefix=$BASE3 --disable-cplusplus $curl_opt $libwww_opt
    make clean all install
# Patch xmlrpc install bugs
    rm -f $BASE3/include/XmlRpcCpp.h
    install-sh lib/libutil/.libs/libxmlrpc_util.so.3 $BASE3/lib
    install-sh lib/libutil/.libs/libxmlrpc_util.so.3.6.15 $BASE3/lib
    install-sh lib/libutil/.libs/libxmlrpc_util.a $BASE3/lib
    install-sh lib/libutil/.libs/libxmlrpc_util.lai $BASE3/lib
    #install-sh lib/libutil/.libs/libxmlrpc_util.la $BASE3/lib
    make clean
fi

# Bojan Nikolic's WVR stuff, needs c++

# Boost includes for WVR/c++
if test $doBoost = yes; then
    cd $BASE3
# Only need header files for WVR
    rm -f -r include/boost
    tar xzvf tarballs/boostheader_1_41_0.tar.gz
fi

# Bojan's WVR libraries
if test $doWVR = yes; then
    export BNMINVER=bnmin1-1.11
    export LIBAIRVER=libair-1.0.1
    export INSTALLDIR=$BASE3
    export BOOSTDIR=$BASE3
    cd $BASE3
# bnmin
    rm -f -r ${BNMINVER}
    tar xjvf tarballs/${BNMINVER}.tar.bz2
    (cd ${BNMINVER} &&
	LD_LIBRARY_PATH=$INSTALLDIR/lib:$PREREQPATH/lib \
	    PATH=$INSTALLDIR/bin:$PREREQPATH/bin:$PATH \
	    ./configure --disable-pybind --disable-buildtests --prefix=$INSTALLDIR  \
	    --includedir=$BASE3/include/almawvr --with-boost=$BOOSTDIR &&
	make && make install && cd ..)
# libAir
    rm -f -r ${LIBAIRVER}
    tar xjvf tarballs/${LIBAIRVER}.tar.bz2
    (cd ${LIBAIRVER} &&
	LD_LIBRARY_PATH=$INSTALLDIR/lib:$PREREQPATH/lib \
	    PATH=$INSTALLDIR/bin:$PREREQPATH/bin:$PATH \
	    ./configure --disable-pybind --disable-buildtests --prefix=$INSTALLDIR  \
	    --with-boost-program-options=no  --with-boost-unit-test-framework=no \
	    --includedir=$BASE3/include/almawvr --with-boost=$BOOSTDIR &&
	make && make install && cd ..)
fi

