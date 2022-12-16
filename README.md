Filename: Cisco_UCS_ESXi_Upgrader_1.0.ps1<br>
Author: Mustafa Hashmi<br>
Limitation of Liability: <br>
You arefully responsible for your use of this script AND I am not liable for damages or losses arising from its use.<br>
<br>
Offline Cisco Custom ESXi Upgrade PowerCLI Script for UCS Automation (no vCenter OR Internet)<br>
<br>
PowerCLI First Time Setup (Install):<br>
Install-Module VMware.PowerCLI -Scope CurrentUser -AllowClobber<br>
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true<br>
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false<br>
<br>
Prep:<br>
Use the ESXi Build Number to determine your source ESXi version:<br>
https://kb.vmware.com/s/article/2143832<br>
<br>
Use Interop Checker to make sure your source version can goto the target version in one-step:<br>
https://interopmatrix.vmware.com/Upgrade<br>
<br>
Download vSphere ESXi ZIP:<br>
vSphere 7.0U3: https://customerconnect.vmware.com/en/downloads/details?downloadGroup=OEM-ESXI70U3-CISCO&productId=974<br>
<br>
Important Step: Upload .zip to a common DataStore accessible by all hosts OR map a local folder (using NFS) <br>
as a datastore using PowerCLI after connecting to the host (can be added to the script below):<br>
New-Datastore -Nfs -Name nfs01 -Path /nfs01 -NfsHost <IP of PC running NFS><br>
