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
                DependsOn = '[WindowsFeature]DNS'
            }

            foreach ($ARecord in $Zone.ARecords)
            {
                xDnsRecord $ARecord.Key
                {
                    Ensure    = 'Present'
                    Name      = $ARecord.Key
                    Zone      = $Zone.PrimaryZone
                    Type      = 'ARecord'
                    Target    = $ARecord.Value
                    DependsOn = '[WindowsFeature]DNS'
                }        
            }

            foreach ($CNameRecord in $Zone.CNameRecords)
            {
                xDnsRecord $CNameRecord.Key
                {
                    Ensure    = 'Present'
                    Name      = $CNameRecord.Key
                    Zone      = $Zone.PrimaryZone
                    Type      = 'CName'
                    Target    = $CNameRecord.Value
                    DependsOn = '[WindowsFeature]DNS'
                }        
            }
        }
    }
}
