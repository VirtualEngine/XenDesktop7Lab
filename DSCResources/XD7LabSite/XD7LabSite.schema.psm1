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
        
    cXD7Feature XD7Controller {
        Role = 'Controller';
        SourcePath = $XenDesktopMediaPath;
    }

    cXD7Feature XD7Studio {
        Role = 'Studio';
        SourcePath = $XenDesktopMediaPath;
    }

    cXD7Database XD7SiteDatabase {
        SiteName = $SiteName;
        DatabaseServer = $DatabaseServer;
        DatabaseName = $SiteDatabaseName;
        Credential = $Credential;
        DataStore = 'Site';
        DependsOn = '[cXD7Feature]XD7Controller';
    }

    cXD7Database XD7SiteLoggingDatabase {
        SiteName = $SiteName;
        DatabaseServer = $DatabaseServer;
        DatabaseName = $LoggingDatabaseName;
        Credential = $Credential;
        DataStore = 'Logging';
        DependsOn = '[cXD7Feature]XD7Controller';
    }
    
    cXD7Database XD7SiteMonitorDatabase {
        SiteName = $SiteName;
        DatabaseServer = $DatabaseServer;
        DatabaseName = $MonitorDatabaseName;
        Credential = $Credential;
        DataStore = 'Monitor';
        DependsOn = '[cXD7Feature]XD7Controller';
    }
        
    cXD7Site XD7Site {
        SiteName = $SiteName;
        DatabaseServer = $DatabaseServer;
        SiteDatabaseName = $SiteDatabaseName;
        LoggingDatabaseName = $LoggingDatabaseName;
        MonitorDatabaseName = $MonitorDatabaseName;
        Credential = $Credential;
        DependsOn = '[cXD7Feature]XD7Controller','[cXD7Database]XD7SiteDatabase','[cXD7Database]XD7SiteLoggingDatabase','[cXD7Database]XD7SiteMonitorDatabase';
    }

    cXD7SiteLicense XD7SiteLicense {
        LicenseServer = $LicenseServer;
        Credential = $Credential;
        DependsOn = '[cXD7Site]XD7Site';
    }

    foreach ($administrator in $SiteAdministrators) {
        cXD7Administrator $administrator {
            Name = $administrator;
            Credential = $Credential;
        }

        cXD7Role "$($administrator)FullAdministrator" {
            Name = 'Full Administrator';
            Members = $administrator;
            Credential = $Credential;
        }
    }

}
       