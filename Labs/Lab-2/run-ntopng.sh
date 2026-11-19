#!/usr/bin/env bash
# Run a Lab 2 pcap in ntopng without loading the Pro-only app_utils module
# in Community mode. The patch applies only inside this disposable container.
set -euo pipefail

if [[ $# -ne 1 || ! -f $1 ]]; then
  printf 'Usage: %s /path/to/net1.pcap\n' "$0" >&2
  exit 2
fi

pcap_path=$(realpath -- "$1")
pcap_dir=$(dirname -- "$pcap_path")
pcap_name=$(basename -- "$pcap_path")

case "$(uname -m)" in
  x86_64) image=ntop/ntopng.dev:latest ;;
  aarch64|arm64) image=ntop/ntopng_arm64.dev:latest ;;
  *) printf 'Unsupported Kali VM architecture: %s\n' "$(uname -m)" >&2; exit 2 ;;
esac

printf 'Opening %s with %s\n' "$pcap_path" "$image"
sudo docker run --rm -it -p 127.0.0.1:3000:3000 \
  -v "$pcap_dir":/pcaps:ro \
  --entrypoint /bin/bash \
  "$image" -lc '
    set -e
    module=/usr/share/ntopng/scripts/lua/modules/check_redis_prefs.lua
    if grep -Fq "if ntop.hasnAnalyst and ntop.hasnAnalyst() then" "$module"; then
      sed -i "s/if ntop.hasnAnalyst and ntop.hasnAnalyst() then/if ntop.isPro and ntop.isPro() and ntop.hasnAnalyst and ntop.hasnAnalyst() then/" "$module"
    fi
    exec /run.sh -i "/pcaps/$1" --disable-login 1
  ' ntopng-lab "$pcap_name"
