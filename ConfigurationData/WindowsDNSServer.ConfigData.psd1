@{
    AllNodes = 
    @(
        @{
            NodeName            = 'localhost'
            Role                = 'DNSServer'
            ZoneData            = 
            @{
                PrimaryZone     = 'Contoso.com'
                ARecords        = 
                @{
                    'ARecord1'  = '10.0.0.25'
                    'ARecord2'  = '10.0.0.26'
                    'ARecord3'  = '10.0.0.27'
                }
                CNameRecords    = 
                @{
                    'www'       = 'ARecord1'
                    'wwwtest'   = 'ARecord2'
                    'wwwqa'     = 'ARecord3'
                }
            },
            @{
                PrimaryZone     = 'Fabrikam.com'
                ARecords        = 
                @{
                    'ARecord1'  = '10.0.0.35'
                    'ARecord2'  = '10.0.0.36'
                    'ARecord3'  = '10.0.0.37'
                }
                CNameRecords    = 
                @{
                    'www'       = 'ARecord1'
                    'wwwtest'   = 'ARecord2'
                    'wwwqa'     = 'ARecord3'
                }
            }
        }
    )
}
