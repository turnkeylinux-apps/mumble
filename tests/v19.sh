#!/bin/bash
set -Eeuo pipefail
umask 077

result=${TKL_TEST_RESULT:?TKL_TEST_RESULT is required}
password=${TKL_TEST_APP_PASS:?TKL_TEST_APP_PASS is required}
response=/tmp/tkl-mumble-response.$$
protocol_result=/tmp/tkl-mumble-protocol.$$
policy=/tmp/tkl-mumble-policy.$$

cleanup() {
    rm -f -- "$response" "$protocol_result" "$policy"
}
trap cleanup EXIT

systemctl --quiet is-active mumble-server.service apache2.service \
    multi-user.target
systemctl --quiet is-enabled mumble-server.service

mumble_version=$(dpkg-query -W -f='${Version}' mumble-server)
apache_version=$(dpkg-query -W -f='${Version}' apache2)
php_ice_version=$(dpkg-query -W -f='${Version}' php-zeroc-ice)

grep -Fxq 'registerName=TurnKey Mumble Server' \
    /etc/mumble/mumble-server.ini
grep -Fxq 'ice="tcp -h 0.0.0.0 -p 6502"' \
    /etc/mumble/mumble-server.ini
grep -Fxq "icesecretwrite=$password" /etc/mumble/mumble-server.ini
php -m | grep -Fxiq ice
ss -ltn | awk '$4 ~ /:6502$/ { found=1 } END { exit !found }'
ss -lun | awk '$4 ~ /:64738$/ { found=1 } END { exit !found }'

curl --fail --silent --show-error http://127.0.0.1/ >"$response"
grep -q 'TurnKey Mumble Server' "$response"
grep -q ':12321' "$response"
curl --insecure --fail --silent --show-error https://127.0.0.1/ >"$response"
grep -q 'TurnKey Mumble Server' "$response"
dpkg-query -W webmin-apache webmin-phpini >/dev/null

python3 -u - >"$protocol_result" <<'PY'
import hashlib
import os
import socket
import ssl
import struct


def varint(value):
    encoded = bytearray()
    while True:
        byte = value & 0x7f
        value >>= 7
        encoded.append(byte | (0x80 if value else 0))
        if not value:
            return bytes(encoded)


def string_field(number, value):
    raw = value.encode()
    return varint((number << 3) | 2) + varint(len(raw)) + raw


def send_message(connection, kind, payload):
    connection.sendall(struct.pack('>HI', kind, len(payload)) + payload)


def receive_exact(connection, length):
    received = bytearray()
    while len(received) < length:
        chunk = connection.recv(length - len(received))
        if not chunk:
            raise RuntimeError('Mumble closed the connection')
        received.extend(chunk)
    return bytes(received)


raw_connection = socket.create_connection(('127.0.0.1', 64738), timeout=5)
context = ssl.create_default_context()
context.check_hostname = False
context.verify_mode = ssl.CERT_NONE
with context.wrap_socket(raw_connection, server_hostname='localhost') as connection:
    connection.settimeout(5)
    certificate = connection.getpeercert(binary_form=True)
    assert certificate, 'Mumble did not present a TLS certificate'
    assert connection.version() in ('TLSv1.2', 'TLSv1.3')

    version = b'\x08' + varint(0x01050000)
    version += string_field(2, 'turnkey-v19-acceptance')
    authentication = string_field(1, 'SuperUser')
    authentication += string_field(2, os.environ['TKL_TEST_APP_PASS'])
    authentication += b'\x28\x01'
    send_message(connection, 0, version)
    send_message(connection, 2, authentication)

    for _ in range(20):
        kind, length = struct.unpack('>HI', receive_exact(connection, 6))
        payload = receive_exact(connection, length)
        if kind == 4:
            raise RuntimeError(
                'Mumble rejected the SuperUser credential: %s' % payload.hex()
            )
        if kind == 5:
            break
    else:
        raise RuntimeError('Mumble did not complete SuperUser authentication')

    print('tls_version=%s' % connection.version())
    print('certificate_sha256=%s' % hashlib.sha256(certificate).hexdigest())
    print('superuser_authentication=accepted')
PY

tls_version=$(awk -F= '$1 == "tls_version" {print $2}' "$protocol_result")
certificate_sha256=$(awk -F= '$1 == "certificate_sha256" {print $2}' "$protocol_result")
grep -Fxq 'superuser_authentication=accepted' "$protocol_result"
test -n "$tls_version"
test "${#certificate_sha256}" = 64

before="$mumble_version|$apache_version|$php_ice_version"
apt-get update >/dev/null
for package in mumble-server apache2 php-zeroc-ice; do
    apt-cache policy "$package" >"$policy"
    candidate=$(awk '/Candidate:/ {print $2}' "$policy")
    test -n "$candidate"
    test "$candidate" != '(none)'
    grep -Eq 'http://deb\.debian\.org/debian trixie/main' "$policy"
done
after="$(dpkg-query -W -f='${Version}' mumble-server)|$(dpkg-query -W -f='${Version}' apache2)|$(dpkg-query -W -f='${Version}' php-zeroc-ice)"
test "$after" = "$before"
grep -Rqs '^Suites: trixie' /etc/apt/sources.list.d
! grep -Rqi bookworm /etc/apt/sources.list.d

cat >"$result" <<EOF
package_source=Debian 13 Trixie APT repositories for Mumble Server, Apache, PHP and ZeroC Ice; TurnKey APT for Webmin modules
installed_version=mumble-server $mumble_version; apache2 $apache_version; php-zeroc-ice $php_ice_version
runtime_checks=normal init; Mumble TCP TLS $tls_version with certificate $certificate_sha256; SuperUser protocol authentication; UDP voice listener; Ice endpoint and first-boot write secret; HTTP and HTTPS web control panel; Webmin link and modules
updater_command=apt-get update; apt-cache policy mumble-server apache2 php-zeroc-ice
updater_result=signed metadata refreshed; eligible candidates found; installed versions unchanged
updater_channel=Debian Trixie and TurnKey Trixie APT repositories
integrity_evidence=APT accepted signed repository metadata through configured Deb822 sources and keyrings; no Bookworm source remained
EOF
