<#	
Filename: Cisco_UCS_ESXi_Upgrader_1.0.ps1
Author: Mustafa Hashmi
Limitation of Liability: 
You are fully responsible for your use of this script AND am not liable for damages or losses arising from its use.

Offline Cisco Custom ESXi Upgrade PowerCLI Script for UCS Automation (no vCenter OR Internet)

PowerCLI First Time Setup (Install):
Install-Module VMware.PowerCLI -Scope CurrentUser -AllowClobber
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

Prep:
Use the ESXi Build Number to determine your source ESXi version:
https://kb.vmware.com/s/article/2143832

Use Interop Checker to make sure your source version can goto the target version in one-step:
https://interopmatrix.vmware.com/Upgrade

Download vSphere ESXi ZIP:
vSphere 7.0U3: https://customerconnect.vmware.com/en/downloads/details?downloadGroup=OEM-ESXI70U3-CISCO&productId=974

Important Step: Upload .zip to a common DataStore accessible by all hosts OR map a local folder (using NFS) 
as a datastore using PowerCLI after connecting to the host (can be added to the script below above esxcli section):
New-Datastore -Nfs -Name nfs01 -Path /nfs01 -NfsHost <IP of PC running NFS>
#>

#Start of Script

#Get Host Credentials
$Hosts = import-csv -Path ".\HostList.csv" | ForEach-Object {

        $IP = $_.IPAddress
        $Username = $_.User
        $Pswd = $_.Password
 
                #Connect to ESXi Host using credentials      
                Connect-VIServer -Server $IP -Protocol https -User $Username -Password $Pswd

                #Shutdown VMs Gracefully if VMTools is Running OR PowerOff if no VMTools
                $vm = Get-VM
                $vm | Where {($_.Guest.State -eq "Running") -AND ($_.powerstate -eq ‘PoweredOn’)} | Shutdown-VMGuest -Confirm:$false
                $vm | Where-Object {($_.Guest.State -eq "NotRunning") -AND ($_.powerstate -eq ‘PoweredOn’)} | Stop-VM -Confirm:$false 
                Write-Host "If you see errors you may need to turn OFF manually using the ESXi UI."
                pause

                # Turn on Maint. Mode
                set-vmhost -state Maintenance

                #Setup ESXCli command for Upgrade using Cisco Profile in Zip, removing old pkgs, ignoring hardware warning
                $esxcli = Get-EsxCli -V2
                $arguments = $esxcli.software.profile.install.CreateArgs()
                $arguments.depot = "/vmfs/volumes/RCDN_ISO_Datastore/VMWare/VMware-ESXi-7.0.3d-19482537-Custom-Cisco-4.2.2-a-depot.zip"
                $arguments.nohardwarewarning = $true
                $arguments.profile = "Cisco-UCS-Addon-ESXi-70U3d-19482537_4.2.2-a"
                $arguments.oktoremove = $true
                $esxcli.software.profile.install.Invoke($arguments)

                #Restarting Host and Ending PowerCli Session to current host
                Restart-VMHost -Confirm:$false | Disconnect-VIServer -Confirm:$false
                Write-Host "If upgrade failed ABORT using CTRL-C or"
                pause
    }

#End of Script
