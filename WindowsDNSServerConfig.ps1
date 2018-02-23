
<#PSScriptInfo

.VERSION 0.1.0

.GUID 2d1436b4-b53a-42ea-80d6-8495742fdede

.AUTHOR Michael Greene

.COMPANYNAME Microsoft Corporation

.COPYRIGHT 

.TAGS DSCConfiguration

.LICENSEURI https://github.com/Microsoft/WindowsDNSServerConfig/blob/master/LICENSE

.PROJECTURI https://github.com/Microsoft/WindowsDNSServerConfig

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
https://github.com/Microsoft/WindowsDNSServerConfig/blob/master/README.md##releasenotes

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module @{moduleversion = '1.9.0.0'; modulename = 'xDNSServer'}

<# 

.DESCRIPTION 
 This module contains PowerShell Desired State Configuration solutions for deploying and configuring DNS Servers 

#> 

configuration WindowsDNSServerConfig
{
    <#
        .DESCRIPTION
        Basic configuration for Windows DNS Server with zones and records

        .EXAMPLE
        WindowsDNSServer -outpath c:\dsc\

        .NOTES
        This configuration requires the corresponding configdata file
    #>

    Import-DscResource -module 'xDnsServer','PSDesiredStateConfiguration'
    
    $ZoneData = 
        @{
            PrimaryZone     = 'Contoso.com';
            ARecords        = 
            @{
                'ARecord1'  = '10.0.0.25';
                'ARecord2'  = '10.0.0.26';
                'ARecord3'  = '10.0.0.27'
            };
            CNameRecords    = 
            @{
                'www'       = 'ARecord1';
                'wwwtest'   = 'ARecord2';
                'wwwqa'     = 'ARecord3'
            }
        },
        @{
            PrimaryZone     = 'Fabrikam.com';
            ARecords        = 
            @{
                'ARecord1'  = '10.0.0.35';
                'ARecord2'  = '10.0.0.36';
                'ARecord3'  = '10.0.0.37'
            };
            CNameRecords    = 
            @{
                'www'       = 'ARecord1';
                'wwwtest'   = 'ARecord2';
                'wwwqa'     = 'ARecord3'
            }
        }

    WindowsOptionalFeature DNS
    {
        Ensure  = 'Enable'
        Name    = 'DNS-Server-Full-Role'
    }
    
    foreach ($Zone in $ZoneData)
    {
        xDnsServerPrimaryZone $Zone.PrimaryZone
        {
            Ensure    = 'Present'                
            Name      = $Zone.PrimaryZone
            DependsOn = '[WindowsOptionalFeature]DNS'
        }

        foreach ($ARecord in $Zone.ARecords.Keys)
        {
            xDnsRecord "$($Zone.PrimaryZone)_$ARecord"
            {
                Ensure    = 'Present'
                Name      = $ARecord
                Zone      = $Zone.PrimaryZone
                Type      = 'ARecord'
                Target    = $Zone.ARecords[$ARecord]
                DependsOn = "[WindowsOptionalFeature]DNS","[xDnsServerPrimaryZone]$($Zone.PrimaryZone)"
            }        
        }

        foreach ($CNameRecord in $Zone.CNameRecords.Keys)
        {
            xDnsRecord "$($Zone.PrimaryZone)_$CNameRecord"
            {
                Ensure    = 'Present'
                Name      = $CNameRecord
                Zone      = $Zone.PrimaryZone
                Type      = 'CName'
                Target    = $Zone.CNameRecords[$CNameRecord]
                DependsOn = "[WindowsOptionalFeature]DNS","[xDnsServerPrimaryZone]$($Zone.PrimaryZone)"
            }        
        }
    }
}
