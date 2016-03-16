configuration XD7LabAdministrator {
     param (
        ## Citrix XenDesktop 7 built-in admin role
        [Parameter(Mandatory)] [ValidateSet('Full','DeliveryGroup','HelpDesk','Host','MachineCatalog','ReadOnly')]
        [System.String] $Role,
        
        ## Users/groups to add to the Citrix XenDesktop 7.x admin role
        [Parameter(Mandatory)]
        [System.String[]] $Administrator,
        
        ## Domain FQDN
        [Parameter(Mandatory)]
        [System.String] $DomainName,
        
        [Parameter()] [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )
    
    Import-DscResource -ModuleName XenDesktop7;
    
    $netBIOSDomainName = $DomainName.Split('.')[0];
    
    ## Full Administrators with domain qualifier
    $netBIOSDomainAdministrators = @();
    
    ## Credential with domain qualifier
    $domainCredential = $Credential;
    
    if ((-not $Credential.UserName.Contains('\')) -and (-not $Credential.UserName.Contains('@'))) {
        ## Create DOMAIN\UserName credential
        $netBIOSUsername = '{0}\{1}' -f $netBIOSDomainName, $Credential.UserName;
        $domainCredential = New-Object System.Management.Automation.PSCredential($netBIOSUsername, $Credential.Password);
    }
    
    foreach ($administrator in $FullAdministrator) {
        
        $resourceId = $administrator.Replace('\','_').Replace('@','_');
        
        $netBIOSAdministrator = $administrator;
        if ((-not $administrator.UserName.Contains('\')) -and (-not $administrator.UserName.Contains('@'))) {
            ## Ensure we have DOMAIN\UserOrGroup
            $netBIOSAdministrator = '{0}\{1}' -f $netBIOSDomainName, $administrator;
        }
        
        if ($PSBoundParameters.ContainsKey('Credential')) {
            XD7Administrator $resourceId {
                Name = $netBIOSAdministrator;
                Credential = $Credential;
            }
        }
        else {
            XD7Administrator $resourceId {
                Name = $netBIOSAdministrator;
            }
        }
        
        $netBIOSDomainAdministrators += $netBIOSAdministrator;
    
    } #end foreach Full Administrator
    
    $resourceId = '{0}Administrator' -f $Role;
    switch ($Role) {
        'DeliveryGroup' { $roleName = 'Delivery Group Administrator'; }
        'Full' { $roleName = 'Full Administrator'; }
        'HelpDesk' { $roleName = 'Help Desk Administrator'; }
        'Host' { $roleName = 'Host Administrator'; }
        'MachineCatalog' { $roleName = 'Machine Catalog Administrator'; }
        'ReadOnly' { $roleName = 'Read Only Administrator'; }
    }
    
    if ($PSBoundParameters.ContainsKey('Credential')) {
        XD7Role $resourceId {
            Name = $roleName;
            Members = $netBIOSDomainAdministrators;
            Credential = $Credential;
        }
    }
    else {
        XD7Role $resourceId {
            Name = $roleName;
            Members = $netBIOSDomainAdministrators;
        }
    }
    
} #end configuration XD7LabAdministrator
