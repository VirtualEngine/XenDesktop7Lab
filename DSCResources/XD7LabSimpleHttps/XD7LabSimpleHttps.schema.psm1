configuration XD7LabSimpleHttps {
     param (
        ## Citrix XenDesktop installation source root
        [Parameter(Mandatory)]
        [System.String] $XenDesktopMediaPath,
        
        ## Active Directory domain account used to install/configure the Citrix XenDesktop site
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,
        
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

        ## Personal information exchange (Pfx) ertificate file path
        [Parameter(Mandatory)]
        [System.String] $PfxCertificatePath,
        
        ## Pfx certificate thumbprint
        [Parameter(Mandatory)]
        [System.String] $PfxCertificateThumbprint,
        
        ## Pfx certificate password
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $PfxCertificateCredential,
        
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
        [Parameter()]
        [System.Boolean] $InstallRDSLicensingRole = $true,
        
        ## RDS license server - defaults to $ServerName
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $RDSLicenseServer = $ServerName
    )

    ## Avoid recursive import of the XenDesktop7Lab resource!
    Import-DscResource -Name XD7LabSessionHost, XD7LabStorefrontHttps, XD7LabLicenseServer, XD7LabSite, XD7LabMachineCatalog, XD7LabDeliveryGroup;

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

    ## Ensure we have domain credentials
    if ((-not $Credential.UserName.Contains('@')) -or (-not($Credential.UserName.Contains('\')))) {
        $credentialUPN = '{0}@{1}' -f $Credential.UserName, $DomainName;
        $Credential = New-Object System.Management.Automation.PSCredential($credentialUPN, $Credential.Password);
    }
    
    XD7LabSessionHost XD7SessionHost {
        XenDesktopMediaPath = $XenDesktopMediaPath;
        ControllerAddress = $ServerName;
        RDSLicenseServer = $RDSLicenseServer;
    }
    
    XD7LabStoreFrontHttps XD7StoreFrontHttps {
        XenDesktopMediaPath = $XenDesktopMediaPath;
        ControllerAddress = $ServerName;
        PfxCertificatePath = $PfxCertificatePath;
        PfxCertificateThumbprint = $PfxCertificateThumbprint;
        PfxCertificateCredential = $PfxCertificateCredential;
    }
    
    XD7LabLicenseServer XD7LicenseServer {
        XenDesktopMediaPath = $XenDesktopMediaPath;
        InstallRDSLicensingRole = $InstallRDSLicensingRole;
        CitrixLicensePath = $CitrixLicensePath;
    }

    XD7LabSite XD7Site {
        XenDesktopMediaPath = $XenDesktopMediaPath;
        Credential = $Credential;
        SiteName = $SiteName;
        DatabaseServer = $DatabaseServerName;
        LicenseServer = $ServerName;
        SiteAdministrators = 'Domain Admins';
        DelegatedComputers = $credSSPDelegatedComputers;
        LicenseModel = $LicenseModel;
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
        Description = $DeliveryGroupDescription;
        Users = $Users;
        DependsOn = '[XD7LabMachineCatalog]XD7Catalog';
    }

} #end configuration XD7LabSimple
