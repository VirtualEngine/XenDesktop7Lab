@{
    ModuleVersion = '2.4.5';
    RootModule = 'XenDesktop7Lab.psm1';
    GUID = '1b0a8b41-8590-4e46-b828-01157fb7eec9';
    Author = 'Iain Brighton';
    CompanyName = 'Virtual Engine';
    Copyright = '(c) 2016 Virtual Engine Limited. All rights reserved.';
    Description = 'Citrix XenDesktop 7 Lab DSC Composite Resources.';
    PowerShellVersion = '4.0';
    CLRVersion = '4.0';
    RequiredModules = @('XenDesktop7', 'xCredSSP');
    PrivateData = @{
        PSData = @{  # Private data to pass to the module specified in RootModule/ModuleToProcess
            Tags = @('VirtualEngine','Citrix','XenDesktop','XenApp','Composite','DSC');
            LicenseUri = 'https://github.com/VirtualEngine/XenDesktop7Lab/blob/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/XenDesktop7Lab';
            IconUri = 'https://raw.githubusercontent.com/VirtualEngine/XenDesktop7Lab/master/CitrixReceiver.png';
        } # End of PSData hashtable
    } # End of PrivateData hashtable

}
