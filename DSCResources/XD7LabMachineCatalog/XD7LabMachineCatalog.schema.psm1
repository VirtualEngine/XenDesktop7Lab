configuration XD7LabMachineCatalog {
    param (
        ## Machine catalog name
        [Parameter(Mandatory)]
        [System.String] $Name,

        ## Machine catalog computer accounts/members
        [Parameter(Mandatory)]
        [System.String[]] $ComputerName,

        ## Machine catalog allocation type (defaults to 'Random')
        [Parameter()]
        [ValidateSet('Permanent','Random','Static')]
        [System.String] $Allocation = 'Random',

        ## Machine catalog provisioning type (defaults to 'Manual')
        [Parameter()]
        [ValidateSet('Manual','PVS','MCS')]
        [System.String] $Provisioning = 'Manual',

        ## Machine catalog user persistence type (defaults to 'Local')
        [Parameter()]
        [ValidateSet('Discard','Local','PVD')]
        [System.String] $Persistence = 'Local',

        ## Machine catalog is RDS/Session Hosts
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $IsMultiSession = $true,

        ## Machine catalog description
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Description = 'Manual machine catalog provisioned by DSC',

        ## Active Directory domain account used to install/configure the Citrix XenDesktop machine catalog
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

    Import-DscResource -ModuleName XenDesktop7;
    $resourceName = $Name.Replace(' ','_');

    if ($PSBoundParameters.ContainsKey('Credential')) {

        XD7Catalog "Catalog_$resourceName" {
            Name = $Name;
            Description = $Description;
            Allocation = $Allocation;
            Persistence = $Persistence;
            Provisioning = $Provisioning;
            IsMultiSession = $IsMultiSession;
            Credential = $Credential;
        }

        XD7CatalogMachine "Catalog_$($resourceName)_Machines" {
            Name = $Name;
            Members = $ComputerName
            Credential = $Credential;
            DependsOn = "[XD7Catalog]Catalog_$resourceName";
        }
    }
    else {

        XD7Catalog "Catalog_$resourceName" {
            Name = $Name;
            Description = $Description;
            Allocation = $Allocation;
            Persistence = $Persistence;
            Provisioning = $Provisioning;
            IsMultiSession = $IsMultiSession;
        }

        XD7CatalogMachine "Catalog_$($resourceName)_Machines" {
            Name = $Name;
            Members = $ComputerName
            DependsOn = "[XD7Catalog]Catalog_$resourceName";
        }
    }

} #end configuration XD7LabMachineCatalog
