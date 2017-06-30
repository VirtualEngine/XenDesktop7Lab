configuration XD7LabSite {
    param (
        ## Citrix XenDesktop installation source root
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $XenDesktopMediaPath,

        ## Citrix XenDesktop site name
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $SiteName,

        ## Microsoft SQL Server FQDN
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        ## Citrix license server FQDN
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $LicenseServer,

        ## List of all FQDNs and NetBIOS of XenDesktop site controller names for credential delegation
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $DelegatedComputers,

        ## List of Active Directory site administrators
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $SiteAdministrators,

        ## Citrix XenDesktop Site database name
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $SiteDatabaseName = "$($SiteName)Site",

        ## Citrix XenDesktop Logging database name
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $LoggingDatabaseName = "$($SiteName)Logging",

        ## Citrix XenDesktop Monitor database name
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $MonitorDatabaseName = "$($SiteName)Monitor",

        ## Citrix XenDesktop licensed edition
        [Parameter()]
        [ValidateSet('PLT','ENT','APP')]
        [System.String] $LicenseEdition = 'PLT',

        ## Citrix XenDesktop licensing model
        [Parameter()]
        [ValidateSet('UserDevice','Concurrent')]
        [System.String] $LicenseModel = 'UserDevice',

        ## The XML Broker Service trust settings
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $TrustRequestsSentToXmlServicePort,

        ## Active Directory domain account used to install/configure the Citrix XenDesktop site
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

    Import-DscResource -ModuleName xCredSSP, XenDesktop7;

    xCredSSP 'CredSSPServer' {
        Role = 'Server';
    }

    xCredSSP 'CredSSPClient' {
        Role = 'Client';
        DelegateComputers = $DelegatedComputers;
    }

    XD7Feature 'XD7Controller' {
        Role = 'Controller';
        SourcePath = $XenDesktopMediaPath;
    }

    XD7Feature 'XD7Studio' {
        Role = 'Studio';
        SourcePath = $XenDesktopMediaPath;
    }

    if ($PSBoundParameters.ContainsKey('Credential')) {

        XD7Database 'XD7SiteDatabase' {
            SiteName = $SiteName;
            DatabaseServer = $DatabaseServer;
            DatabaseName = $SiteDatabaseName;
            Credential = $Credential;
            DataStore = 'Site';
            DependsOn = '[XD7Feature]XD7Controller';
        }

        XD7Database 'XD7SiteLoggingDatabase' {
            SiteName = $SiteName;
            DatabaseServer = $DatabaseServer;
            DatabaseName = $LoggingDatabaseName;
            Credential = $Credential;
            DataStore = 'Logging';
            DependsOn = '[XD7Feature]XD7Controller';
        }

        XD7Database 'XD7SiteMonitorDatabase' {
            SiteName = $SiteName;
            DatabaseServer = $DatabaseServer;
            DatabaseName = $MonitorDatabaseName;
            Credential = $Credential;
            DataStore = 'Monitor';
            DependsOn = '[XD7Feature]XD7Controller';
        }

        XD7Site 'XD7Site' {
            SiteName = $SiteName;
            DatabaseServer = $DatabaseServer;
            SiteDatabaseName = $SiteDatabaseName;
            LoggingDatabaseName = $LoggingDatabaseName;
            MonitorDatabaseName = $MonitorDatabaseName;
            Credential = $Credential;
            DependsOn = '[XD7Feature]XD7Controller','[XD7Database]XD7SiteDatabase','[XD7Database]XD7SiteLoggingDatabase','[XD7Database]XD7SiteMonitorDatabase';
        }

        XD7SiteLicense 'XD7SiteLicense' {
            LicenseServer = $LicenseServer;
            Credential = $Credential;
            LicenseEdition = $LicenseEdition;
            LicenseModel = $LicenseModel;
            DependsOn = '[XD7Site]XD7Site';
        }

        if ($PSBoundParameters.ContainsKey('SiteAdministrators')) {

            foreach ($administrator in $SiteAdministrators) {

                XD7Administrator $administrator.Replace(' ','') {
                    Name = $administrator;
                    Credential = $Credential;
                }
            }

            XD7Role 'FullAdministrators' {
                Name = 'Full Administrator';
                Members =  $SiteAdministrators;
                Credential = $Credential;
            }
        
        }

        if ($PSBoundParameters.ContainsKey('TrustRequestsSentToXmlServicePort')) {

            XD7SiteConfig 'TrustRequestsSentToXmlServicePort' {
                IsSingleInstance = 'Yes';
                TrustRequestsSentToTheXmlServicePort = $TrustRequestsSentToXmlServicePort;
                Credential = $Credential;
                DependsOn = '[XD7Site]XD7Site';
            }
        } #end if TrustRequestsSentToXmlServicePort

    }
    else {

        XD7Database 'XD7SiteDatabase' {
            SiteName = $SiteName;
            DatabaseServer = $DatabaseServer;
            DatabaseName = $SiteDatabaseName;
            DataStore = 'Site';
            DependsOn = '[XD7Feature]XD7Controller';
        }

        XD7Database 'XD7SiteLoggingDatabase' {
            SiteName = $SiteName;
            DatabaseServer = $DatabaseServer;
            DatabaseName = $LoggingDatabaseName;
            DataStore = 'Logging';
            DependsOn = '[XD7Feature]XD7Controller';
        }

        XD7Database 'XD7SiteMonitorDatabase' {
            SiteName = $SiteName;
            DatabaseServer = $DatabaseServer;
            DatabaseName = $MonitorDatabaseName;
            DataStore = 'Monitor';
            DependsOn = '[XD7Feature]XD7Controller';
        }

        XD7Site 'XD7Site' {
            SiteName = $SiteName;
            DatabaseServer = $DatabaseServer;
            SiteDatabaseName = $SiteDatabaseName;
            LoggingDatabaseName = $LoggingDatabaseName;
            MonitorDatabaseName = $MonitorDatabaseName;
            DependsOn = '[XD7Feature]XD7Controller','[XD7Database]XD7SiteDatabase','[XD7Database]XD7SiteLoggingDatabase','[XD7Database]XD7SiteMonitorDatabase';
        }

        XD7SiteLicense 'XD7SiteLicense' {
            LicenseServer = $LicenseServer;
            LicenseEdition = $LicenseEdition;
            LicenseModel = $LicenseModel;
            DependsOn = '[XD7Site]XD7Site';
        }

        if ($PSBoundParameters.ContainsKey('SiteAdministrators')) {
            
            foreach ($administrator in $SiteAdministrators) {

                XD7Administrator $administrator.Replace(' ','') {
                    Name = $administrator;
                }
            }

            XD7Role 'FullAdministrators' {
                Name = 'Full Administrator';
                Members =  $SiteAdministrators;
            }

        }

        if ($PSBoundParameters.ContainsKey('TrustRequestsSentToXmlServicePort')) {

            XD7SiteConfig 'TrustRequestsSentToXmlServicePort' {
                IsSingleInstance = 'Yes';
                TrustRequestsSentToTheXmlServicePort = $TrustRequestsSentToXmlServicePort;
                DependsOn = '[XD7Site]XD7Site';
            }
        } #end if TrustRequestsSentToXmlServicePort
    }

} #end configuration XD7LabSite
