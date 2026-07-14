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
MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAodRct9cyPXTEXX+qy79w
n1J7l0ghDzVV/2xAPtBJrqMTA2xN3mBiIPNHQpaIO6/utE8GkF1ULoZ2zUXg1eZT
Wr/QFyIbWcjDoGweoIVy5tQsnIcAODPND3qIc7rzprcmCcFW9RVNw/wHWM6fWTRy
D5vLUbturrdIkK14qPaePx40cmwI/3THb9d6RNVqwOyEng18DbZld4pfnAtdf0qN
j+JhNt5TQjg+kOMgT6Vcn9OwR4AMC/BZPhIuJafBXjAtiOurWZ217CRhNCo4aeed
cqwOND9sa+WH2/AU3TrFLTpSzQR5VX7zn14sdSOkdrjpV1CQ/M0uC+NZb9Pp77fi
n/NCxoZ5aLpefIg+jI35SN5qW8eE2ZV97o8x6CG/rcYDEWaACWFOk9IS3hUdHgOG
9h/PQFWr0uZtEmh1BW4yj5y1NzAaTY0ZLAH94VXfP9o3zCSMdURf/tZKLQ6itpWW
GuPnDTwmU4Pz+udTrUMNx0bjIfU8zRIQgS61MnG5FwhRAgMBAAE=
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
