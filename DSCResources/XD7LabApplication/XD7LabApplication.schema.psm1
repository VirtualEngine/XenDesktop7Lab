configuration XD7LabApplication {
     param (
        ## Citrix XenDesktop 7 application name
        [Parameter(Mandatory)]
        [System.String] $Name,

        ## Citrix XenDesktop 7 application executable path
        [Parameter(Mandatory)]
        [System.String] $Path,

        [Parameter()]
        [ValidateSet('Published','Local')]
        [System.String] $Type = 'Published',

        ## Citrix XenDesktop 7 desktop delivery group name
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DesktopGroupName = 'Default Desktop',

        ## Application executable arguments
        [Parameter()]
        [AllowNull()]
        [System.String] $Arguments,

        ## Working directory of the application executable
        [Parameter()]
        [AllowNull()]
        [System.String] $WorkingDirectory,

        [Parameter()]
        [AllowNull()]
        [System.String] $Description,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DisplayName = $Name,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $Enabled = $true,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $Visible = $true,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

    Import-DscResource -ModuleName XenDesktop7;

    $resourceId = '{0}_{1}' -f $DesktopGroupName.Replace(' ','_'), $Name;

    if ($PSBoundParameters.ContainsKey('Credential')) {

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
            Credential = $Credential;
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
            DisplayName = $DisplayName;
        }
    }

} #end configuration XD7LabPublishedApp
