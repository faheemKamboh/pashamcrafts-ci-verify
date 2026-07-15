#!/usr/bin/env bash
set -euo pipefail

output_dir="${1:?output directory is required}"
shift

work_dir="$(mktemp -d)"
cleanup() {
  rm -rf "${work_dir}"
}
trap cleanup EXIT

diagnostics="${work_dir}/diagnostics"
mkdir -p "${diagnostics}" "${output_dir}"

copied=0
for file in "$@"; do
  if [ -f "${file}" ]; then
    cp "${file}" "${diagnostics}/$(basename "${file}")"
    copied=$((copied + 1))
  fi
done

if [ "${copied}" -eq 0 ]; then
  printf '%s\n' "No detailed diagnostic file was produced." > "${diagnostics}/diagnostic.txt"
fi

tar -czf "${work_dir}/diagnostics.tar.gz" -C "${diagnostics}" .

cat > "${work_dir}/diagnostic-public.pem" <<'PUBLIC_KEY'
-----BEGIN PUBLIC KEY-----
MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAwfVQ2NArdyLkmwvig819
dELExyse9d1ns3VmTTaA7+T35WTwyo+WcWTtq+eZPB5C1/2dHlbfynOwfITqnIHh
bVPBU0SqFpYzs6nVBTJC+DJtYQT2xsAlN0SalZHakN+7sfOyXO++a6OYBK06F5HJ
1aW3UMX7uJC9kTOHCbqSUVSu/Wr5GU/DDFHnUXRGcdJMHz0LxhSffQ3tXefDWHhx
uGhUopJsKkkP7B68QVGf8LtD5dMwDqpITOz04m381BA082+9QpL+K1pTbO+b4O91
OEtKccQG0+sN6nbyXE7ak+mGdLLpNotPMT0nusEJibIlS91cEe3iMnxyxdgOjWA4
f9kFl7ONXYFLKQZ6sSEfm3YEJjJA4BSoLE7dUCq/AQ8u+hOfBMks6gNvc9ZmRb8s
b4o5/ffRxPjOD00xEVmLGBYtv7vKwwJFexruGG8oH8+Qbsh+l9Q0dAhyco3Rha/4
L6naMFuj1Aux7IUObQKuNTqLm0SlvI4Oa2xjaQAw8DqRAgMBAAE=
-----END PUBLIC KEY-----
PUBLIC_KEY

openssl rand -hex 32 > "${work_dir}/diagnostic-passphrase"
openssl enc -aes-256-cbc -salt -pbkdf2 \
  -in "${work_dir}/diagnostics.tar.gz" \
  -out "${output_dir}/payload.enc" \
  -pass file:"${work_dir}/diagnostic-passphrase"
openssl pkeyutl -encrypt -pubin \
  -inkey "${work_dir}/diagnostic-public.pem" \
  -in "${work_dir}/diagnostic-passphrase" \
  -out "${output_dir}/passphrase.enc" \
  -pkeyopt rsa_padding_mode:oaep \
  -pkeyopt rsa_oaep_md:sha256
