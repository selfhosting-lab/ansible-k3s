# ansible-k3s

[![Drone build status](https://img.shields.io/drone/build/selfhosting-lab/ansible-k3s/master?label=BUILD&logo=drone&style=for-the-badge)](https://cloud.drone.io/selfhosting-lab/ansible-k3s/)

## Description

Provide a customised [k3s](https://k3s.io/) installation, via Ansible.

This is used as a base image for selfhosting-labs.

## Dependencies

- [Fedora 30](https://getfedora.org/) x86_64 target machine.
- [Ansible](https://ansible.com).
- [Ruby](https://ruby-lang.org) >= `2.6` if you wish to run the test suite.
- [Bundler](https://bundler.io)

---

## Features

- [Create administrator user accounts.](#admins)
- [Security updates are automatically applied.](#security-updates)
- [DNS configuration.](#dns-configuration)
- [Create swap file.](#swapfile)
- [NTP configuration.](#ntp-configuration)
- [Tuning.](#tuning)
- [Install a bunch of useful utility tools.](#additional-utilities)
- [Additional custom tools](#custom-tools)

---

## Admins

A user group `admin` is created which is granted sudo access via `/etc/sudoers.d/admin`.

To create administrator users you can simply add them to the `admins` variable like this:

```yaml
admins:
  - name: <USER NAME>
    key: 'ssh-rsa <SSH PUBLIC KEY>'
```

> By default, the users are granted passwordless sudo access. You can change this by setting
> `admin_passwordless_sudo: false`.

## Security updates

Automatic security updates are provided by [dnf-automatic](https://dnf.readthedocs.io/en/latest/automatic.html). You can
review the status of the updates by running `systemctl status dnf-automatic.timer`.

The job will first run 1 hour after booting, and then every 24 hours after that.

## DNS configuration

By default, DNS is configured automatically by Network Manager based on DHCP
settings.

This role offers optional configuration of DNS to instead use
[Cloudflare](https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/) and
[Google](https://developers.google.com/speed/public-dns/) providers.

These providers offer fast, highly available, secure public DNS resolution but you can configure a different set if you
have privacy concerns or want to use your own nameservers.

You can also set a search domain, which allows you to resolve non-FQDN hostnames in DNS. This defaults to simply using
the host's currently configured domain.

```yaml
nameservers:
  - 1.1.1.1
  - 8.8.8.8
  - 8.8.4.4

search_domains:
  - selfhosting-lab.com
```

To enable this feature simply set `enable_custom_dns: True`.

## Swapfile

A swapfile is created at `/var/cache/swap` to provide additional swap resource. Although hosts should be configured
appropriately for their workload, it can be good to have a temporary resource that memory can be swapped to.

By default this is sized the same as your memory by looking up the `ansible_memory_mb.real.total` variable. You can set
the size to something else by setting `swapfile_size` to an amount in MiB.

Using swap is enabled by default but can be turned off by setting `enable_swap: False`.

You can also adjust the swappiness of the system by setting `swappiness` to a value between 0 and 100. The default
swappiness is `10` which provides good performance, only using swap when necessary.

## NTP configuration

NTP is provided using the [chronyd](https://chrony.tuxfamily.org/) daemon and should be something you should never have
to manage. By default it synchronises time from the public `pool.ntp.org` pool, which should automatically find the best
time server for the host. If for some reason you want to set this manually you can set `ntp_pool: pool.ntp.org`.

You can also optionally set your prefered timezone using the appropriate
[tz database name](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for your preferred timezone by setting
`timezone: Europe/London` or similar. You may not want to do this if you'd prefer your host to use it's local timezone
that was configured at installation time.

## Tuning

A few opinionated system tweaks are applied to optimise performance. These are applied using the [[Tuned](Tuned project
https://tuned-project.org) profile `atomic-guest`.

If, for your specific hardware configuration, you'd like to use an alternative profile you can set `tuned_profile`.

## Additional utilities

A few additional utilities are installed for your convience, primarily for troubleshooting and system visibility.

List of tools installed:

- [Bash Completion](https://github.com/scop/bash-completion) - Programmable completion for the Bash shell.
- [Bind Utils](https://apps.fedoraproject.org/packages/bind-utils/overview/) - Collection of utilities for querying DNS.
- [cURL](https://curl.haxx.se/) - Command-line tool for transferring data with URLs.
- [Git](https://git-scm.com/) - *The* distributed revision control system.
- [Glances](https://github.com/nicolargo/glances) - CLI monitoring tool which also supports running as a webpage.
- [htop](http://hisham.hm/htop/) - Better version of `top`.
- [htpasswd](https://httpd.apache.org/docs/2.4/programs/htpasswd.html) - Tool to create and update usernames and password for basic authentication.
- [iotop](http://guichaz.free.fr/iotop/) - `top`-like utility for disk I/O.
- [Iperf](http://github.com/esnet/iperf) - Measurement tool for TCP/UDP bandwith performance.
- [kexec](https://en.wikipedia.org/wiki/Kexec) - Utility to quickly load new kernels.
- [lsof](https://people.freebsd.org/~abe/) - Utility to list open files.
- [Ncat](https://nmap.org/ncat/) - Bidirectional data relay for TCP connections.
- [NFS Utils](https://apps.fedoraproject.org/packages/nfs-utils/overview/) - NFS utilities and supporting clients and daemons.
- [Perf](https://perf.wiki.kernel.org/index.php/Main_Page) - Tool for performance monitoring of the Linux kernel.
- [PV (Pipe Viewer)](http://www.ivarch.com/programs/pv.shtml) - Nifty tool for monitoring the progress of data through a pipe.
- [realmd](https://cgit.freedesktop.org/realmd/realmd/) - Used to interact with and join LDAP realms.
- [Screen](http://www.gnu.org/software/screen) - Screen manager that supports multiple logins on one terminal.
- [Socat](https://apps.fedoraproject.org/packages/socat/overview/) - Bidirectional data relay for Unix sockets.
- [Stress-ng](https://kernel.ubuntu.com/~cking/stress-ng/) - Stress testing tool
- [Tcpdump](http://www.tcpdump.org) - Network traffic monitoring tool and packet analyser.
- [Vim](http://vim.org/) - Powerful text editor.
- [Wget](http://www.gnu.org/software/wget/) - Tool for retreiving files using HTTP or FTP.

## Custom tools

For quality of life, a few custom tools have been added which are installed by default.

### shl-reboot

`shl-reboot` allows you to quickly reboot a system when a new kernel is available, minimising the amount of downtime on
the system. It works using `kexec` to swap the kernel out while the system is still running, meaning POST and BIOS
stages of the boot process are skipped. On enterprise-grade hardware this can sometimes save minutes due to extensive
POST checks.

If there is no new kernel, the tool will simply exit with a `1` exit status. If a new kernel is installed but not
currently active the tool will inform you.

You can then reboot the system by running `shl-reboot apply`. After sleeping for 3 seconds, the system will reboot.

### shl-reload

`shl-reload` allows you to restart currently running services which have updates available, minimising the frequency of
reboots required to pick up software updates. It looks at which SystemD units are associated with updated software, and
restarts those units, including SystemD itself. In theory this reduces the frequency at which you need to reboot your
system down to only kernel updates, meaning security updates can be applied more frequently.

You can choose to run the tasks required to reload the system by running `shl-reload apply`.

Restarting services can be disruptive, for example restarting active user sessions will kick out currently logged in
users, but the impact is minimised to only those services which need updating. It should be treated as a situational
alternative to reboots as it cannot guarantee that there will be no impact to services which you rely on, and therefore
cannot provide a zero-downtime update process.
