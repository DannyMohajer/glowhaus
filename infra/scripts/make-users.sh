#!/usr/bin/env bash
# Creates a password for every identity in mosquitto/acl.conf.
#
#   infra/scripts/make-users.sh                      passwords for every user in acl.conf
#   infra/scripts/make-users.sh <homeId> <deviceId>...   first append an ACL block for
#                                                    that home (app user + one user per
#                                                    device), then the passwords
#
# Writes (both git-ignored):
#   infra/secrets/credentials   username:password per line, for the simulator
#                               (--credentials) and for you (the app login)
#   infra/secrets/passwd        the hashed form Mosquitto reads
#
# Existing passwords are kept; only new users get one. Needs mosquitto_passwd
# (brew install mosquitto) or, failing that, Docker.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
acl="$here/mosquitto/acl.conf"
secrets="$here/secrets"
credentials="$secrets/credentials"
passwd="$secrets/passwd"
mkdir -p "$secrets"
touch "$credentials"

if [ $# -gt 0 ]; then
  home="$1"; shift
  if [ $# -eq 0 ]; then
    echo "usage: $0 [<homeId> <deviceId>...]" >&2; exit 2
  fi
  if grep -q "^user $home\.app\$" "$acl"; then
    echo "acl.conf already has a block for home '$home'; not adding another." >&2
  else
    {
      echo
      echo "# ---- home: $home ----"
      echo
      echo "user $home.app"
      echo "topic readwrite glowhaus/$home/#"
      for device in "$@"; do
        echo
        echo "user $home.$device"
        echo "topic write glowhaus/$home/$device/state"
        echo "topic write glowhaus/$home/$device/ack"
        echo "topic write glowhaus/$home/$device/availability"
        echo "topic read glowhaus/$home/$device/set"
        echo "topic readwrite glowhaus/$home/discovery"
      done
    } >> "$acl"
    echo "Added home '$home' with $# device(s) to mosquitto/acl.conf."
  fi
fi

random_password() {
  LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24
}

added=0
while read -r user; do
  if ! grep -q "^$user:" "$credentials"; then
    echo "$user:$(random_password)" >> "$credentials"
    added=$((added + 1))
  fi
done < <(sed -n 's/^user \(.*\)$/\1/p' "$acl")

# Hash the whole file again; mosquitto_passwd -U converts plain "user:password"
# lines in place.
cp "$credentials" "$passwd"
if command -v mosquitto_passwd > /dev/null; then
  mosquitto_passwd -U "$passwd"
elif command -v docker > /dev/null; then
  docker run --rm -v "$secrets:/work" eclipse-mosquitto:2 \
    mosquitto_passwd -U /work/passwd
else
  rm -f "$passwd"
  echo "Need mosquitto_passwd (brew install mosquitto) or Docker to hash passwords." >&2
  exit 1
fi
chmod 600 "$credentials"
chmod 644 "$passwd"

echo "$added new password(s). Logins are in infra/secrets/credentials; the app user is:"
grep '\.app:' "$credentials" | cut -d: -f1 | sed 's/^/  /'
