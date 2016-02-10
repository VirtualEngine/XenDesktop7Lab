configuration XD7LabApplication {
     param (
        ## Citrix XenDesktop 7 application name
        [Parameter(Mandatory)]
        [System.String] $Name,
        
        ## Citrix XenDesktop 7 application executable path
        [Parameter(Mandatory)]
        [System.String] $Path,
        
        [Parameter()] [ValidateSet('Published','Local')]
        [System.String] $Type = 'Published',
        
        ## Citrix XenDesktop 7 desktop delivery group name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DeliveryGroupName = 'Default Desktop',
        
        ## Application executable arguments
        [Parameter()] [AllowNull()]
        [System.String] $Arguments,

        ## Working directory of the application executable 
        [Parameter()] [AllowNull()]
        [System.String] $WorkingDirectory,
                
        [Parameter()] [AllowNull()]
        [System.String] $Description,

        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DisplayName,
        
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $Enabled = $true,
        
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $Visible = $true,
    )
    
    Import-DscResource -Name XenDesktop7;
    
    $resourceId = '{0}_{1}' -f $DeliveryGroupName.Replace(' ','_'), $Name;
    
    if ($PSBoundParameters.ContainsKey('DisplayName')) {
        XD7DesktopGroupApplication $resourceId {
            Name = $Name;
            DesktopGroupName = $DesktopGroupName;
            Path = $Path;
            ApplicationType = if ($Type -eq 'Published') { 'HostedOnDesktop' } else { 'InstalledOnClient' };
            Arguments = $Arguments;
            WorkingDirectory = $WorkingDirectory;
            Description = $Description;
            Enabled = $Enabled;
            Visible = $Visible;
            DisplayName = $DisplayName;
        }
    }
    else {
        XD7DesktopGroupApplication $resourceId {
            Name = $Name;
            DesktopGroupName = $DesktopGroupName;
            Path = $Path;
            ApplicationType = if ($Type -eq 'Published') { 'HostedOnDesktop' } else { 'InstalledOnClient' };
            Arguments = $Arguments;
            WorkingDirectory = $WorkingDirectory;
            Description = $Description;
            Enabled = $Enabled;
            Visible = $Visible;
        }
    }
    
} #end configuration XD7LabPublishedApp
