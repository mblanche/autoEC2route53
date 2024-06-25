# Automate Route53 DNS upon EC2 start

This script automatically update Route53 record with the instance IP. You need to create 2 tags

```
domain_name your-domain-name.com
host_name the_host
```

The DNS record will be update so that `the_host.your-domain-name.com` point to the public IP of the instance.

To execute the script everytime the instance boot, place a copy or a symlink into `/var/lib/cloud/scripts/per-boot/`.
