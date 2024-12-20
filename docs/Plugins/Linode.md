title: Linode

# How To Use the Linode DNS Plugin

This plugin works against the [Linode](https://www.linode.com/?r=4dfd67cf6f1e384ce626f2943620186344bb2ccf) DNS provider. It is assumed that you have already setup an account and created the DNS zone(s) you will be working against.

!!! note
    The link above is an affiliate link which reduces my out of pocket cost to maintain this plugin. I'd be most grateful if you use it when signing up for a new account.

## Setup

This plugin works against v4 of the Linode API which is not compatible with "legacy" pre-paid accounts. In order to use it and generate the appropriate API Token, your account must be a newer style "hourly billed" account which it should automatically be if you created it after late 2014.

Login to your account and go to the [API Tokens](https://cloud.linode.com/profile/tokens) section of your profile. Generate a Personal Access Token and give it Read/Write access to Domains. Record the value to use later. You can't retrieve it if you forget it. You can only delete and re-create.

## Using the Plugin

The token you created is used with the `LIToken` SecureString parameter.

!!! warning
    The `LITokenInsecure` parameter is deprecated and will be removed in the next major module version. If you are using it, please migrate to the Secure parameter set.

Linode also has an unusually long delay between when a record is set and when it propagates to their public name servers. There's a note at the bottom of the DNS Manager web GUI that reads, *"Changes made to a master zone will take effect in our nameservers every quarter hour."* So you need to set `DnsSleep` parameter in `New-PACertificate` to at least 15 minutes. But in testing, 17 minutes (1020 seconds) seemed to be the minimum to reliably satisfy the challenges.

```powershell
$pArgs = @{
    LIToken = (Read-Host -Prompt 'Token' -AsSecureString)
}
New-PACertificate example.com -Plugin Linode -PluginArgs $pArgs -DnsSleep 1020
```
