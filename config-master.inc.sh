################################################################################
# Filename    # config.inc
# Purpose     # Defines the Toolchain source versions/mirrors
# Copyright   # Copyright (C) 2011-2013 Luke A. Guest, David Rees.
# Depends     # http://gcc.gnu.org/install/prerequisites.html
# Description # 1) cp config-master.inc config.inc
#             # 2) edit config.inc as required for your machine.
#             # 3) ./build-tools.sh --help
################################################################################

################################################################################
# Project name, can change.
################################################################################
export PROJECT_NAME=free-ada

################################################################################
# So we don't overwrite an already working toolchain! This is only valid when
# building a new native toolchain. Once this has been done, move your old tools
# to a new directory and rename the new one, then remove the "-new" from the
# PROJECT variable.
# TODO: Put in a check when building cross compilers.
################################################################################
export PROJECT=$PROJECT_NAME-10.2.0

################################################################################
# INSTALL_BASE_DIR - This is where tar needs to change directory to.
# INSTALL_DIR      - Where the actual local toolchain is going to placed.
# STAGE_BASE_DIR   - This is the where we stage the install to get ready for
#                    packaging.
# STAGE_DIR        - We want to get to the base $PROJECT_NAME directory for
#                    packaging.
################################################################################
INSTALL_BASE_DIR=$HOME/opt
INSTALL_DIR=$INSTALL_BASE_DIR/$PROJECT
STAGE_BASE_DIR=/tmp/opt/$PROJECT
STAGE_DIR=$STAGE_BASE_DIR$INSTALL_DIR/..

################################################################################
# Basic directories we need.
################################################################################
export SRC=$TOP/source
export ARC=$TOP/archives
export LOG=$TOP/build/logs
export BLD=$TOP/build
export PKG=$TOP/packages
export FILES=$TOP/files

################################################################################
# Date variable for packaging anything from source control.
################################################################################
export DATE=`date +%d%m%Y`

################################################################################
# Is the host machine 64 bit? Used for LD_LIBRARY_PATH, leave blank for 32.
################################################################################
if grep -q 64 <<< $CPU; then
    export BITS=64
#    export MULTILIB="--enable-multilib"
#    export EXTRA_BINUTILS_FLAGS="--enable-64-bit-bfd"
#    export multilib_enabled="yes"
else
    export BITS=
#    export MULTILIB=""
#    export EXTRA_64_BIT_CONFIGURE=""
#    export multilib_enabled="no"
fi

################################################################################
# Parallel Make Threads/Jobs
################################################################################
# How many 'make' threads do you want to have going during the build?
# In most cases using a value greater than the number of processors
# in your machine will result in fewer and shorter I/O latency hits,
# thus improving overall throughput; this is especially true for
# slow drives and network filesystems.
# Load-average Threshold tells 'make' to spawn new jobs only when the load
# average is less than or equal to it's value. If the load average becomes
# greater, 'make' will wait until the average drops below this number,
# or until all the other jobs finish. Use only one of the options;
# Static Jobs, Scaled Jobs, or Dynamic or Static Load-average Threshold.
################################################################################
CORES=`grep 'model name' /proc/cpuinfo | wc -l`

# Static Jobs
# 1 = No Parallel Make Jobs (slow)
export JOBS_NUM=$(nproc)
export JOBS="-j $JOBS_NUM"

# Scaled Jobs, 2 jobs per cpu core (fast)
# export JOBS="-j $(($CORES*2))"

# Dynamic Load-average Threshold (slow, but can reduce cpu hammering)
# Spawn parallel processes only at < 100% core utilization
# export JOBS=--load-average=$(echo "scale=2; $CORES*100/100" | bc)

# Static Load-average Threshold
# export JOBS=--load-average=3.5


# Edit package versions/mirrors as required.

################################################################################
# Required tools ###############################################################
################################################################################

################################################################################
# BINUTILS #####################################################################
################################################################################

export BINUTILS_SNAPSHOT=n

if [ $BINUTILS_SNAPSHOT == "y" ]; then
    # Snapshot
    export BINUTILS_VERSION=2.35.90 # filename version
    export BINUTILS_SRC_VERSION=2.35.90 # extracted version
    export BINUTILS_MIRROR=ftp://sourceware.org/pub/binutils/snapshots
    export BINUTILS_TARBALL=binutils-$BINUTILS_VERSION.tar.bz2
    export BINUTILS_DIR=binutils-$BINUTILS_SRC_VERSION
else
    # Release
    export BINUTILS_VERSION=2.36.1 # filename version
    export BINUTILS_SRC_VERSION=2.36.1 # extracted version
    export BINUTILS_MIRROR=ftp://sourceware.org/pub/binutils/releases
    export BINUTILS_TARBALL=binutils-$BINUTILS_VERSION.tar.bz2
    export BINUTILS_DIR=binutils-$BINUTILS_SRC_VERSION
fi

export BINUTILS_TARBALL
export BINUTILS_SRC_VERSION

################################################################################
# GDB ##########################################################################
################################################################################
export GDB_VERSION=10.1 # filename version
export GDB_SRC_VERSION=10.1 # extracted version
export GDB_MIRROR=ftp://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gdb
#export GDB_MIRROR=http://ftp.gnu.org/gnu/gdb
export GDB_TARBALL=gdb-$GDB_VERSION.tar.xz
export GDB_DIR=gdb-$GDB_SRC_VERSION 

################################################################################
# GCC ##########################################################################
################################################################################

export NATIVE_LANGUAGES="c,c++,objc,obj-c++,ada"

export GCC_RELEASE=y
export GCC_TESTS=n

if [ $GCC_RELEASE == "y" ]; then
    export GCC_VERSION=10.2.0 # filename version
    export GCC_SRC_VERSION=$GCC_VERSION # extracted version, change if different
    export GCC_MIRROR=ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$GCC_VERSION
    export GCC_TARBALL=gcc-$GCC_VERSION.tar.xz

    export GCC_DIR=gcc-$GCC_SRC_VERSION
else
    # WARNING: DON'T USE THIS!!

    # Always get GCC from GitHub now.
    #export GCC_REPO=git@github.com:Lucretia/gcc.git
    #export GCC_REPO=https://github.com/gcc-mirror/gcc.git

    export GCC_DIR=$SRC/gcc
fi

################################################################################
# Required libs ################################################################
################################################################################

# GMP (GNU Multiple Precision Arithmetic Library)
#export GMP_VERSION=4.3.2
#export GMP_VERSION=5.1.2
#export GMP_VERSION=6.1.2
export GMP_VERSION=6.2.1
export GMP_MIRROR=ftp://ftp.gnu.org/gnu/gmp/
export GMP_TARBALL=gmp-$GMP_VERSION.tar.xz
export GMP_DIR=gmp-$GMP_VERSION

# MPC
#export MPC_VERSION=0.8.1
#export MPC_VERSION=1.0.2
#export MPC_VERSION=1.0.3
export MPC_VERSION=1.2.1
export MPC_MIRROR=ftp://ftp.gnu.org/gnu/mpc/
export MPC_TARBALL=mpc-$MPC_VERSION.tar.gz
export MPC_DIR=mpc-$MPC_VERSION

# MPFR (Multiple Precision Floating Point Computations With Correct Rounding)
# Warning! Due to the fact that TLS support is now detected automatically, the
# MPFR build can be incorrect on some platforms (compiler or system bug). Indeed,
# the TLS implementation of some compilers/platforms is buggy, and MPFR cannot
# detect every problem at configure time. Please run "make check" to see if your
# build is affected. If you get failures, you should try the
# --disable-thread-safe configure option to disable TLS and see if this solves
# these failures. But you should not use an MPFR library with TLS disabled in a
# multithreaded program (unless you know what you are doing).
#export MPFR_VERSION=2.4.2
#export MPFR_VERSION=3.1.2
#export MPFR_VERSION=3.1.5
export MPFR_VERSION=4.1.0
export MPFR_MIRROR=https://www.mpfr.org/mpfr-$MPFR_VERSION
export MPFR_PATCHES=https://www.mpfr.org/mpfr-$MPFR_VERSION/allpatches
export MPFR_TARBALL=mpfr-$MPFR_VERSION.tar.xz
export MPFR_DIR=mpfr-$MPFR_VERSION

# ISL
# The --with-isl configure option should be used if ISL is not installed in your
# default library search path.
# export ISL_VERSION=0.16.1
export ISL_VERSION=0.23
export ISL_MIRROR=http://isl.gforge.inria.fr
#export ISL_MIRROR=ftp://gcc.gnu.org/pub/gcc/infrastructure
export ISL_TARBALL=isl-$ISL_VERSION.tar.bz2
export ISL_DIR=isl-$ISL_VERSION

################################################################################
# Python
################################################################################
export PYTHON_VERSION_SHORT=3.8
export PYTHON_VERSION=${PYTHON_VERSION_SHORT}.8
export PYTHON_EXE="python${PYTHON_VERSION_SHORT}"
export PIP_EXE="pip${PYTHON_VERSION_SHORT}"
export PYTHON_MIRROR=https://www.python.org/ftp/python/$PYTHON_VERSION/
export PYTHON_TARBALL=Python-$PYTHON_VERSION.tar.xz
export PYTHON_DIR=Python-$PYTHON_VERSION

################################################################################
# AdaCore GPL components #######################################################
################################################################################
export GPL_YEAR=2018
#export ASIS_HASH=51ecea080c3c6760cd024e8b467502de26f3c3f2
#export ASIS_VERSION=asis-gpl-$GPL_YEAR-src
#export GNATMEM_HASH=6de65bb7e300e299711f90396710ace741123656
#export GNATMEM_VERSION=gnatmem-gpl-$GPL_YEAR-src
#export POLYORB_HASH=22f27fec50a9c2b92be2e10aa5027eb49567787c
#export POLYORB_VERSION=polyorb-gpl-$GPL_YEAR-src
#export POLYORB_DIR=polyorb-$GPL_YEAR-src
#export FLORIST_HASH=224f73e1cd4afd1f0f6ca3bd1ad0191aa7f81e05
#export FLORIST_VERSION=florist-gpl-$GPL_YEAR-src
#export FLORIST_DIR=florist-src

export ADACORE_DOWNLOAD_MIRROR="http://mirrors.cdn.adacore.com/art/"
export ADACORE_GITHUB="https://github.com/AdaCore"

export GPRBUILD_VERSION=21.0.0
export GPRBUILD_DIR="gprbuild-${GPRBUILD_VERSION}"
export GPRBUILD_MIRROR=${ADACORE_GITHUB}/gprbuild/archive/v${GPRBUILD_VERSION}
export GPRBUILD_TARBALL=${GPRBUILD_DIR}.tar.gz

export GPRCONFIG_KB_VERSION=21.0.0
export GPRCONFIG_KB_DIR="gprconfig_kb-${GPRCONFIG_KB_VERSION}"
export GPRCONFIG_KB_MIRROR=${ADACORE_GITHUB}/gprconfig_kb/archive/v${GPRCONFIG_KB_VERSION}
export GPRCONFIG_KB_TARBALL=${GPRCONFIG_KB_DIR}.tar.gz

export XMLADA_VERSION=21.0.0
export XMLADA_DIR="xmlada-${XMLADA_VERSION}"
export XMLADA_MIRROR=${ADACORE_GITHUB}/xmlada/archive/v${XMLADA_VERSION}
export XMLADA_TARBALL=${XMLADA_DIR}.tar.gz

export GNATCOLL_CORE_VERSION=21.0.0
export GNATCOLL_CORE_DIR="gnatcoll-core-${GNATCOLL_CORE_VERSION}"
export GNATCOLL_CORE_MIRROR=${ADACORE_GITHUB}/gnatcoll-core/archive/v${GNATCOLL_CORE_VERSION}
export GNATCOLL_CORE_TARBALL=${GNATCOLL_CORE_DIR}-${GNATCOLL_CORE_VERSION}.tar.gz

export GNATCOLL_BINDINGS_VERSION=21.0.0
export GNATCOLL_BINDINGS_DIR="gnatcoll-bindings-${GNATCOLL_BINDINGS_VERSION}"
export GNATCOLL_BINDINGS_MIRROR=${ADACORE_GITHUB}/gnatcoll-bindings/archive/v${GNATCOLL_BINDINGS_VERSION}
export GNATCOLL_BINDINGS_TARBALL=${GNATCOLL_BINDINGS_DIR}.tar.gz
export GNATCOLL_BINDINGS_GMP=y
export GNATCOLL_BINDINGS_ICONV=y
export GNATCOLL_BINDINGS_LZMA=y
export GNATCOLL_BINDINGS_OMP=y
export GNATCOLL_BINDINGS_PYTHON=y
export GNATCOLL_BINDINGS_READLINE=y
export GNATCOLL_BINDINGS_SYSLOG=y
export GNATCOLL_BINDINGS_ZLIB=y

export GNATCOLL_DB_VERSION=21.0.0
export GNATCOLL_DB_DIR="gnatcoll-db-${GNATCOLL_DB_VERSION}"
export GNATCOLL_DB_MIRROR=${ADACORE_GITHUB}/gnatcoll-db/archive/v${GNATCOLL_DB_VERSION}
export GNATCOLL_DB_TARBALL=${GNATCOLL_DB_DIR}.tar.gz
export GNATCOLL_DB=y

export LANGKIT_VERSION=21.0.0
export LANGKIT_DIR="langkit-${LANGKIT_VERSION}"
export LANGKIT_MIRROR=${ADACORE_GITHUB}/langkit/archive/v${LANGKIT_VERSION}
export LANGKIT_TARBALL=${LANGKIT_VERSION_DIR}.tar.gz
export LANGKIT_PATCHES="${FILES}/${LANGKIT_DIR}/0001-Add-view-conversion-to-fix-compile.patch"

export LIBADALANG_VERSION=21.0.0
export LIBADALANG_DIR="libadalang-${LIBADALANG_VERSION}"
export LIBADALANG_MIRROR=${ADACORE_GITHUB}/libadalang/archive/v${LIBADALANG_VERSION}
export LIBADALANG_TARBALL=${LIBADALANG_DIR}.tar.gz

export LIBADALANG_TOOLS_DIR="libadalang-tools"
export LIBADALANG_TOOLS_GIT="${ADACORE_GITHUB}/libadalang-tools.git"
export LIBADALANG_TOOLS_BRANCH="21.0"
export LIBADALANG_TOOLS_COMMIT="a1dedd8bbbc1607405a32bf037d46863d6e3eb81"

export AUNIT_DIR="aunit"
export AUNIT_GIT="${ADACORE_GITHUB}/aunit.git"
export AUNIT_BRANCH="master"
export AUNIT_COMMIT="fd9801b79b56f5dd55ab1e6500f16daf5dd12fc9"

export GNAT_UTIL_DIR=gnat_util

export ASIS_GPL_YEAR=2016
export ASIS_HASH=57399029c7a447658e0aff71
export ASIS_VERSION_PREFIX=asis-gpl-${ASIS_GPL_YEAR}-src
export ASIS_VERSION=${ASIS_VERSION_PREFIX}

export ASIS_MIRROR="${ADACORE_DOWNLOAD_MIRROR}"
export ASIS_TARBALL="${ASIS_VERSION}.tar.gz"
export ASIS_DIR=${ASIS_VERSION_PREFIX}


export GTKADA_MIRROR="${ADACORE_GITHUB}/gtkada.git"
export GTKADA_DIR=gtkada

export GPS_MIRROR="${ADACORE_GITHUB}/gps.git"
export GPS_DIR=gps

# For Spark
#export _MIRROR="${ADACORE_GITHUB}/"
#export _DIR=

################################################################################
# Additional Options ###########################################################
################################################################################

export MATRESHKA_VERSION=0.7.0
export MATRESHKA_MIRROR=http://forge.ada-ru.org/matreshka/downloads
export MATRESHKA_DIR=matreshka-$MATRESHKA_VERSION

export AHVEN_VERSION=2.6
export AHVEN_MIRROR=http://www.ahven-framework.com/releases
export AHVEN_DIR=ahven-$AHVEN_VERSION

# export U_BOOT_VERSION=1.3.4
# export U_BOOT_MIRROR=ftp://ftp.denx.de/pub/u-boot
#export NEWLIB_VERSION=1.20.0
#export NEWLIB_MIRROR=ftp://sources.redhat.com/pub/newlib
#export STLINK_MIRROR=git://github.com/texane/stlink.git
# export SPARK_FILE=spark-gpl-2011-x86_64-pc-linux-gnu.tar.gz

# Bootstrap builds #############################################################
#
# These builds consist of two types of build, a normal cross compiler using an
# existing system root (--sysroot flag) and a host-x-host compiler which is
# a compiler built to run on that system and produce binaries for that system.
#
# See https://gcc.gnu.org/onlinedocs/gccint/Configure-Terms.html
#
# The toolchains required to be built to gain a native i686 Linux bootstrap
# compiler are as follows:
#
# e.g. Cross compiler
#   --build=x86_64-pc-linux-gnu = Built compiler is built on amd64 Linux
#   --host=x86_64-pc-linux-gnu  = Built compiler runs on amd64 Linux
#   --target=i686-pc-linux-gnu  = Built compiler builds programs for x86 Linux
#
# and e.g. host-x-host
#   --build=x86_64-pc-linux-gnu = Built compiler is built on amd64 Linux
#   --host=i686-pc-linux-gnu    = Built compiler runs on x86 Linux
#   --target=i686-pc-linux-gnu  = Built compiler builds programs for x86 Linux
#
# The host-x-host compiler wouldn't need binutils as these should be supplied
# by the installed OS on which this compiler is to run.
################################################################################

# For bootstrap builds we are building compilers for full systems
#SYSROOT_X86_LINUX	=	<point me to>/usr
#SYSROOT_AMD64_LINUX	=	<point me to>/usr
#SYSROOT_SPARC_LINUX	=	<point me to>/usr
#SYSROOT_MIPS_LINUX	=	<point me to>/usr
#SYSROOT_ARM_LINUX	=	<point me to>/usr
#SYSROOT_AMD64_WINDOWS	=	<point me to>/usr

# This flag tells the script whether to just build the bootstrap packages
#INSTALL_BOOTSTRAPS	=	n

# Build this bootstrap statically, no shared libs.
#STATIC_BOOTSTRAP	=	y

#BOOTSTRAP_VERSION=$(echo $GCC_VERSION | awk -F \. {'print $1"."$2'})
#BOOTSTRAP_BASE_DIR=/tmp/free-ada-bootstrap
#BOOTSTRAP_DIR=$BOOTSTRAP_BASE_DIR/usr

#X86_64_BOOTSTRAP_TARBALL="gnatboot-${BOOTSTRAP_VERSION}-amd64.tar.xz"
#X86_64_BOOTSTRAP_MIRROR="https://www.dropbox.com/s/8qz551so8xn4t9r/${X86_64_BOOTSTRAP_TARBALL}?dl=0"

BOOTSTRAP_MIRROR="https://community.download.adacore.com/v1/"
X86_64_LINUX_BOOTSTRAP_TARBALL="9682e2e1f2f232ce03fe21d77b14c37a0de5649b"
X86_64_LINUX_BOOTSTRAP_TARBALL_NAME="gnat-gpl-2017-x86_64-linux-bin.tar.gz"
X86_64_MACOS_BOOTSTRAP_TARBALL="7bbc77bd9c3c03fdb93699bce67b458f95d049a9"
X86_64_MACOS_BOOTSTRAP_TARBALL_NAME="gnat-gpl-2017-x86_64-darwin-bin.tar.gz"
#X86_64_WINDOWS_BOOTSTRAP_TARBALL=""

BOOTSTRAP_DIR="$HOME/opt/gnat-gpl-2017"

################################################################################
# Implementation specific tuning ###############################################
################################################################################

# Versions of the GNU C library up to and including 2.11.1 included an incorrect
# implementation of the cproj function. GCC optimizes its builtin cproj according
# to the behavior specified and allowed by the ISO C99 standard. If you want to
# avoid discrepancies between the C library and GCC's builtin transformations
# when using cproj in your code, use GLIBC 2.12 or later. If you are using an
# older GLIBC and actually rely on the incorrect behavior of cproj, then you can
# disable GCC's transformations using -fno-builtin-cproj.

#export EXTRA_NATIVE_CFLAGS="-march=native"

################################################################################
# GMP, MPFR, MPC static lib installation directory #############################
################################################################################
# export STAGE1_LIBS_PREFIX=$STAGE1_PREFIX/opt/libs
# export STAGE2_LIBS_PREFIX=$STAGE2_PREFIX/opt/libs
