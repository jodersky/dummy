#!/bin/bash

# Set up an environment for signing and publishing sbt projects.

# WARNING: this script has global side effects, it is intended to be
# run in an isolated, throw-away environment!

set -e
set -o pipefail

echo "Preparing authenticated environment" >&2

# Verify that this script is running in a CI environment and has
# secrets available
if [ -z "CI" ]; then
    echo "This script should be run in a CI environment. Aborting." >&2
    exit 1
fi
if [ -z "$SECURE" ] || [ "$SECURE" = "\$\$SECURE" ]; then
    echo "Secrets not defined. Aborting." >&2
    exit 1
fi

# Import gpg signing (secret) key.
#
# Although the key is encrypted as a drone secret, it should also be
# encrypted with a passphrase since gpg2 does not allow exporting keys
# with empty passwords https://bugs.gnupg.org/gnupg/issue2070
# The used password is 0000000000
echo "$GPG_KEY_ENC" | base64 -w 0 -d | gpg --batch --import
echo "Imported signing key" >&2

# Prepare gpg settings for sbt
cat << EOF > "gpg.sbt"
pgpSigningKey in Global := Some(0x2CED17AB2B6D6F37l)
pgpPassphrase in Global := Some("0000000000".toCharArray)
EOF
echo "sbt-pgp ready" >&2

# Prepare bintray settings
mkdir -p "$HOME/.bintray"
cat << EOF > "$HOME/.bintray/.credentials"
realm = Bintray API Realm
host = api.bintray.com
user = jodersky
password = "$BINTRAY_KEY"
EOF
echo "sbt-bintray ready"

echo "Environment ready"
