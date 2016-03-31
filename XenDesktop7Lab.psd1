@{
    ModuleVersion = '2.3.2';
    RootModule = 'XenDesktop7Lab.psm1';
    GUID = '1b0a8b41-8590-4e46-b828-01157fb7eec9';
    Author = 'Iain Brighton';
    CompanyName = 'Virtual Engine';
    Copyright = '(c) 2016 Virtual Engine Limited. All rights reserved.';
    Description = 'Citrix XenDesktop 7 Lab DSC Composite Resources.';
    PowerShellVersion = '4.0';
    CLRVersion = '4.0';
    DscResourcesToExport = @('XD7LabAdministrator', 'XD7LabApplication', 'XD7LabController', 'XD7LabDeliveryGroup',
                                'XD7LabLicenseServer', 'XD7LabMachineCatalog', 'XD7LabSessionHost', 'XD7LabSimple',
                                'XD7LabSimpleHttps', 'XD7LabSite', 'XD7LabStorefront', 'XD7LabStorefrontHttps',
                                'XD7LabStorefrontRedirect', 'XD7LabStorefrontUrl');
    PrivateData = @{
        PSData = @{  # Private data to pass to the module specified in RootModule/ModuleToProcess
            Tags = @('VirtualEngine','Citrix','XenDesktop','Composite','DSC');
            LicenseUri = 'https://github.com/VirtualEngine/XenDesktop7Lab/blob/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/XenDesktop7Lab';
            IconUri = 'https://raw.githubusercontent.com/VirtualEngine/XenDesktop7Lab/master/CitrixReceiver.png';
        } # End of PSData hashtable
    } # End of PrivateData hashtable

}
