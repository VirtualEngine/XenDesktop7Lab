configuration XD7LabDeliveryGroup {
    param (
        ## Delivery group name
        [Parameter(Mandatory)]
        [System.String] $Name,

        ## Delivery group computer accounts/members
        [Parameter(Mandatory)]
        [System.String[]] $ComputerName,

        ## Delivery group active directory user/groups
        [Parameter(Mandatory)]
        [System.String[]] $Users,

        ## Delivery group description
        [Parameter()]
        [AllowNull()]
        [System.String] $Description = '',

        ## Delivery group delivery type (defaults to 'DesktopsAndApps')
        [Parameter()]
        [ValidateSet('AppsOnly','DesktopsAndApps','DesktopsOnly')]
        [System.String] $DeliveryType = 'DesktopsAndApps',

        ## Delivery group desktop type (defaults to 'Shared')
        [Parameter()]
        [ValidateSet('Private','Shared')]
        [System.String] $DesktopType = 'Shared',

        ## Delivery group is RDS/Session Hosts
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $IsMultiSession = $true,

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
        XD7DesktopGroup "DesktopGroup_$resourceName" {
            Name = $Name;
            Description = $Description;
            DeliveryType = $DeliveryType;
            DesktopType = $DesktopType;
            IsMultiSession = $IsMultiSession;
            Credential = $Credential;
        }

        XD7DesktopGroupMember "DesktopGroup_$($resourceName)_Machines" {
            Name = $Name;
            Members = $ComputerName;
            Credential = $Credential;
            DependsOn = "[XD7DesktopGroup]DesktopGroup_$resourceName";
        }

        if ($DeliveryType -in 'DesktopsAndApps','DesktopsOnly') {

            XD7EntitlementPolicy "DesktopGroup_$($resourceName)_DesktopEntitlement" {
                DeliveryGroup = $Name;
                Name = $Name;
                Description = $Description;
                EntitlementType = 'Desktop';
                Credential = $Credential;
                DependsOn = "[XD7DesktopGroup]DesktopGroup_$resourceName";
            }
        }

        if ($DeliveryType -in 'DesktopsAndApps','AppsOnly') {

            XD7EntitlementPolicy "DesktopGroup_$($resourceName)_ApplicationEntitlement" {
                DeliveryGroup = $Name;
                Name = $Name;
                EntitlementType = 'Application';
                Credential = $Credential;
                DependsOn = "[XD7DesktopGroup]DesktopGroup_$resourceName";
            }
        }

        XD7AccessPolicy "DesktopGroup_$($resourceName)_Direct" {
            DeliveryGroup = $Name;
            AccessType = 'Direct';
            Credential = $Credential;
            DependsOn = "[XD7DesktopGroup]DesktopGroup_$resourceName";
            IncludeUsers = $Users;
        }

        XD7AccessPolicy "DesktopGroup_$($resourceName)_AG" {
            DeliveryGroup = $Name;
            AccessType = 'AccessGateway';
            Credential = $Credential;
            DependsOn = "[XD7DesktopGroup]DesktopGroup_$resourceName";
            IncludeUsers = $Users;
        }
    }
    else {

        XD7DesktopGroup "DesktopGroup_$resourceName" {
            Name = $Name;
            Description = $Description;
            DeliveryType = $DeliveryType;
            DesktopType = $DesktopType;
            IsMultiSession = $IsMultiSession;
        }

        XD7DesktopGroupMember "DesktopGroup_$($resourceName)_Machines" {
            Name = $Name;
            Members = $ComputerName;
            DependsOn = "[XD7DesktopGroup]DesktopGroup_$resourceName";
        }

        if ($DeliveryType -in 'DesktopsAndApps','DesktopsOnly') {

            XD7EntitlementPolicy "DesktopGroup_$($resourceName)_DesktopEntitlement" {
                DeliveryGroup = $Name;
                Name = $Name;
                EntitlementType = 'Desktop';
                DependsOn = "[XD7DesktopGroup]DesktopGroup_$resourceName";
            }
        }

        if ($DeliveryType -in 'DesktopsAndApps','AppsOnly') {

            XD7EntitlementPolicy "DesktopGroup_$($resourceName)_ApplicationEntitlement" {
                DeliveryGroup = $Name;
                Name = $Name;
                EntitlementType = 'Application';
                Credential = $Credential;
                DependsOn = "[XD7DesktopGroup]DesktopGroup_$resourceName";
            }
        }

        XD7AccessPolicy "DesktopGroup_$($resourceName)_Direct" {
            DeliveryGroup = $Name;
            AccessType = 'Direct';
            DependsOn = "[XD7DesktopGroup]DesktopGroup_$resourceName";
            IncludeUsers = $Users;
        }

        XD7AccessPolicy "DesktopGroup_$($resourceName)_AG" {
            DeliveryGroup = $Name;
            AccessType = 'AccessGateway';
            DependsOn = "[XD7DesktopGroup]DesktopGroup_$resourceName";
            IncludeUsers = $Users;
        }
    }

} #end configuration XD7LabDeliveryGroup
