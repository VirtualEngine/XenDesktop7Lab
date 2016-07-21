configuration XD7LabSimpleHttps {
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

        ## Database server fully-qualified domain name
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
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $PfxCertificateCredential,

        ## Custom StoreFront base url
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $StoreFrontBaseUrl,

        ## IIS root redirection relative/absolute url
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $StoreFrontRedirectUrl,

        ## Storefront explicit authentication methods available
        [Parameter()]
        [ValidateSet('IntegratedWindows','HttpBasic','ExplicitForms','CitrixFederation','CitrixAGBasic','Certificate')]
        [System.String[]] $StoreFrontAuthenticationMethods,

        ## Delivery group active directory user/groups
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Users = 'Domain Users',

        ## Machine catalog name
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $CatalogName = 'Manual',

        ## Delivery group name
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DeliveryGroupName = 'Default Desktop',

        ## Delivery group description
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DeliveryGroupDescription = 'Virtual Engine XenDesktop Lab Desktop KEYWORDS:Auto',

        ## Citrix XenDesktop licensing model
        [Parameter()]
        [ValidateSet('UserDevice','Concurrent')]
        [System.String] $LicenseModel = 'UserDevice',

        ## Install Microsoft RDS license server role
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $InstallRDSLicensingRole = $true,

        ## RDS license server - defaults to $ServerName
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $RDSLicenseServer = $ServerName,

        ## Citrix XenDesktop full administrators
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $SiteAdministrator,

        ## The XML Broker Service trust settings
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $TrustRequestsSentToXmlServicePort,

        ## Enable or disable auto-launching of the default desktop
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $AutoLaunchDesktop = $true,

        ## Enable the Citrix Receiver plugin detection
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $StorefrontPluginAssistant = $true,

        ## Citrix Storefront session timeout (mins)
        [Parameter()]
        [ValidateNotNull()]
        [System.UInt16] $StorefrontSessionTimeout = 20,

        ## Enable the Citrix Storefront Unified Experience
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $StorefrontUnifiedExperience,

        ## Active Directory domain account used to install/configure the Citrix XenDesktop site
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

    ## Avoid recursive import of the XenDesktop7Lab resource!
    Import-DscResource -Name XD7StoreFrontAuthenticationMethod, XD7StoreFrontReceiverAuthenticationMethod;
    Import-DscResource -Name XD7LabSessionHost, XD7LabStorefrontHttps, XD7LabLicenseServer, XD7LabSite, XD7LabMachineCatalog;
    Import-DscResource -Name XD7LabDeliveryGroup, XD7LabStorefrontUrl, XD7LabStorefrontRedirect, XD7LabStorefrontWebConfig;

    ## Create ServerName and ServerName.DomainName names
    if ($ServerName.Contains('.')) {
        $credSSPDelegatedComputers = @($ServerName, $ServerName.Split('.')[0]);
    }
    else {
        $credSSPDelegatedComputers = @($ServerName, ('{0}.{1}' -f $ServerName, $DomainName));
    }

    if (-not $DatabaseServerName.Contains('.')) {
        ## Create database server FQDN
        $DatabaseServerName = '{0}.{1}' -f $DatabaseServerName, $DomainName;
    }

    $domainUsers = @();
    foreach ($user in $Users) {

        if (($user.Contains('\')) -or ($user.Contains('@'))) {
            ## User group is already in domain format
            $domainUsers += $user;
        }
        else {
            ## Convert user/group to NetBIOSDomainName\Username
            $domainUsers += '{0}\{1}' -f $DomainName.Split('.')[0], $user;
        }
    }

    XD7LabSessionHost 'XD7SessionHost' {
        XenDesktopMediaPath = $XenDesktopMediaPath;
        ControllerAddress = $ServerName;
        RDSLicenseServer = $RDSLicenseServer;
    }

    XD7LabStoreFrontHttps 'XD7StoreFrontHttps' {
        XenDesktopMediaPath = $XenDesktopMediaPath;
        ControllerAddress = $ServerName;
        PfxCertificatePath = $PfxCertificatePath;
        PfxCertificateThumbprint = $PfxCertificateThumbprint;
        PfxCertificateCredential = $PfxCertificateCredential;
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
            SiteAdministrators = $SiteAdministrator;
            DelegatedComputers = $credSSPDelegatedComputers;
            LicenseModel = $LicenseModel;
            TrustRequestsSentToXmlServicePort = $TrustRequestsSentToXmlServicePort;
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
            Users = $domainUsers;
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
            TrustRequestsSentToXmlServicePort = $TrustRequestsSentToXmlServicePort;
        }

        XD7LabMachineCatalog 'XD7Catalog' {
            Name = $CatalogName;
            ComputerName = $ServerName;
            DependsOn = '[XD7LabSite]XD7Site';
        }

        XD7LabDeliveryGroup 'XD7DeliveryGroup' {
            Name = $DeliveryGroupName;
            ComputerName = $ServerName;
            Description = $DeliveryGroupDescription;
            Users = $domainUsers;
            DependsOn = '[XD7LabMachineCatalog]XD7Catalog';
        }
    }

    if ($PSBoundParameters.ContainsKey('StoreFrontAuthenticationMethods')) {

        XD7StoreFrontAuthenticationMethod 'StoreAuthenticationMethod' {
            VirtualPath = '/Citrix/Authentication';
            AuthenticationMethod = $StoreFrontAuthenticationMethods;
            ## Installing the site, creates the Storefront Store
            DependsOn = '[XD7LabSite]XD7Site';
        }

        XD7StoreFrontReceiverAuthenticationMethod 'StorefrontAuthenticationMethod' {
            VirtualPath = '/Citrix/StoreWeb';
            AuthenticationMethod = $StoreFrontAuthenticationMethods;
            DependsOn = '[XD7StoreFrontAuthenticationMethod]StoreAuthenticationMethod';
        }
    } #end if StoreFrontAuthenticationMethods

    if (($PSBoundParameters.ContainsKey('AutoLaunchDesktop')) -or
        ($PSBoundParameters.ContainsKey('StorefrontPluginAssistant')) -or
        ($PSBoundParameters.ContainsKey('StorefrontSessionTimeout'))) {

        XD7LabStorefrontWebConfig 'XD7StorefrontWebConfig' {
            Path = 'C:\inetpub\wwwroot\Citrix\StoreWeb\web.config';
            AutoLaunchDesktop = $AutoLaunchDesktop;
            PluginAssistant = $StorefrontPluginAssistant;
            SessionTimeout = $StorefrontSessionTimeout;
            ## Installing the site, creates the Storefront Store
            DependsOn = '[XD7LabSite]XD7Site';
        }
    }

    if ($PSBoundParameters.ContainsKey('StorefrontBaseUrl')) {

        XD7LabStoreFrontUrl 'lab_simple_storefront' {
            BaseUrl = $StoreFrontBaseUrl;
        }
    } #end if Storefront Base Url

    if ($PSBoundParameters.ContainsKey('StorefrontRedirectUrl')) {

        XD7LabStoreFrontRedirect 'lab_simple_storefront_redirect' {
            RedirectUrl = $StoreFrontRedirectUrl;
        }
    } #end if Storefront Redirect Url

    if ($PSBoundParameters.ContainsKey('StorefrontUnifiedExperience')) {

        XD7StoreFrontUnifiedExperience 'StoreFrontUnifiedExperience' {
            VirtualPath = '/Citrix/Store';
            WebReceiverVirtualPath = '/Citrix/StoreWeb';
            Ensure = if ($StorefrontUnifiedExperience -eq $true) { 'Present' } else { 'Absent' }
        }
    } #end if Storefront Unified Experience

} #end configuration XD7LabSimple
