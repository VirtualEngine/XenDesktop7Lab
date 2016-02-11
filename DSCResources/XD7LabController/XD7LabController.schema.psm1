configuration XD7LabController {
    param (
        ## Citrix XenDesktop installation source root
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $XenDesktopMediaPath,
        
        ## Citrix XenDesktop site name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $SiteName,
        
        ## Existing XenDesktop controller used to join the site
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $ExistingControllerAddress,
        
        ## List of all FQDNs and NetBIOS of XenDesktop site controller names for credential delegation
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String[]] $DelegatedComputers,
        
        ## Active Directory domain account used to install/configure the Citrix XenDesktop site
        [Parameter()] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $Credential
    )

    Import-DscResource -ModuleName xCredSSP, XenDesktop7;

    xCredSSP CredSSPServer {
        Role = 'Server';
    }
    
    xCredSSP CredSSPClient {
        Role = 'Client';
        DelegateComputers = $DelegatedComputers;
    }
        
    XD7Feature XD7Controller {
        Role = 'Controller';
        SourcePath = $XenDesktopMediaPath;
    }

    XD7Feature XD7Studio {
        Role = 'Studio';
        SourcePath = $XenDesktopMediaPath;
    }

    if ($PSBoundParameters.ContainsKey('Credential')) {
        XD7WaitForSite 'WaitForXD7Site' {
            SiteName = $SiteName;
            ExistingControllerName = $ExistingControllerAddress;
            Credential = $Credential;
            DependsOn = '[XD7Feature]XD7Controller';
        }
            
        XD7Controller 'XD7ControllerJoin' {
            SiteName = $SiteName;
            ExistingControllerName = $ExistingControllerAddress;
            Credential = $Credential;
            DependsOn = '[XD7Feature]XD7Controller','[XD7WaitForSite]WaitForXD7Site';
        }
    }
    else {
        XD7WaitForSite 'WaitForXD7Site' {
            SiteName = $SiteName;
            ExistingControllerName = $ExistingControllerAddress;
            DependsOn = '[XD7Feature]XD7Controller';
        }
            
        XD7Controller 'XD7ControllerJoin' {
            SiteName = $SiteName;
            ExistingControllerName = $ExistingControllerAddress;
            DependsOn = '[XD7Feature]XD7Controller','[XD7WaitForSite]WaitForXD7Site';
        }
    }

} #end configuration XD7LabController
