configuration XD7LabSessionHost {
    param (
        ## Citrix XenDesktop installation source root
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $XenDesktopMediaPath,
        ## Citrix XenDesktop delivery controller address(es)
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String[]] $ControllerAddress,
        ## RDS license server
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $RDSLicenseServer
    )

    Import-DscResource -ModuleName CitrixXenDesktop7;

    foreach ($feature in @('RDS-RD-Server', 'Remote-Assistance', 'Desktop-Experience')) {
        WindowsFeature $feature {
            Name = $feature;
            Ensure = 'Present';
        }
    }
        
    XD7VDAFeature XD7SessionVDA {
        Role = 'SessionVDA';
        SourcePath = $XenDesktopMediaPath;
        DependsOn = '[WindowsFeature]RDS-RD-Server';
    }

    foreach ($controller in $ControllerAddress) {
        XD7VDAController "XD7VDA_$controller" {
            Name = $controller;
            DependsOn = '[XD7VDAFeature]XD7SessionVDA';
        }
    }

    Registry RDSLicenseServer {
        Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TermService\Parameters\LicenseServers';
        ValueName = 'SpecifiedLicenseServers';
        ValueData = $RDSLicenseServer;
        ValueType = 'MultiString';
    }

    Registry RDSLicensingMode {
        Key = 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server\RCM\Licensing Core';
        ValueName = 'LicensingMode';
        ValueData = '4'; # 2 = Per Device, 4 = Per User
        ValueType = 'Dword';
    }

}