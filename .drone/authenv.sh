#!/bin/sh

# Set up the environment for signing and publishing sbt projects.
# WARNING: this script has global side effects, it is intended to be
# run in an isolated, throw-away environment!

set -e

# import public key from key servers
echo "Getting public key"
gpg2 --batch --keyserver hkp://pool.sks-keyservers.net --recv-keys 4E7DA7B5A0F86992D6EB3F514601878662E33372

# import secret signing sub key, the key is expected to be passwordless
echo "Importing SSB"
echo "$GPG_SSB" | gpg2 --batch --import

# prepare gpg settings for sbt
echo "Setting up sbt-pgp"
cat << EOF > gpg.sbt
import com.typesafe.sbt.pgp.PgpKeys._
pgpSigningKey in Global := Some(0x2CED17AB2B6D6F37l)
pgpPassphrase in Global := None
useGpg in Global := true
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
