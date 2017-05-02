Debian NAT/IP masq automation tool
===

## Temporary
### Prequisites
- iptables

#### Install the prequisites
`$ sudo apt install iptables iptables-persistent`

### Enable
`$ sudo ./temporary/temp_enable.sh`

### Disable
`$ sudo ./temporary/temp_disable.sh`

## Permanent
### Prequisites
- iptables
- iptables-persistent

#### Install the prequisites
`$ sudo apt install iptables iptables-persistent`

### Enable
`$ sudo ./permanent/perm_enable.sh`

### Disable
`$ sudo ./permanent/perm_disable.sh`
