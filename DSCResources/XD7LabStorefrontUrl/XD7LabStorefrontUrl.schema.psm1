configuration XD7LabStorefrontUrl {
    param (
        [Parameter(Mandatory)]
        [System.String] $BaseUrl
    )

    Import-DscResource -ModuleName XenDesktop7;
    
    if (-not ($BaseUrl.StartsWith('http://') -or $BaseUrl.StartsWith('https://'))) {
        $BaseUrl = 'http://{0}' -f $BaseUrl;
    }
    
    if (-not $BaseUrl.EndsWith('/')) {
        $BaseUrl = '{0}/' -f $BaseUrl;
    }
    
    $baseUrlResourceId = $BaseUrl.Replace('://','_').Replace('/','_');
    XD7StoreFrontBaseUrl $baseUrlResourceId {
        BaseUrl = $BaseUrl;
    }
    
} #end configuration XD7LabStorefrontUrl
