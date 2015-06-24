configuration XD7LabMachineCatalog {
    param (
        ## Machine catalog name
        [Parameter(Mandatory)] [System.String] $Name,
        ## Machine catalog description
        [Parameter()] [System.String] $Description = '',
        ## Machine catalog allocation type (defaults to 'Random')
        [Parameter()] [ValidateSet('Permanent','Random','Static')] $Allocation = 'Random',
        ## Machine catalog provisioning type (defaults to 'Manual')
        [Parameter()] [ValidateSet('Manual','PVS','MCS')] $Provisioning = 'Manual',
        ## Machine catalog user persistence type (defaults to 'Local')
        [Parameter()] [ValidateSet('Discard','Local','PVD')] $Persistence = 'Local',
        ## Machine catalog is RDS/Session Hosts
        [Parameter()] [System.Boolean] $IsMultiSession = $true,
        ## Active Directory domain account used to install/configure the Citrix XenDesktop machine catalog
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential] $Credential,
        ## Machine catalog computer accounts/members
        [Parameter(Mandatory)] [System.String[]] $ComputerName
    )

    Import-DscResource -ModuleName CitrixXenDesktop7;
    $resourceName = $Name.Replace(' ','_');

    XD7Catalog "Catalog_$resourceName" {
        Name = $Name;
        Description = 'Manual machine catalog provisioned by DSC';
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
