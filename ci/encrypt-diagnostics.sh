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
MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAq0+e4QuKjIqicH4FOmbg
5eLb+RBRGjLsf1hVj3DA2QscIiL3/35H07ZFeXXZ2akEfLYtX/lnLiIHihMxW/8B
xgMgXHETYzcGZ3JaRLLL8prAi1nPaYiajxFkiE2UevDKzE+5pmJ5CpIt+tB5L6Kq
3xay91hYitCdc7OLFQMt1yIzZZnbOAL4Sa3Zo1lVg8DMeQmyjwuN7AZSVkQOvbLa
QysHW4+IBP8E9N4B+3yspqbmh8bYum26wfTaD35LBQSUasmpQ7RMIu6bBeUmk898
2wNCOe0PTK3OyW9T9kGkzkYrE0PNW5rOx2U3IjgMud0g1+I6HxNA8llOn1xI0m6t
oZZOh7PsN1Gq/bfsdF91gZNfrlsglSqbfx8RJJWn8bcqF7jcxnos+h8nuQMrjIa0
WX7ogy9unowrcXS3ILle5bRQssggzsIZLOdnUV7QFMi43cr+ZFg1wo5rQP9vR7zg
tV+Gz9SXCRLZOevXhH4E8jqgTKg9RL1WcA+WG9ckmYU7AgMBAAE=
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
