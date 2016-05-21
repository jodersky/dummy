#!/bin/sh

# Set up the environment for signing and publishing sbt projects.
# WARNING: this script has global side effects, it is intended to be
# run in an isolated, throw-away environment!

set -e

echo "Preparing authenticated environment"
echo "ssb: $GPG_SSB"
if [ -z "$GPG_SSB" ] || [ -z "$BINTRAY_KEY" ]; then
    echo "Secrets not defined!" >&2
    exit 1
fi

# import public key from key servers
#echo "Getting public key"
#gpg2 --batch --keyserver hkp://pool.sks-keyservers.net --recv-keys 4E7DA7B5A0F86992D6EB3F514601878662E33372

# import secret signing sub key
#
# although the key is encrypted as a drone secret, it must also be encrypted
# with a passphrase since gpg2 does not allow exporting keys with empty passwords
# https://bugs.gnupg.org/gnupg/issue2070
echo "$GPG_SSB_ENC" | base64 -w 0 -d | gpg --batch --import
echo "Imported signing key"

# prepare gpg settings for sbt
cat << EOF > "gpg.sbt"
gpgCommand := "/usr/bin/gpg"
useGpg in Global := true
pgpSigningKey in Global := Some(0x2CED17AB2B6D6F37l)
pgpPassphrase in Global := Some("0000000000".toCharArray)
EOF
echo "sbt-pgp ready"

# prepare bintray settings
mkdir -p "$HOME/.bintray"
cat << EOF > "$HOME/.bintray/.credentials"
realm = Bintray API Realm
host = api.bintray.com
user = jodersky
password = "$BINTRAY_KEY"
EOF
echo "sbt-bintray ready"
