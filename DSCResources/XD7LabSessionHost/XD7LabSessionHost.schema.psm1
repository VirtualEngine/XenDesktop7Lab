configuration XD7LabSessionHost {
    param (
        ## Citrix XenDesktop installation source root
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $XenDesktopMediaPath,

        ## Citrix XenDesktop delivery controller address(es)
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $ControllerAddress,

        ## RDS license server
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $RDSLicenseServer,

        ## Users/groups to add to the local Remote Desktop Users group
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $RemoteDesktopUsers,

        ## Active Directory domain account used to communicate with AD for Remote Desktop Users
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        ## Windows features to install on session host
        [Parameter()]
        [System.String[]] $WindowsFeature = @('RDS-RD-Server', 'Remote-Assistance', 'Desktop-Experience')
    )

    Import-DscResource -ModuleName XenDesktop7;

    $featureDependsOn = @();
    foreach ($feature in $WindowsFeature) {

        WindowsFeature $feature {
            Name   = $feature;
            Ensure = 'Present';
        }

        $featureDependsOn += "[WindowsFeature]$feature";
    }

    if ($featureDependsOn.Count -ge 1) {

        XD7VDAFeature 'XD7SessionVDA' {
            Role       = 'SessionVDA';
            SourcePath = $XenDesktopMediaPath;
            DependsOn  = $featureDependsOn;
        }
    }
    else {

        XD7VDAFeature 'XD7SessionVDA' {
            Role       = 'SessionVDA';
            SourcePath = $XenDesktopMediaPath;
        }
    }

    foreach ($controller in $ControllerAddress) {

        XD7VDAController "XD7VDA_$controller" {
            Name = $controller;
            DependsOn = '[XD7VDAFeature]XD7SessionVDA';
        }
    }

    if ($PSBoundParameters.ContainsKey('RemoteDesktopUsers')) {

        if ($PSBoundParameters.ContainsKey('Credential')) {

            Group 'RemoteDesktopUsers' {
                GroupName = 'Remote Desktop Users';
                MembersToInclude = $RemoteDesktopUsers;
                Ensure = 'Present';
                Credential = $Credential;
            }
        }
        else {

            Group 'RemoteDesktopUsers' {
                GroupName = 'Remote Desktop Users';
                MembersToInclude = $RemoteDesktopUsers;
                Ensure = 'Present';
            }
        } #end if Credential

    } #end if Remote Desktop Users

    Registry 'RDSLicenseServer' {
        Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TermService\Parameters\LicenseServers';
        ValueName = 'SpecifiedLicenseServers';
        ValueData = $RDSLicenseServer;
        ValueType = 'MultiString';
    }

    Registry 'RDSLicensingMode' {
        Key = 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server\RCM\Licensing Core';
        ValueName = 'LicensingMode';
        ValueData = '4'; # 2 = Per Device, 4 = Per User
        ValueType = 'Dword';
    }

} #end configuration XD7LabSessionHost
