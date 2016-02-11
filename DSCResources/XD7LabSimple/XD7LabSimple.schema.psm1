configuration XD7LabSimple {
     param (
        ## Citrix XenDesktop installation source root
        [Parameter(Mandatory)]
        [System.String] $XenDesktopMediaPath,
        
        ## Citrix XenDesktop site name
        [Parameter(Mandatory)]
        [System.String] $SiteName,
        
        ## Server fully-qualified domain name
        [Parameter(Mandatory)]
        [System.String] $ServerName,

        ## Server fully-qualified domain name
        [Parameter(Mandatory)]
        [System.String] $DatabaseServerName,
        
        ## Local path to Citrix XenDesktop license file(s)
        [Parameter(Mandatory)]
        [System.String[]] $CitrixLicensePath,

        ## Domain FQDN
        [Parameter(Mandatory)]
        [System.String] $DomainName,
        
        ## Delivery group active directory user/groups
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String[]] $Users = 'Domain Users',
        
        ## Machine catalog name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $CatalogName = 'Manual',
        
        ## Delivery group name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DeliveryGroupName = 'Default Desktop',

        ## Delivery group name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DeliveryGroupDescription = 'Virtual Engine Lab',

        ## Citrix XenDesktop licensing model
        [Parameter()] [ValidateSet('UserDevice','Concurrent')] [System.String] $LicenseModel = 'UserDevice',
        
        ## Install Microsoft RDS license server role
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $InstallRDSLicensingRole = $true,
        
         ## Active Directory domain account used to install/configure the Citrix XenDesktop site
        [Parameter()] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $Credential
    )

    ## Avoid recursive import of the XenDesktop7Lab resource!
    Import-DscResource -Name XD7LabSessionHost, XD7LabStorefront, XD7LabLicenseServer, XD7LabSite, XD7LabMachineCatalog, XD7LabDeliveryGroup;

    ## Create ServerName and ServerName.DomainName names
    if ($ServerName.Contains('.')) {
        $credSSPDelegatedComputers = @($ServerName, $ServerName.Split('.')[0]);
    }
    else {
        $credSSPDelegatedComputers = @($ServerName, ('{0}.{1}' -f $ServerName, $DomainName));
    }

    if (-not $DatabaseServerName.Contains('.')) {
        $DatabaseServerName = '{0}.{1}' -f $DatabaseServerName, $DomainName;
    }
    
    XD7LabSessionHost 'XD7SessionHost' {
        XenDesktopMediaPath = $XenDesktopMediaPath;
        ControllerAddress = $ServerName;
        RDSLicenseServer = $ServerName;
    }
    
    XD7LabStoreFront 'XD7StoreFront' {
        XenDesktopMediaPath = $XenDesktopMediaPath;
        ControllerAddress = $ServerName;
    }
    
    XD7LabLicenseServer 'XD7LicenseServer' {
        XenDesktopMediaPath = $XenDesktopMediaPath;
        InstallRDSLicensingRole = $InstallRDSLicensingRole;
        CitrixLicensePath = $CitrixLicensePath;
    }
    
    if ($PSBoundParameters.ContainsKey('Credential')) {
        ## Ensure we have domain credentials
        if ((-not $Credential.UserName.Contains('@')) -or (-not($Credential.UserName.Contains('\')))) {
            $credentialUPN = '{0}@{1}' -f $Credential.UserName, $DomainName;
            $Credential = New-Object System.Management.Automation.PSCredential($credentialUPN, $Credential.Password);
        }

        XD7LabSite 'XD7Site' {
            XenDesktopMediaPath = $XenDesktopMediaPath;
            Credential = $Credential;
            SiteName = $SiteName;
            DatabaseServer = $DatabaseServerName;
            LicenseServer = $ServerName;
            SiteAdministrators = 'Domain Admins';
            DelegatedComputers = $credSSPDelegatedComputers;
            LicenseModel = $LicenseModel;
        }
        
        XD7LabMachineCatalog 'XD7Catalog' {
            Name = $CatalogName;
            Credential = $Credential;
            ComputerName = $ServerName;
            DependsOn = '[XD7LabSite]XD7Site';
        }
        
        XD7LabDeliveryGroup 'XD7DeliveryGroup' {
            Name = $DeliveryGroupName;
            Credential = $Credential;
            ComputerName = $ServerName;
            Description = $DeliveryGroupDescription;
            Users = $Users;
            DependsOn = '[XD7LabMachineCatalog]XD7Catalog';
        }
    }
    else {
        XD7LabSite 'XD7Site' {
            XenDesktopMediaPath = $XenDesktopMediaPath;
            SiteName = $SiteName;
            DatabaseServer = $DatabaseServerName;
            LicenseServer = $ServerName;
            SiteAdministrators = 'Domain Admins';
            DelegatedComputers = $credSSPDelegatedComputers;
            LicenseModel = $LicenseModel;
        }
        
        XD7LabMachineCatalog 'XD7Catalog' {
            Name = $CatalogName;
            ComputerName = $ServerName;
            DependsOn = '[XD7LabSite]XD7Site';
        }
        
        XD7LabDeliveryGroup XD7DeliveryGroup {
            Name = $DeliveryGroupName;
            ComputerName = $ServerName;
            Description = $DeliveryGroupDescription;
            Users = $Users;
            DependsOn = '[XD7LabMachineCatalog]XD7Catalog';
        }
    }

} #end configuration XD7LabSimple
