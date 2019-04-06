configuration XD7LabMsiLicenseServer {
    [CmdletBinding()]
    param (
        ## Citrix XenDesktop installation source root
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $MsiPath,

        ## Install Microsoft RDS license server role
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $InstallRDSLicensingRole = $true,

        ## Path Citrix XenDesktop license file(s)
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $CitrixLicensePath,

        ## Active Directory domain account used to download the Citrix license file(s)
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        ## Path(s) to Citrix license file(s) are directory paths
        [Parameter()]
        [System.Boolean] $IsCitrixLicensePathDirectory
    )

    Import-DscResource -ModuleName XenDesktop7, PSDesiredStateConfiguration;

    if ($InstallRDSLicensingRole) {

        WindowsFeature 'RDSLicensing' {
            Name = 'RDS-Licensing';
        }

        WindowsFeature 'RDSLicensingUI' {
            Name = 'RDS-Licensing-UI';
        }
    }

    Package 'CitrixLicenseServerMsi' {
        Name      = 'Citrix Licensing';
        ProductId = ''
        Path      = $MsiPath;
        Ensure    = 'Present';
    }
    
    if ($IsCitrixLicensePathDirectory) {

        $fileType = 'Directory';
        $fileRecurse = $true;
    }
    else {

        $fileType = 'File';
        $fileRecurse = $false;
    }

    foreach ($licenseFile in $CitrixLicensePath) {

        $counter = 1;
        if ($PSBoundParameters.ContainsKey('Credential')) {

            File "XDLicenseFile_$counter" {
                Type = $fileType;
                Recurse = $fileRecurse;
                SourcePath = $licenseFile;
                DestinationPath = "${env:ProgramFiles(x86)}\Citrix\Licensing\MyFiles";
                Credential = $Credential;
            }
        }
        else {

            File "XDLicenseFile_$counter" {
                Type = $fileType;
                Recurse = $fileRecurse;
                SourcePath = $licenseFile;
                DestinationPath = "${env:ProgramFiles(x86)}\Citrix\Licensing\MyFiles";
            }
        }
        $counter++;
    }

} #end configuration XD7LabMsiLicenseServer
