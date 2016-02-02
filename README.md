The XenDesktop7Lab composite DSC resources mask some of the underlying implementation/complexities
of the individual [XenDesktop7](https://github.com/VirtualEngine/XenDesktop7) DSC resources.
The composite XenDesktop7Lab resources can be used to deploy Citrix XenDesktop v7.0, v7.1, v7.5, v7.6
or v7.7 via PowerShell Desired State Configuration (DSC).

This module contains the following DSC resources:

###Included Resources
* XD7LabController
 * Adds a controller to an existing XenDesktop site.
* XD7LabDeliveryGroup
 * Creates a desktop group, adds machine(s) and creates access and entitlement policies.
* XD7LabLicenseServer
 * Installs RDS and Citrix licensing server and imports license file.
* XD7LabMachineCatalog
 * Creates a machine catalog and adds machine(s).
* XD7LabSessionHost
 * Installs RDSH, VDA and assigns RDS license server.
* XD7LabSite
 * Configures CredSSP, installs the controller role, creates the XenDesktop site and assigns administrators.
* XD7LabStorefront
 * Installs IIS required roles, Storefront and Director.
* XD7LabStorefrontHttps
 * Installs IIS required roles, certificate and configures Storefront and Director to use HTTPS.

###Requirements
There are __dependencies__ on the following DSC resources:

* XenDesktop7 - https://github.com/VirtualEngine/XenDesktop7
* xCertificate - https://github.com/Powershell/xCertificate
* xCredSSP - https://github.com/Powershell/xCredSSP
* xWebAdministration - https://github.com/Powershell/xWebAdministration
