#!/usr/bin/env bash

set -euo pipefail

#############################################
# GLOBAL VARIABLES
#############################################

# Working directories
WORKDIR="/opt/snort3"
DOWNLOADS_DIR="${WORKDIR}/downloads"
BUILD_DIR="${WORKDIR}/build"

CPU_CORES="$(nproc)"

#############################################
# VERSIONS
#############################################

PCRE2_VERSION="10.47"
BOOST_VERSION="1.85.0"
GPERFTOOLS_VERSION="2.18.1"
FLATBUFFERS_VERSION="25.2.10"
RAGEL_VERSION="6.10"
SAFELIB_VERSION="3.9.2"
VECTORSCAN_VERSION="5.4.12"
LIBDAQ_VERSION="3.0.27"
SNORT_VERSION="3.12.2.0"

#############################################
# DOWNLOAD URLS
#############################################

PCRE2_URL="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.47/pcre2-10.47.tar.gz"
BOOST_URL="https://archives.boost.org/release/1.85.0/source/boost_1_85_0.tar.gz"
GPERFTOOLS_URL="https://github.com/gperftools/gperftools/releases/download/gperftools-${GPERFTOOLS_VERSION}/gperftools-${GPERFTOOLS_VERSION}.tar.gz"
FLATBUFFERS_URL="https://github.com/google/flatbuffers/archive/refs/tags/v${FLATBUFFERS_VERSION}.tar.gz"
RAGEL_URL="http://www.colm.net/files/ragel/ragel-${RAGEL_VERSION}.tar.gz"
SAFELIB_URL="https://github.com/rurban/safeclib/releases/download/v${SAFELIB_VERSION}/safeclib-${SAFELIB_VERSION}.tar.gz"
VECTORSCAN_URL="https://github.com/VectorCamp/vectorscan/archive/refs/tags/vectorscan/${VECTORSCAN_VERSION}.tar.gz"
LIBDAQ_URL="https://api.github.com/repos/snort3/libdaq/tarball/v${LIBDAQ_VERSION}"
SNORT_URL="https://api.github.com/repos/snort3/snort3/tarball/${SNORT_VERSION}"

#############################################
# GENERAL FUNCTIONS
#############################################

log(){
    echo "[INFO] $1"
}

error(){
    echo "[ERROR] $1"
    exit 1
}

check_root(){
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root."
    fi
}

create_workdir(){
    log "Creating working directory..."
    mkdir -p "$WORKDIR"
    mkdir -p "$DOWNLOADS_DIR"
    mkdir -p "$BUILD_DIR"
}

install_system_packages(){
    log "Updating APT package index..."
    apt update

    log "Installing required system packages..."
    apt install -y \
        asciidoctor \
        autotools-dev \
        build-essential \
        cpputest \
        doxygen \
        ethtool \
        flex \
        git \
        golang-go \
        jq \
        libbz2-dev \
        libcmocka-dev \
        libdumbnet-dev \
        libhwloc-dev \
        libicu-dev \
        libluajit-5.1-dev \
        liblzma-dev \
        libmnl-dev \
        libnetfilter-queue-dev \
        libpcap-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libunwind-dev \
        openssl \
        pandoc \
        pkg-config \
        python3-pip \
        python3-venv \
        uuid-dev \
        zlib1g-dev \
        cmake

    log "System packages installed successfully."
}

download(){
    # Download source packages
}

extract(){
    # Extract compressed files
}

rebuild_pcre2_for_vectorscan(){
    log "Reconfiguring PCRE2..."

    cd "$BUILD_DIR/pcre2-${PCRE2_VERSION}"

    ./configure \
        --prefix=/usr/local \
        --enable-pcre2-16 \
        --enable-pcre2-32 \
        --enable-pcre2grep-libz \
        --enable-pcre2grep-libbz2 \
        --enable-unicode-properties \
        --enable-jit

    make clean

    log "Rebuilding PCRE2 using ${CPU_CORES} CPU cores..."
    make -j"$CPU_CORES"

    log "Reinstalling PCRE2..."
    make install

    ldconfig
}

#############################################
# DEPENDENCY INSTALLATION
#############################################

install_pcre2(){
    log "Installing PCRE2 ${PCRE2_VERSION}..."

    log "Downloading PCRE2..."
    cd "$DOWNLOADS_DIR"
    wget "$PCRE2_URL"

    log "Extracting PCRE2..."
    tar -xzf "pcre2-${PCRE2_VERSION}.tar.gz"

    log "Preparing build directory..."
    mv "pcre2-${PCRE2_VERSION}" "$BUILD_DIR"

    cd "$BUILD_DIR/pcre2-${PCRE2_VERSION}"

    log "Configuring PCRE2..."
    ./configure \
        --enable-pcre2-16 \
        --enable-pcre2-32 \
        --enable-pcre2grep-libz \
        --enable-pcre2grep-libbz2 \
        --disable-static

    log "Compiling PCRE2 using ${CPU_CORES} CPU cores..."
    make -j"$CPU_CORES"

    log "Installing PCRE2..."
    make install

    log "Updating shared library cache..."
    ldconfig

    log "PCRE2 ${PCRE2_VERSION} installed successfully."
}

install_boost(){
    log "Installing Boost ${BOOST_VERSION}..."

    log "Downloading Boost..."
    cd "$DOWNLOADS_DIR"
    wget "$BOOST_URL"

    log "Extracting Boost..."
    tar -xzf "boost_1_85_0.tar.gz"

    log "Preparing build directory..."
    mv "boost_1_85_0" "$BUILD_DIR"

    cd "$BUILD_DIR/boost_1_85_0"

    log "Installing ICU development package..."

    log "Bootstrapping Boost..."
    ./bootstrap.sh --with-python=python3

    log "Compiling and installing Boost using ${CPU_CORES} CPU cores..."
    ./b2 -j"$CPU_CORES" install

    log "Boost ${BOOST_VERSION} installed successfully."
}

install_gperftools(){
    log "Installing gperftools ${GPERFTOOLS_VERSION}..."

    log "Downloading gperftools..."
    cd "$DOWNLOADS_DIR"
    wget "$GPERFTOOLS_URL"

    log "Extracting gperftools..."
    tar -xzf "gperftools-${GPERFTOOLS_VERSION}.tar.gz"

    log "Preparing build directory..."
    mv "gperftools-${GPERFTOOLS_VERSION}" "$BUILD_DIR"

    cd "$BUILD_DIR/gperftools-${GPERFTOOLS_VERSION}"

    log "Installing required packages..."
    apt install -y \

    log "Installing pprof..."
    go install github.com/google/pprof@latest

    log "Creating symbolic link for pprof..."
    ln -sf /root/go/bin/pprof /usr/local/bin/pprof

    log "Configuring gperftools..."
    ./configure

    log "Compiling gperftools using ${CPU_CORES} CPU cores..."
    make -j"$CPU_CORES"

    log "Installing gperftools..."
    make install

    log "Updating shared library cache..."
    ldconfig

    log "gperftools ${GPERFTOOLS_VERSION} installed successfully."
}

install_flatbuffers()
{
    local ARCHIVE_NAME="flatbuffers-${FLATBUFFERS_VERSION}.tar.gz"
    local SOURCE_DIR

    log "Installing FlatBuffers ${FLATBUFFERS_VERSION}..."

    log "Downloading FlatBuffers..."
    cd "$DOWNLOADS_DIR"
    wget "$FLATBUFFERS_URL" -O "$ARCHIVE_NAME"

    SOURCE_DIR=$(tar -tf "$ARCHIVE_NAME" | head -1 | cut -d/ -f1)

    log "Extracting FlatBuffers..."
    tar -xzf "$ARCHIVE_NAME"

    log "Preparing build directory..."
    mv "$SOURCE_DIR" "$BUILD_DIR"

    cd "$BUILD_DIR/$SOURCE_DIR"

    log "Configuring FlatBuffers..."
    cmake -G "Unix Makefiles"

    log "Compiling FlatBuffers using ${CPU_CORES} CPU cores..."
    make -j"$CPU_CORES"

    log "Installing FlatBuffers..."
    make install

    log "Creating build directory..."
    mkdir -p build
    cd build

    log "Configuring shared library build..."
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DFLATBUFFERS_BUILD_SHAREDLIB=ON

    log "Compiling FlatBuffers shared library using ${CPU_CORES} CPU cores..."
    make -j"$CPU_CORES"

    log "Installing FlatBuffers shared library..."
    make install

    log "Updating shared library cache..."
    ldconfig

    log "FlatBuffers ${FLATBUFFERS_VERSION} installed successfully."
}

install_ragel(){
    local ARCHIVE_NAME="ragel-${RAGEL_VERSION}.tar.gz"
    local SOURCE_DIR

    log "Installing Ragel ${RAGEL_VERSION}..."

    log "Downloading Ragel..."
    cd "$DOWNLOADS_DIR"
    wget "$RAGEL_URL"

    SOURCE_DIR=$(tar -tf "$ARCHIVE_NAME" | head -1 | cut -d/ -f1)

    log "Extracting Ragel..."
    tar -xzf "$ARCHIVE_NAME"

    log "Preparing build directory..."
    mv "$SOURCE_DIR" "$BUILD_DIR"

    cd "$BUILD_DIR/$SOURCE_DIR"

    log "Configuring Ragel..."
    ./configure

    log "Compiling Ragel using ${CPU_CORES} CPU cores..."
    make -j"$CPU_CORES"

    log "Installing Ragel..."
    make install

    log "Updating shared library cache..."
    ldconfig

    log "Verifying Ragel installation..."
    ragel -v

    log "Ragel ${RAGEL_VERSION} installed successfully."
}

install_safeclib(){
    local ARCHIVE_NAME="safeclib-${SAFELIB_VERSION}.tar.gz"
    local SOURCE_DIR

    log "Installing SafeCLib ${SAFELIB_VERSION}..."

    log "Downloading SafeCLib..."
    cd "$DOWNLOADS_DIR"
    wget "$SAFELIB_URL"

    SOURCE_DIR=$(tar -tf "$ARCHIVE_NAME" | head -1 | cut -d/ -f1)

    log "Extracting SafeCLib..."
    tar -xzf "$ARCHIVE_NAME"

    log "Preparing build directory..."
    mv "$SOURCE_DIR" "$BUILD_DIR"

    cd "$BUILD_DIR/$SOURCE_DIR"

    log "Configuring SafeCLib..."
    ./configure

    log "Running autoreconf..."
    autoreconf -i
    autoreconf -fi

    log "Reconfiguring SafeCLib..."
    ./configure

    log "Compiling SafeCLib using ${CPU_CORES} CPU cores..."
    make -j"$CPU_CORES"

    # Second build required to complete the SafeCLib build process.
    log "Rebuilding SafeCLib..."
    make -j"$CPU_CORES"

    log "Installing SafeCLib..."
    make install

    log "Updating shared library cache..."
    ldconfig

    log "SafeCLib ${SAFELIB_VERSION} installed successfully."
}

install_vectorscan(){
    local ARCHIVE_NAME="vectorscan-${VECTORSCAN_VERSION}.tar.gz"
    local SOURCE_DIR

    log "Installing Vectorscan ${VECTORSCAN_VERSION}..."

    log "Downloading Vectorscan..."
    cd "$DOWNLOADS_DIR"
    wget "$VECTORSCAN_URL" -O "$ARCHIVE_NAME"

    SOURCE_DIR=$(tar -tf "$ARCHIVE_NAME" | head -1 | cut -d/ -f1)

    log "Rebuilding PCRE2 with JIT and Unicode support..."
    rebuild_pcre2_for_vectorscan

    log "Extracting Vectorscan..."
    tar -xzf "$ARCHIVE_NAME"

    log "Preparing build directory..."
    mv "$SOURCE_DIR" "$BUILD_DIR"

    cd "$BUILD_DIR/$SOURCE_DIR"

    log "Patching CMakeLists.txt..."
    # TODO: sed commands

    log "Patching cmake/pcre.cmake..."
    # TODO: sed commands

    log "Creating build directory..."
    mkdir build
    cd build

    log "Configuring Vectorscan..."
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_STATIC_LIBS=ON \
        -DBUILD_TOOLS=OFF \
        -DBUILD_EXAMPLES=OFF

    log "Compiling Vectorscan using ${CPU_CORES} CPU cores..."
    make -j"$CPU_CORES"

    log "Installing Vectorscan..."
    make install

    log "Updating shared library cache..."
    ldconfig

    log "Vectorscan ${VECTORSCAN_VERSION} installed successfully."
}

install_libdaq(){
    local ARCHIVE_NAME="libdaq-${LIBDAQ_VERSION}.tar.gz"
    local SOURCE_DIR

    log "Installing LibDAQ ${LIBDAQ_VERSION}..."

    log "Downloading LibDAQ..."
    cd "$DOWNLOADS_DIR"
    wget "$LIBDAQ_URL" -O "$ARCHIVE_NAME"

    SOURCE_DIR=$(tar -tf "$ARCHIVE_NAME" | head -1 | cut -d/ -f1)

    log "Extracting LibDAQ..."
    tar -xzf "$ARCHIVE_NAME"

    log "Preparing build directory..."
    mv "$SOURCE_DIR" "$BUILD_DIR"

    cd "$BUILD_DIR/$SOURCE_DIR"

    log "Running bootstrap..."
    ./bootstrap

    log "Configuring LibDAQ..."
    ./configure \
        --prefix=/usr/local \
        --enable-afpacket-module \
        --enable-nfq-module

    log "Compiling LibDAQ using ${CPU_CORES} CPU cores..."
    make -j"$CPU_CORES"

    log "Installing LibDAQ..."
    make install

    log "Updating shared library cache..."
    ldconfig

    log "LibDAQ ${LIBDAQ_VERSION} installed successfully."
}

#############################################
# SNORT INSTALLATION
#############################################

install_snort(){
    local ARCHIVE_NAME="snort3-${SNORT_VERSION}.tar.gz"
    local SOURCE_DIR

    log "Installing Snort ${SNORT_VERSION}..."

    log "Downloading Snort..."
    cd "$DOWNLOADS_DIR"
    wget "$SNORT_URL" -O "$ARCHIVE_NAME"

    SOURCE_DIR=$(tar -tf "$ARCHIVE_NAME" | head -1 | cut -d/ -f1)

    log "Extracting Snort..."
    tar -xzf "$ARCHIVE_NAME"

    log "Preparing build directory..."
    mv "$SOURCE_DIR" "$BUILD_DIR"

    cd "$BUILD_DIR/$SOURCE_DIR"

    log "Configuring Snort..."
    ./configure_cmake.sh \
        --prefix=/usr/local \
        --enable-tcmalloc

    cd build

    log "Compiling Snort using ${CPU_CORES} CPU cores..."
    make -j"$CPU_CORES"

    log "Installing Snort..."
    make install

    log "Updating shared library cache..."
    ldconfig

    log "Verifying Snort installation..."
    /usr/local/bin/snort -V

    log "Snort ${SNORT_VERSION} installed successfully."
}


#############################################
# COMPLETE INSTALLATION
#############################################

install_all(){
    install_system_packages
    create_workdir

    install_pcre2
    install_boost
    install_gperftools
    install_flatbuffers
    install_ragel
    install_safeclib
    install_vectorscan
    install_libdaq

    install_snort
}

cleanup(){
    log "Removing working directory..."

    rm -rf "$WORKDIR"

    log "Working directory removed."
}


#############################################
# MENU
#############################################

show_menu(){
    clear

    echo "=================================================="
    echo "              SNORT 3 INSTALLER"
    echo "=================================================="
    echo
    echo "General"
    echo "-------"
    echo " 1) Install system packages"
    echo " 2) Create working directory"
    echo
    echo "Dependencies"
    echo "------------"
    echo " 3) Install PCRE2"
    echo " 4) Install Boost"
    echo " 5) Install gperftools"
    echo " 6) Install FlatBuffers"
    echo " 7) Install Ragel"
    echo " 8) Install SafeCLib"
    echo " 9) Install Vectorscan"
    echo "10) Install LibDAQ"
    echo
    echo "Snort"
    echo "-----"
    echo "11) Install Snort"
    echo
    echo "Utilities"
    echo "---------"
    echo "20) Install everything"
    echo "21) Remove working directory"
    echo
    echo " 0) Exit"
    echo
}

debug_menu()
{
    while true
    do
        show_menu

        read -rp "Select an option: " OPTION

        echo
        log "Executing selected option..."
        echo

        case "$OPTION" in

            1) install_system_packages ;;

            2) create_workdir ;;

            3) install_pcre2 ;;

            4) install_boost ;;

            5) install_gperftools ;;

            6) install_flatbuffers ;;

            7) install_ragel ;;

            8) install_safeclib ;;

            9) install_vectorscan ;;

            10) install_libdaq ;;

            11) install_snort ;;

            20) install_all ;;

            21) cleanup ;;

            0)
                log "Exiting..."
                exit 0
                ;;

            *)
                error "Invalid option."
                ;;
        esac

        echo
        read -rp "Press ENTER to continue..."
    done
}

#############################################
# MAIN
#############################################

main(){
    check_root
    debug_menu
}

main