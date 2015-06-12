configuration XD7LabDeliveryGroup {
    param (
        ## Delivery group name
        [Parameter(Mandatory)] [System.String] $Name,
        ## Delivery group description
        [Parameter()] [System.String] $Description = '',
        ## Delivery group delivery type (defaults to 'DesktopsAndApps')
        [Parameter()] [ValidateSet('AppsOnly','DesktopsAndApps','DesktopsOnly')] $DeliveryType = 'DesktopsAndApps',
        ## Delivery group desktop type (defaults to 'Shared')
        [Parameter()] [ValidateSet('Private','Shared')] $DesktopType = 'Shared',
        ## Delivery group is RDS/Session Hosts
        [Parameter()] [System.Boolean] $IsMultiSession = $true,
        ## Active Directory domain account used to install/configure the Citrix XenDesktop machine catalog
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential] $Credential,
        ## Delivery group computer accounts/members
        [Parameter(Mandatory)] [System.String[]] $ComputerName,
        ## Delivery group active directory user/groups
        [Parameter(Mandatory)] [System.String[]] $Users
    )

    Import-DscResource -ModuleName CitrixXenDesktop7;
    $resourceName = $Name.Replace(' ','_');

    cXD7DesktopGroup "DesktopGroup_$resourceName" {
        Name = $Name;
        Description = $Description;
        DeliveryType = $DeliveryType;
        DesktopType = $DesktopType;
        IsMultiSession = $IsMultiSession;
        Credential = $Credential;
    }

    cXD7DesktopGroupMember "DesktopGroup_$($resourceName)_Machines" {
        Name = $Name;
        Members = $ComputerName;
        Credential = $Credential;
        DependsOn = "[cXD7DesktopGroup]DesktopGroup_$resourceName";
    }

    cXD7EntitlementPolicy "DesktopGroup_$($resourceName)_Entitlement" {
        DeliveryGroup = $Name;
        EntitlementType = 'Desktop';
        Credential = $Credential;
        DependsOn = "[cXD7DesktopGroup]DesktopGroup_$resourceName";
    }

    cXD7AccessPolicy "DesktopGroup_$($resourceName)_Direct" {
        DeliveryGroup = $Name;
        AccessType = 'Direct';
        Credential = $Credential;
        DependsOn = "[cXD7DesktopGroup]DesktopGroup_$resourceName";
        IncludeUsers = $Users;
    }

    cXD7AccessPolicy "DesktopGroup_$($resourceName)_AG" {
        DeliveryGroup = $Name;
        AccessType = 'AccessGateway';
        Credential = $Credential;
        DependsOn = "[cXD7DesktopGroup]DesktopGroup_$resourceName";
        IncludeUsers = $Users;
    }

}