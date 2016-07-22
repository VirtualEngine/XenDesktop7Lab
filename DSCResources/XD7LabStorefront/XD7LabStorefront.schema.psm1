configuration XD7LabStorefront {
    param (
        ## Citrix XenDesktop installation source root
        [Parameter(Mandatory)]
        [System.String] $XenDesktopMediaPath,

        ## XenDesktop controller address for Director
        [Parameter(Mandatory)]
        [System.String[]] $ControllerAddress
    )

    Import-DscResource -ModuleName XenDesktop7, xWebAdministration;

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
        SourcePath = $XenDesktopMediaPath;#
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

} #end configuration XD7LabStorefront
