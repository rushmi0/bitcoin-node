#!/bin/bash

# Function to download Bitcoin Core binary
download_bitcoin_core() {
    local VERSION="$1"
    local PLATFORM="$2"
    local FILENAME="bitcoin-$VERSION-$PLATFORM.tar.gz"

    echo "Downloading Bitcoin Core $VERSION for $PLATFORM..."
    wget "https://bitcoincore.org/bin/bitcoin-core-$VERSION/$FILENAME"
}

# Function to download cryptographic checksums
download_checksums() {
    local VERSION="$1"

    echo "Downloading SHA256SUMS for Bitcoin Core $VERSION..."
    wget "https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS"
}

# Function to download signatures
download_signatures() {
    local VERSION="$1"

    echo "Downloading SHA256SUMS.asc for Bitcoin Core $VERSION..."
    wget "https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.asc"
}

# Function to check checksums
checksum_check() {
    echo "Performing checksum check..."
    sha256sum --ignore-missing --check SHA256SUMS
}

# Function to import public keys
import_public_keys() {
    echo "Importing public keys..."
    curl -s "https://api.github.com/repositories/355107265/contents/builder-keys" | grep download_url | grep -oE "https://[a-zA-Z0-9./-]+" | while read url; do curl -s "$url" | gpg --import; done
}

# Function to verify signatures
verify_signatures() {
    echo "Verifying signatures..."
    gpg --verify SHA256SUMS.asc
}

# Function to install Bitcoin Core binaries
install_bitcoin_core() {
    local VERSION="$1"
    local PLATFORM="$2"


    echo "Installing Bitcoin Core $VERSION..."
    tar -xvf "bitcoin-$VERSION-$PLATFORM.tar.gz"

     # Install each file individually
    for file in "bitcoin-$VERSION/bin/"*; do
        sudo install -m 0755 -o root -g root "$file" "/usr/local/bin/"
    done

    bitcoind --version
}

# Function to clean up downloaded files
cleanup_files() {
    local VERSION="$1"
    local PLATFORM="$2"

    echo "Cleaning up downloaded files..."
    rm "bitcoin-$VERSION-$PLATFORM.tar.gz"
    rm "SHA256SUMS"
    rm "SHA256SUMS.asc"
}

# Main function
main() {
    local VERSION="26.0"
    local PLATFORM=""

    # Allow user to select Bitcoin Core version
    echo "Available Bitcoin Core versions:"
    echo "> Bitcoin Core 26.0"

    # Determine platform
    if [[ $(uname -m) == "x86_64" ]]; then
        PLATFORM="x86_64-linux-gnu"
    elif [[ $(uname -m) == "arm"* ]]; then
        PLATFORM="aarch64-linux-gnu"
    else
        echo "Unsupported CPU architecture."
        exit 1
    fi

    # Perform actions
    download_bitcoin_core "$VERSION" "$PLATFORM"
    download_checksums "$VERSION"
    download_signatures "$VERSION"
    checksum_check
    import_public_keys
    verify_signatures
    install_bitcoin_core "$VERSION" "$PLATFORM"
    cleanup_files "$VERSION" "$PLATFORM"

    echo "Bitcoin Core setup completed successfully."
}

# Execute main function
main

