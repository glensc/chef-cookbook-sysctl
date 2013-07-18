#!/bin/sh

# Apply sysctl settings, including files in /etc/sysctl.d
if [ -x /lib/systemd/systemd-sysctl ]; then
	/lib/systemd/systemd-sysctl
	return
fi

for file in /usr/lib/sysctl.d/*.conf; do
	[ -f /run/sysctl.d/${file##*/} ] && continue
	[ -f /etc/sysctl.d/${file##*/} ] && continue
	test -f "$file" && sysctl -e -p "$file"
done
for file in /run/sysctl.d/*.conf; do
	[ -f /etc/sysctl.d/${file##*/} ] && continue
	test -f "$file" && sysctl -e -p "$file"
done
for file in /etc/sysctl.d/*.conf; do
	test -f "$file" && sysctl -e -p "$file"
done
sysctl -e -p /etc/sysctl.conf
