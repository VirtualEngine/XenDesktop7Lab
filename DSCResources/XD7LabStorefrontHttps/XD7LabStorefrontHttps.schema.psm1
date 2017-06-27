configuration XD7LabStorefrontHttps {
    param (
        ## Citrix XenDesktop installation source root
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $XenDesktopMediaPath,

        ## Pfx certificate thumbprint
        [Parameter(Mandatory)]
        [System.String] $PfxCertificateThumbprint,

        ## XenDesktop controller address for Director connectivity
        [Parameter(Mandatory)]
        [System.String[]] $ControllerAddress,

        ## Pfx certificate password
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $PfxCertificateCredential,

        ## Personal information exchange (Pfx) ertificate file path
        [Parameter()]
        [System.String] $PfxCertificatePath
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, XenDesktop7, xWebAdministration, xCertificate;

    $features = @(
        'NET-Framework-45-ASPNET',
        'Web-Server',
        'Web-Common-Http',
        'Web-Default-Doc',
        'Web-Http-Errors',
        'Web-Static-Content',
        'Web-Http-Redirect',
        'Web-Http-Logging',
        'Web-Filtering',
        'Web-Basic-Auth',
        'Web-Client-Auth',
        'Web-Windows-Auth',
        'Web-Net-Ext45',
        'Web-AppInit',
        'Web-Asp-Net45',
        'Web-ISAPI-Ext',
        'Web-ISAPI-Filter',
        'Web-Mgmt-Console',
        'Web-Scripting-Tools'
    )
    foreach ($feature in $features) {

        WindowsFeature $feature {
            Name = $feature;
            Ensure = 'Present';
        }
    }

    XD7Feature 'XD7StoreFront' {
        Role = 'Storefront';
        SourcePath = $XenDesktopMediaPath;
        DependsOn = '[WindowsFeature]Web-Server';
    }

    XD7Feature 'XD7Director' {
        Role = 'Director';
        SourcePath = $XenDesktopMediaPath;
        DependsOn = '[WindowsFeature]Web-Server';
    }

    foreach ($controller in $ControllerAddress) {

        xWebConfigKeyValue "ServiceAutoDiscovery_$controller" {
            ConfigSection = 'AppSettings';
            Key = 'Service.AutoDiscoveryAddresses';
            Value = $controller;
            IsAttribute = $false;
            WebsitePath = 'IIS:\Sites\Default Web Site\Director';
            DependsOn = '[WindowsFeature]Web-Server','[XD7Feature]XD7Director';
        }
    }

    $xWebSiteDependsOn = @('[WindowsFeature]Web-Server');

    if (($PSBoundParameters.ContainsKey('PfxCertificatePath')) -or
        ($PSBoundParameters.ContainsKey('PfxCertificateCredential'))) {

        xPfxImport 'PfxCertificate' {
            Thumbprint = $PfxCertificateThumbprint;
            Location = 'LocalMachine';
            Store = 'My';
            Path = $PfxCertificatePath;
            Credential = $PfxCertificateCredential;
        }

        $xWebSiteDependsOn += '[xPfxImport]PfxCertificate';
    }

    xWebSite 'DefaultWebSite' {
        Name = 'Default Web Site';
        PhysicalPath = 'C:\inetpub\wwwroot';
        BindingInfo = @(
            MSFT_xWebBindingInformation  { Protocol = 'HTTPS'; Port = 443; CertificateThumbprint = $PfxCertificateThumbprint; CertificateStoreName = 'My'; }
            MSFT_xWebBindingInformation  { Protocol = 'HTTP'; Port = 80; }
        )
        DependsOn = $xWebSiteDependsOn;
    }

} #end configuration XD7LabStorefrontHttps
