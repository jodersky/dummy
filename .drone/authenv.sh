#!/bin/sh

# Set up the environment for signing and publishing sbt projects.
# WARNING: this script has global side effects, it is intended to be
# run in an isolated, throw-away environment!

set -e

echo "the newline is:"
echo "$NEWLINE"

# import public key from key servers
#echo "Getting public key"
#gpg2 --batch --keyserver hkp://pool.sks-keyservers.net --recv-keys 4E7DA7B5A0F86992D6EB3F514601878662E33372

# import secret signing sub key
#
# although the key is encrypted as a drone secret, it must also be encrypted
# with a passphrase since gpg2 does not allow exporting keys with empty passwords
# https://bugs.gnupg.org/gnupg/issue2070
echo "Extracting and importing signing key"
echo "$GPG_SSB_ENC" | base64 -w 0 -d | gpg --batch --import

# prepare gpg settings for sbt
echo "Setting up sbt-pgp"
cat << EOF > gpg.sbt
import com.typesafe.sbt.pgp.PgpKeys._
gpgCommand := "/usr/bin/gpg"
useGpg in Global := true
pgpSigningKey in Global := Some(0x2CED17AB2B6D6F37l)
pgpPassphrase in Global := Some("0000000000".toCharArray)
EOF

# prepare bintray settings
echo "Setting up sbt-bintray"
mkdir -p "$HOME"/.bintray
cat << EOF > "$HOME"/.bintray/.credentials
realm = Bintray API Realm
host = api.bintray.com
user = jodersky
password = "$BINTRAY_KEY"
EOF
