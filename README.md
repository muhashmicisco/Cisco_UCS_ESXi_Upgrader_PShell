<b>Offline Cisco Custom ESXi Upgrade PowerCLI Script for UCS Automation (no vCenter, Internet or SSH required)<br></b><br>
Filename: Cisco_UCS_ESXi_Upgrader_1.0.ps1<br>
Author: Mustafa Hashmi<br>
Limitation of Liability: <br>
You are fully responsible for your use of this script AND am not liable for damages or losses arising from its use.<br>
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
Remember to update the Profile name in the script (which can be found under update.zip\metadata.zip\profiles without the "NUMBER").<br><br>
Important Step: Upload .zip to a common DataStore accessible by all hosts OR map a local folder (using NFS) <br>
as a datastore using PowerCLI after connecting to the host (can be added to the script above the esxcli section):<br>
New-Datastore -Nfs -Name nfs01 -Path /nfs01 -NfsHost [IP of PC running NFS]<br>
<br>
PLEASE NOTE:<br>
INCREASE THE START-SLEEP TIMER (60s DEFAULT) IF YOU HAVE MANY VMs TO TURN OFF, OTHERWISE MAINT. MODE WILL NOT TURN ON.<br>
POST UPGRADE REBOOT, EACH HOST WILL REMAIN IN MAINTANENCE MODE UNIT YOU TURN IT OFF.<br>
LASTLY MAKE SURE THE CSV HAS CORRECT IPs & CREDENTIALS !!!!<br>
<br>
Good Luck!<br>
<br>
Sample Output from PowerShell Console:<br>
![image](https://user-images.githubusercontent.com/85717393/209022229-5c7e32d6-8e66-45c5-bd4f-733fdaf4ffa0.png)

Sample Output from Log file:
![image](https://user-images.githubusercontent.com/85717393/209022299-ade896bb-e5ee-46f9-b281-f6636211a53a.png)
