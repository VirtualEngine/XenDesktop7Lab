configuration XD7LabSimple {
     param (
        ## Citrix XenDesktop installation source root
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $XenDesktopMediaPath,
        
        ## Active Directory domain account used to install/configure the Citrix XenDesktop site
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,
        
        ## Citrix XenDesktop site name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $SiteName,
        
        ## Server fully-qualified domain name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $ServerName,
        
        ## Local path to Citrix XenDesktop license file(s)
        [Parameter(Mandatory)]
        [System.String[]] $CitrixLicensePath,
        
        ## Delivery group active directory user/groups
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String[]] $Users = 'Domain Users',
        
        ## Machine catalog name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $CatalogName = 'Manual',
        
        ## Machine catalog name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DeliveryGroupName = 'Default'
    )

    ## Avoid recursive import of the XenDesktop7Lab resource!
    Import-DscResource -Name XD7LabSessionHost, XD7LabStorefrontHttps, XD7LabLicenseServer, XD7LabSite, XD7LabMachineCatalog, XD7LabDeliveryGroup;
    
    XD7LabSessionHost XD7SessionHost {
        XenDesktopMediaPath = $XenDesktopMediaPath;
        ControllerAddress = $ServerName;
        RDSLicenseServer = $ServerName;
    }
    
    XD7LabStoreFront XD7StoreFront {
        XenDesktopMediaPath = $XenDesktopMediaPath;
        ControllerAddress = $ServerName;
    }
    
    XD7LabLicenseServer XD7LicenseServer {
        XenDesktopMediaPath = $XenDesktopMediaPath;
        InstallRDSLicensingRole = $true;
        CitrixLicensePath = $CitrixLicensePath;
    }

    XD7LabSite XD7Site {
        XenDesktopMediaPath = $XenDesktopMediaPath;
        Credential = $Credential;
        SiteName = $SiteName;
        DatabaseServer = $ServerName;
        LicenseServer = $ServerName;
        SiteAdministrators = 'Domain Admins';
        DelegatedComputers = $ServerName;
    }
    
    XD7LabMachineCatalog XD7Catalog {
        Name = $CatalogName;
        Credential = $Credential;
        ComputerName = $ServerName;
        DependsOn = '[XD7LabSite]XD7Site';
    }
    
    XD7LabDeliveryGroup XD7DeliveryGroup {
        Name = $DeliveryGroupName;
        Credential = $Credential;
        ComputerName = $ServerName;
        Users = $Users;
        DependsOn = '[XD7LabMachineCatalog]XD7Catalog';
    }

} #end configuration XD7LabSimple
