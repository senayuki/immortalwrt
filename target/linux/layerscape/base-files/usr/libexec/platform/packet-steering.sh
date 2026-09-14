#!/bin/sh

packet_steering="${1:-1}"
flow_cnt="$(uci -q get 'network.@globals[0].steering_flows')"

# Preserve generic steering on other interfaces and Layerscape boards.
if [ "${flow_cnt:-0}" -gt 0 ] 2>/dev/null; then
	/usr/libexec/network/packet-steering.uc -l "$flow_cnt" "$packet_steering"
else
	/usr/libexec/network/packet-steering.uc "$packet_steering"
fi

[ "$(cat /sys/devices/system/cpu/online 2>/dev/null)" = "0-15" ] || exit 0

devices=""
queues=0
for device in /sys/class/net/*; do
	driver="$(readlink "$device/device/driver")"
	[ "${driver##*/}" = "fsl_dpaa2_eth" ] || continue
	set -- "$device"/queues/rx-*
	[ "$#" -eq 8 ] || continue
	devices="$devices $device"
	queues=$((queues + 8))
done
[ -n "$devices" ] || exit 0

case "$flow_cnt" in
	''|*[!0-9]*) flow_cnt=1024 ;;
esac
while [ "${flow_cnt#0}" != "$flow_cnt" ]; do
	flow_cnt="${flow_cnt#0}"
done
flow_cnt="${flow_cnt:-0}"
[ "$packet_steering" = 0 ] && flow_cnt=0

if [ "$packet_steering" != 0 ] && [ -w /proc/sys/net/core/rps_sock_flow_entries ]; then
	echo "$((flow_cnt * queues))" > /proc/sys/net/core/rps_sock_flow_entries
fi

# Eight RX queues cover the 16 CPUs in pairs on every DPAA2 interface.
masks="3 c 30 c0 300 c00 3000 c000"
for device in $devices; do
	queue=0
	for mask in $masks; do
		case "$packet_steering" in
			0) mask=0 ;;
			2) mask=ffff ;;
		esac
		path="$device/queues/rx-$queue"
		[ ! -w "$path/rps_cpus" ] || echo "$mask" > "$path/rps_cpus"
		[ ! -w "$path/rps_flow_cnt" ] || echo "$flow_cnt" > "$path/rps_flow_cnt"
		queue=$((queue + 1))
	done
done
