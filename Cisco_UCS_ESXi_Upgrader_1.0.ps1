<#	
Filename: Cisco_UCS_ESXi_Upgrader_1.0.ps1
Author: Mustafa Hashmi
Limitation of Liability: 
You are fully responsible for your use of this script AND I am not liable for damages or losses arising from its use.

Offline Cisco Custom ESXi Upgrade PowerCLI Script for UCS Automation (no vCenter, Internet or SSH required)

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

PLEASE NOTE:
INCREASE THE START-SLEEP TIMER (60s DEFAULT) IF YOU HAVE MANY VMs TO TURN OFF, OTHERWISE MAINT. MODE WILL NOT TURN ON.
POST UPGRADE REBOOT, EACH HOST WILL REMAIN IN MAINTANENCE MODE UNIT YOU TURN IT OFF.
LASTLY MAKE SURE THE HostList.csv HAS CORRECT IP & CREDENTIALS !!!!

Good Luck!
#>

#Start of Script
clear
Write-Host "Starting Upgrade. Ensure a new log window has opened.`n" | Out-File output_log.txt
start-process powershell -ArgumentList "Get-Content .\output_log.txt -wait" 
pause

#Get Host Credentials
$HostCount = 0
$Hosts = import-csv -Path ".\HostList.csv" | ForEach-Object {

                $IP = $_.IPAddress
                $Username = $_.User
                $Pswd = $_.Password
                
                # Connect to Host
                Write-Host "Connecting to ESXi Host:"$IP
                Connect-VIServer -Server $IP -Protocol https -User $Username -Password $Pswd
              
                 # Shutdown VMs & turn of Maint. Mode
                $poweredonvmcount = 0
                $poweredonvmcount = (get-vm | where {$_.powerstate -eq 'PoweredOn'}).count
                                             
                if($poweredonvmcount -eq 0) {
                    Write-Host "Turning on Maintance Mode."
                    set-vmhost -state Maintenance
                    Start-Sleep 5
                    }        
                else {
                    Write-Host "Shutting down"$poweredonvmcount" VMs, and waiting 60s."
                    $vm = Get-VM
                    $vm | Where {($_.Guest.State -eq "Running") -AND ($_.powerstate -eq ‘PoweredOn’)} | Shutdown-VMGuest -Confirm:$false
                    $vm | Where {($_.Guest.State -eq "NotRunning") -AND ($_.powerstate -eq ‘PoweredOn’)} | Stop-VM -Confirm:$false 
                    Start-Sleep 60
                    $poweredonvmcount = (get-vm | where {$_.powerstate -eq 'PoweredOn'}).count
                    if($poweredonvmcount -eq 0) {
                        Write-Host "Turning on Maintance Mode."
                        set-vmhost -state Maintenance
                        Start-Sleep 5
                    }
                    else { 
                        Write-Host "Error!"$poweredonvmcount" VMs are still Powered On. Turn OFF manually via UI and only then"
                        pause
                        Write-Host "Re-trying Maintance Mode activation."
                        set-vmhost -state Maintenance
                        Start-Sleep 5
                        }
                    }
                
                # Run Upggrade Command
                Write-Host "ESXi upgrade in progress...please wait."
                $esxcli = Get-EsxCli -V2
                $arguments = $esxcli.software.profile.install.CreateArgs()
                $arguments.depot = "/vmfs/volumes/Common_Datastore/VMWare/VMware-ESXi-7.0.3d-19482537-Custom-Cisco-4.2.2-a-depot.zip"
                #NoHardwareWarning is only supported for ESXi 6.7 onwards, remove/comment for 6.5 and prior source versions
                $arguments.nohardwarewarning = $true
                $arguments.profile = "Cisco-UCS-Addon-ESXi-70U3d-19482537_4.2.2-a"
                $arguments.oktoremove = $true
                $esxcli.software.profile.install.Invoke($arguments)
                
                # Reboot, disconnect session and move on to next Host
                Write-Host "Upgrade Complete, if there are errors ABORT using CTRL-C OR to REBOOT this server and move on to the next"
                pause
                Restart-VMHost -Confirm:$false | Disconnect-VIServer -Confirm:$false
                $HostCount++
                Write-Host
                Write-Host

    } | Out-File output_log.txt -append

Write-Host $HostCount" Hosts Upgraded Successfully. Exiting Script."
$HostCount = 0

#End of Script
