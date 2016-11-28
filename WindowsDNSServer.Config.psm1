configuration WindowsDNSServer
{
    <#
        .DESCRIPTION
        Basic configuration for Windows DNS Server

        .EXAMPLE
        WindowsDNSServer -outpath c:\dsc\

        .NOTES
        This is the most basic configuration and does not take parameters or configdata
    #>

    Import-DscResource -module 'xDnsServer','xNetworking', 'PSDesiredStateConfiguration'
    
    Node $AllNodes.Where{$_.Role -eq 'DNSServer'}.NodeName
    {
        # WindowsOptionalFeature is compatible with the Nano Server installation option
        WindowsOptionalFeature DNS
        {
            Ensure  = 'Enable'
            Name    = 'DNS-Server-Full-Role'
        }
        
        foreach ($Zone in $Node.ZoneData)
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
}
