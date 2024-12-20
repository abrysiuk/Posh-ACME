title: NameCom

# How To Use the NameCom DNS Plugin

This plugin works against the [name.com](https://www.name.com/) domain registrar and DNS provider. It is assumed that you have already setup an account and purchased domain you will be working against. You must also be using name.com's own DNS hosting.

## Setup

First, go to the [Account API Settings](https://www.name.com/account/settings/api) page and create a new API token for your account. Make a note of both the token value and the username associated with the token. If the username is blank immediately following the token creation, try refreshing the page.

!!! warning
    If you have two-step verification enabled on your account, there is an additional step to allow the API token to be used. Go to the [Security Settings](https://www.name.com/account/settings/security) page and scroll to the bottom. There is a section called `Name.com API Access` with a slider that need to be set to the "on" position which is to the right. It should be green when set properly. Without it, the API will generate errors about two-step verification not being supported by the API.

## Using the Plugin

The username is used with the `NameComUsername` parameter and the token is used with the `NameComTokenSecure` SecureString parameter. If you are using name.com's API testing environment, you'll also need to include `NameComUseTestEnv=$true` in your plugin arguments.

!!! warning
    The `NameComeToken` parameter is deprecated and will be removed in the next major module version. If you are using it, please migrate to the Secure parameter set.

```powershell
$pargs = @{
    NameComUsername = 'username'
    NameComTokenSecure = (Read-Host 'Token' -AsSecureString)
}
New-PACertificate example.com -Plugin NameCom -PluginArgs $pargs
```
