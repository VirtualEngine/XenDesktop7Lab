configuration XD7LabSite {
    param (
        ## Citrix XenDesktop installation source root
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $XenDesktopMediaPath,
        ## Active Directory domain account used to install/configure the Citrix XenDesktop site
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential] $Credential,
        ## Citrix XenDesktop site name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $SiteName,
        ## Microsoft SQL Server FQDN
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $DatabaseServer,
        ## Citrix license server FQDN
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $LicenseServer,
        ## List of Active Directory site administrators
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String[]] $SiteAdministrators,
        ## List of all FQDNs and NetBIOS of XenDesktop site controller names for credential delegation
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String[]] $DelegatedComputers,
        ## Citrix XenDesktop Site database name
        [Parameter()] [System.String] $SiteDatabaseName = "$($SiteName)Site",
        ## Citrix XenDesktop Logging database name
        [Parameter()] [System.String] $LoggingDatabaseName = "$($SiteName)Logging",
        ## Citrix XenDesktop Monitor database name
        [Parameter()] [System.String] $MonitorDatabaseName = "$($SiteName)Monitor"
    )

    Import-DscResource -ModuleName xCredSSP, CitrixXenDesktop7;

    xCredSSP CredSSPServer {
        Role = 'Server';
    }
    
    xCredSSP CredSSPClient {
        Role = 'Client';
        DelegateComputers = $DelegatedComputers;
    }
        
    XD7Feature XD7Controller {
        Role = 'Controller';
        SourcePath = $XenDesktopMediaPath;
    }

    XD7Feature XD7Studio {
        Role = 'Studio';
        SourcePath = $XenDesktopMediaPath;
    }

    XD7Database XD7SiteDatabase {
        SiteName = $SiteName;
        DatabaseServer = $DatabaseServer;
        DatabaseName = $SiteDatabaseName;
        Credential = $Credential;
        DataStore = 'Site';
        DependsOn = '[XD7Feature]XD7Controller';
    }

    XD7Database XD7SiteLoggingDatabase {
        SiteName = $SiteName;
        DatabaseServer = $DatabaseServer;
        DatabaseName = $LoggingDatabaseName;
        Credential = $Credential;
        DataStore = 'Logging';
        DependsOn = '[XD7Feature]XD7Controller';
    }
    
    XD7Database XD7SiteMonitorDatabase {
        SiteName = $SiteName;
        DatabaseServer = $DatabaseServer;
        DatabaseName = $MonitorDatabaseName;
        Credential = $Credential;
        DataStore = 'Monitor';
        DependsOn = '[XD7Feature]XD7Controller';
    }
        
    XD7Site XD7Site {
        SiteName = $SiteName;
        DatabaseServer = $DatabaseServer;
        SiteDatabaseName = $SiteDatabaseName;
        LoggingDatabaseName = $LoggingDatabaseName;
        MonitorDatabaseName = $MonitorDatabaseName;
        Credential = $Credential;
        DependsOn = '[XD7Feature]XD7Controller','[XD7Database]XD7SiteDatabase','[XD7Database]XD7SiteLoggingDatabase','[XD7Database]XD7SiteMonitorDatabase';
    }

    XD7SiteLicense XD7SiteLicense {
        LicenseServer = $LicenseServer;
        Credential = $Credential;
        DependsOn = '[XD7Site]XD7Site';
    }

    foreach ($administrator in $SiteAdministrators) {
        XD7Administrator $administrator {
            Name = $administrator;
            Credential = $Credential;
        }

        XD7Role "$($administrator)FullAdministrator" {
            Name = 'Full Administrator';
            Members = $administrator;
            Credential = $Credential;
        }
    }

}
       