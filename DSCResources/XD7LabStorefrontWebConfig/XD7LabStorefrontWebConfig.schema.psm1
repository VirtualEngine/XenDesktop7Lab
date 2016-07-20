configuration XD7LabStorefrontWebConfig {
<#
    .SYNOPSIS
        Configures a Xml element attribute
#>
    param (
        ## Path the Citrix Storefront web.config file
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Enable or disable autolaunching of the default desktop
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $AutoLaunchDesktop,

        ## Enable or disable the desktop view
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $ShowDesktopsView,

        ## Enable or disable the applications view
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $ShowAppsView,

        ## Configure the default view
        [Parameter()]
        [ValidateSet('Auto','Apps','Desktops')]
        [System.String] $DefaultView,

        ## Determine whether Citrix Receiver is installed on the user's device
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $PluginAssistant,

        ## Determine whether an older Citrix Receiver is upgraded on the user's device
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $PluginAssistantUpgrade,

        ## Enable or disable Workspace control
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $WorkspaceControl,

        ## Enable or disable automatic reconnection to any applications left running
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $AutoReconnectAtLogon,

        ## Configure the default log off action
        [Parameter()]
        [ValidateSet('Disconnect','None','Terminate')]
        [System.String] $LogOffAction,

        # Enables or disables users' ability to manually reconnect to applications that they left running
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $ShowReconnectButton,

        # Enables or disables users' ability to manually disconnect from applications without shutting them down
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $ShowDisconnectButton,

        # Configures HTML5 Web Receiver to use same browser tab
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $SingleTabLaunch,

        ## Configures the Web Receiver session timeout (mins)
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt16] $SessionTimeout
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    $settings = @{
        AutoLaunchDesktop = @{
                XPath = '/configuration/citrix.deliveryservices/webReceiver/clientSettings/userInterface';
                Attribute = 'autoLaunchDesktop';
            }
        ShowDesktopsView = @{
                XPath = '/configuration/citrix.deliveryservices/webReceiver/clientSettings/userInterface/uiViews';
                Attribute = 'showDesktopsView';
            }
        ShowAppsView = @{
                XPath = '/configuration/citrix.deliveryservices/webReceiver/clientSettings/userInterface/uiViews';
                Attribute = 'showAppsView';
            }
        DefaultView = @{
                XPath = '/configuration/citrix.deliveryservices/webReceiver/clientSettings/userInterface/uiViews';
                Attribute = 'defaultView';
            }
        PluginAssistant = @{
                XPath = '/configuration/citrix.deliveryservices/webReceiver/clientSettings/pluginAssistant';
                Attribute = 'enabled';
            }
        PluginAssistantUpgrade = @{
                XPath = '/configuration/citrix.deliveryservices/webReceiver/clientSettings/pluginAssistant';
                Attribute = 'upgradeAtLogin';
            }
        WorkspaceControl = @{
                XPath = '/configuration/citrix.deliveryservices/webReceiver/clientSettings/userInterface/workspaceControl';
                Attribute = 'enabled';
            }
        AutoReconnectAtLogon = @{
                XPath = '/configuration/citrix.deliveryservices/webReceiver/clientSettings/userInterface/workspaceControl';
                Attribute = 'autoReconnectAtLogon';
            }
        LogOffAction = @{
                XPath = '/configuration/citrix.deliveryservices/webReceiver/clientSettings/userInterface/workspaceControl';
                Attribute = 'logOffAction';
            }
        ShowReconnectButton = @{
                XPath = '/configuration/citrix.deliveryservices/webReceiver/clientSettings/userInterface/workspaceControl';
                Attribute = 'showReconnectButton';
            }
        ShowDisconnectButton = @{
                XPath = '/configuration/citrix.deliveryservices/webReceiver/clientSettings/userInterface/workspaceControl';
                Attribute = 'showDisconnectButton';
            }
        SingleTabLaunch = @{
                XPath = '/configuration/citrix.deliveryservices/webReceiver/clientSettings/pluginAssistant/html5';
                Attribute = 'singleTabLaunch';
            }
        SessionTimeout = @{
                XPath = '/configuration/system.web/sessionState';
                Attribute = 'timeout';
            }
    }

    foreach ($settingsKey in $settings.Keys) {

        if ($PSBoundParameters.ContainsKey($settingsKey)) {

            $xpath = $settings[$settingsKey].XPath;
            $attribute = $settings[$settingsKey].Attribute;
            $value = $PSBoundParameters[$settingsKey].ToString().ToLower();

            Script $attribute {

                GetScript = {

                    $xml = New-Object -TypeName 'System.Xml.XmlDocument';
                    $xml.Load($using:Path);
                    $node = $xml.SelectSingleNode($using:xpath);
                    return @{
                        Result = $node.$using:attribute;
                    }

                }

                TestScript = {

                    $xml = New-Object -TypeName 'System.Xml.XmlDocument';
                    $xml.Load($using:Path);
                    $node = $xml.SelectSingleNode($using:xpath);
                    if ($node.$using:attribute -ne $using:value) {
                        return $false;
                    }
                    else {
                        return $true;
                    }

                }

                SetScript = {

                    $xml = New-Object -TypeName 'System.Xml.XmlDocument';
                    $xml.Load($using:Path);
                    $node = $xml.SelectSingleNode($using:xpath);
                    $node.$using:attribute = $using:value;
                    $xml.Save($using:Path);

                }
            } #end script
        }
    } #end foreach setting

} #end configuration XD7LabStorefrontWebConfig
