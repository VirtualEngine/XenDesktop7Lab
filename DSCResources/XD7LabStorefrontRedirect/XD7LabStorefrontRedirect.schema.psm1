configuration XD7LabStorefrontRedirect {
    param (
        [Parameter(Mandatory)]
        [System.String] $RedirectUrl;
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;
    
    $defaultDocument = '<script type="text/javascript"><!-- {0}window.location="{1}"; // --></script>' -f "`r`n", $RedirectUrl;    
    
    File 'storefront_inetpub_wwwroot_index_htm' {
        DestinationPath = 'C:\inetpub\wwwroot\index.htm';
        Contents = $defaultDocument;
        Type = 'File'
        Ensure = 'Present';
    }

} #end configuration XD7LabStorefrontUrl
