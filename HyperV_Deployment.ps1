#
# Version: 1.4.0.7
#

function Main-Menu
{
    do
    {
        Clear-Host
        Write-Host "1. HyperV VM Provisioning `n2. VMWare VM Provisioning `n3. Quit`n"
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "1" {$script:hypervisor = "hyperv"
                                 hyperv-menu}
            "2" {$script:hypervisor = "vmware"
                                 vmware-menu}
           
            "3" {exit}
        }
    }
    until (1..3 -contains $menuresponse)
}
function vmhost-menu
{
        $HostGroup = Get-SCVMHostGroup -Name "Internal" -VMMServer "$VMMServerName"
        $HostsInHG = Get-SCVMHost -VMHostGroup $HostGroup
        $HostsInHG | Format-Table -Property Name
}
function vmname-menu
{
   
        Clear-Host
        $script:vmname=read-Host "Enter a name for the new VM "  
        $script:vmdesc= read-host "Enter a description for the new VM "
        $script:vmdiskname = $script:vmname + "_Disk_1"
        hyperv-menu
}

function vmnetwork-menu
{
   
        Clear-Host
        # We list available networks. User enters the network and we get the object and save it into a variable.
        $VMMServerName = "phvmmcit.hvi.brown.edu"
            
        $nets = @(get-scvmnetwork -vmmserver $VMMServerName | where {$_.LogicalNetwork -like "$netstr"} | sort-object -property name | Select-Object -ExpandProperty name)
        $nets = ,"0.0.0.0" + $nets

        $length = $nets.length
        $count = 1
        $index = 0
        Do {
            Write-Host "$count. " $nets[$index];$count+=1;$index+=1
        }
        Until($count -gt $length)
            Write-Host "$count. Return to Main Menu`n"
            $menuresponse = Read-Host [Enter Selection]
        If ($menuresponse -eq $count)
        {
                hyperv-menu
        }

        $count = 1
        $index = 0

        Do {
$count+=1
$index+=1
}
Until ($count -eq $menuresponse)

        $script:vmnetworkname= $nets[$index]  
        $script:vmnetwork = Get-SCVMNetwork -VMMServer $VMMServerName | Where {$_.name -like "$script:vmnetworkname*"}
        
        hyperv-menu
}

function vmram-menu
{
        Clear-Host
        $script:vmram= read-Host "How much RAM in GB "  
        $vmram_num = [int]::Parse($script:vmram)  
        $vmram_num *= 1024
        hyperv-menu
}
function vmcpu-menu
{
   
        Clear-Host
        $script:vmcpu= read-Host "How many CPU "  
        hyperv-menu
}
function vmdisk-menu
{
        Clear-Host
        $script:vmdisk= read-Host "How much Disk in GB"  
        Write-Host "Checking free disk space ...."  

        #$luns = Get-SCStorageVolume -VMHost $vmhostname | where-object {$_.Name -NotMatch "-|11856"} | Select-Object -Property Name, FreeSpace | Sort-Object FreeSpace -Descending  
	$luns = Get-SCStorageVolume -VMHost $vmhostname | where-object {$_.Name -notlike "*11856*" -and $_.Name -notlike "*-p*-d" -and $_.Name -notlike "*-c*-d" -and $_.Name -notlike "*-p*"} | Select-Object -Property Name, FreeSpace | Sort-Object FreeSpace -Descending
        $freespace = $luns[0].FreeSpace
        $vmlun = $luns[0].Name
        $remspace = [math]::round(($luns[0].FreeSpace / 1GB))

        Write-Host "$remspace GB Free"
        if ($remspace -gt $script:vmdisk)
        { 
            Write-Host "There is enough free disk space. Proceeding...`n"
            Write-Host "the vmlun is $vmlun`n"
        }
        else
        {
            Write-Host "There is NOT enough free disk space. Exiting...`n"
            start-sleep -s 5
            exit
        }
        $vmdisk_num = [int]::Parse($script:vmdisk)  
        $vmdisk_num *= 1024
        start-sleep -s 3
        hyperv-menu
}
function Return-ClusterCSVWithMostFreespace($Clstr)
{
        $ClusterInfo = Get-SCVMHostCluster <#-VMMServer $VMMServer#> -Name $Clstr
        $CSVInfo = $ClusterInfo.sharedvolumes | Sort-Object -Property freespace -Descending
        return $CSVInfo[1].mountpoints
}
function printvar-menu
{
   
        Clear-Host
        Write-Host "`n"  
        Write-Host "VM Name:         $script:vmname"
        Write-Host "Prod VM:         $script:vmprod"
        Write-Host "OS:              $script:vmos"
        Write-Host "Cluster:         $script:vmhostcluster"
        Write-Host "Clusterhost:     $vmhostname"
        Write-Host "Net String:      $netstr"
        Write-Host "Backup Tag:      $script:vmtag"
        Write-Output "VM Hypervisor:   $script:hypervisor"
        Write-Output "VM Description:  $script:vmdesc"
        Write-Output "VM Network:      $script:vmnetwork $script:vmnetworkname "
        Write-Output "VM RAM:          $script:vmram"
        Write-Output "VM CPU:          $script:vmcpu"
        Write-Output "VM DISK:         $script:vmdisk GB"
        Write-Output "VM Diskname      $script:vmdiskname"
        Write-host "VM result:       $script:vmresult"
        Write-Host "`n`n"
        pause
        hyperv-menu
}
function vmtag-menu
{       
        Clear-Host
        Write-Host "Select Host Cluster:"
        Write-Host "1. intBackup_2wk `n2. intBackup_4wk  `n3. intBackup_6wk `n4. dmzBackup_2wk `n5. dmzBackup_4wk  `n6. dmzBackup_6wk `n7. dcpodBackup_2wk `n8. dcpodBackup_4wk  `n9. dcpodBackup_6wk `n10. backup_custom `n11. backup_agent  `n12. noBackup`n"
        $tagmenuresponse = read-host [Enter Selection]
        Switch ($tagmenuresponse) {
            "1" {$script:vmtag = "intBackup_2wk" }
            "2" {$script:vmtag = "intBackup_4wk" }
            "3" {$script:vmtag = "intBackup_6wk" }
            "4" {$script:vmtag = "dmzBackup_2wk" }
            "5" {$script:vmtag = "dmzBackup_4wk" }
            "6" {$script:vmtag = "dmzBackup_6wk" }
            "7" {$script:vmtag = "dcpodBackup_2wk" }
            "8" {$script:vmtag = "dcpodBackup_4wk" }
            "9" {$script:vmtag = "dcpodBackup_6wk" }
            "10" {$script:vmtag = "backup_custom" }
            "11" {$script:vmtag = "backup_agent" }
            "12" {$script:vmtag = "noBackup" }
            }

        hyperv-menu
}
function vmware-menu
{
        Write-Host "`nThis functionality is not ready yet. Check back soon!`n" -ForegroundColor Red
        pause
        Main-Menu
}
function hyperv-menu
{
    do
    {
        Clear-Host
        if ($script:vmprod -eq $null) 
        { $script:vmprod= read-Host "Is this a Production VM? ([Y]|N) "
          if($script:vmprod -eq "") { $script:vmprod = "Y" }
  
          $script:vmos= read-Host "Which Operating System? ([Windows]|Linux) "
          if($script:vmos -eq "") { $script:vmos = "Windows" }

        Clear-Host
        $rand_count = 1
        Write-Host "Select Host Cluster:"
        Write-Host "1. HVIC01 (internal) `n2. HVIDMZ01 (dmz) `n3. HVIDCPOD01 (dcpod)`n"
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "1" {$script:vmhostcluster = "hvic01"
                        $HostGroup =  Get-SCVMHost -VMHostGroup Internal | sort-object -property name | Select-Object -ExpandProperty name
                        $vmhostname = Get-Random -InputObject $HostGroup -Count $rand_count
                        Write-Host "Choosing $vmhostname as host to install VM." -ForegroundColor Green
                        sleep -s 3
                        #$vmhostname="hvih07.hvi.brown.edu"
                        $netstr="*Internal*" }
            "2" {$script:vmhostcluster = "hvidmz01"
                        $HostGroup =  Get-SCVMHost -VMHostGroup DMZ | sort-object -property name | Select-Object -ExpandProperty name
                        $vmhostname = Get-Random -InputObject $HostGroup -Count $rand_count
                        Write-Host "Choosing $vmhostname as host to install VM." -ForegroundColor Green
                        sleep -s 3
                        #$vmhostname="hvih11.hvi.brown.edu" 
                        $netstr="*DMZ*"}
            "3" {$script:vmhostcluster = "hvidcpod01"
                        $HostGroup =  Get-SCVMHost -VMHostGroup DCPOD | sort-object -property name | Select-Object -ExpandProperty name
                        $vmhostname = Get-Random -InputObject $HostGroup -Count $rand_count
                        Write-Host "Choosing $vmhostname as host to install VM." -ForegroundColor Green
                        sleep -s 3
                        #$vmhostname="hvih01.hvi.brown.edu" 
                        $netstr="*DCPOD*"  }
            }



               Clear-Host }
        if ($script:vmname -eq $null)
            { Write-Host "1. Enter VM name " } else { Write-Host "1. Enter VM name " -ForegroundColor Green }
        if ($script:vmnetworkname -eq $null)
            { Write-Host "2. Select Network " } else { Write-Host "2. Select Network " -ForegroundColor Green }
        if ($script:vmram -eq $null)
            { Write-Host "3. Select RAM " } else { Write-Host "3. Select RAM " -ForegroundColor Green }
        if ($script:vmcpu -eq $null)
            { Write-Host "4. Select CPU " } else { Write-Host "4. Select CPU " -ForegroundColor Green }
        if ($script:vmdisk -eq $null)
            { Write-Host "5. Select Disk Size " } else { Write-Host "5. Select Disk Size " -ForegroundColor Green }
        if ($script:vmtag -eq $null)
            { Write-Host "6. Select Backup Tag " } else { Write-Host "6. Select Backup Tag " -ForegroundColor Green }
        Write-Host "7. Create VM `n8. Print Parameters `n9. Return to Main Menu`n"
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "1" {vmname-menu}
            "2" {vmnetwork-menu}
            "3" {vmram-menu}
            "4" {vmcpu-menu}
            "5" {vmdisk-menu}
            "6" {vmtag-menu}
            "7" {create-vm}
            "8" {printvar-menu}
            "9" {Main-Menu}
        }
    }
    until (1..9 -contains $menuresponse)
}
function create-vm
{
        if ($script:vmprod -eq "Y") {
            $script:vmmemweight = 5000
            $script:havmpriority = 2000
        }
        else
        {
            $script:vmmemweight = 0
            $script:havmpriority = 1000
        }

        # Get the target ISO file from the VMM library server
        $ISO = Get-SCISO -VMMServer $VMMServerName  | where {$_.Name -eq "SCCMDeployBootImage"}      
        New-SCVirtualScsiAdapter -VMMServer $VMMServerName -JobGroup $script:jobgroup01 -AdapterID 7 -ShareVirtualScsiAdapter $false -ScsiControllerType DefaultTypeNoType
        New-SCVirtualDVDDrive -VMMServer $VMMServerName -JobGroup $JobGroup01 -Bus 0 -LUN 1 #-ISO $ISO -Link        
        New-SCVirtualNetworkAdapter -VMMServer $VMMServerName -JobGroup $JobGroup01 -MACAddressType Dynamic -Synthetic -EnableVMNetworkOptimization $false -EnableMACAddressSpoofing $false -EnableGuestIPNetworkVirtualizationUpdates $false -IPv4AddressType Dynamic -IPv6AddressType Dynamic # -VirtualNetwork $vmnetworkname
        Write-Host "Creating new Hardware profile ..... " -NoNewLine
        New-SCHardwareProfile -VMMServer $VMMServerName  -Name "$script:vmname Temp Profile" -Description "Temp Profile used to create a VM/Template" -CPUCount $script:vmcpu -MemoryMB $vmram_num -DynamicMemoryEnabled $true -DynamicMemoryMinimumMB 32 -DynamicMemoryMaximumMB $vmram_num -DynamicMemoryBufferPercentage 20 -MemoryWeight $script:vmmemweight -CPUExpectedUtilizationPercent 20 -DiskIops 0 -CPUMaximumPercent 100 -CPUReserve 0 -NumaIsolationRequired $false -NetworkUtilizationMbps 0 -CPURelativeWeight 100 -HighlyAvailable $true -HAVMPriority $script:havmpriority -DRProtectionRequired $false -SecureBootEnabled $true -SecureBootTemplate "MicrosoftWindows" -CPULimitFunctionality $false -CPULimitForMigration $true -CheckpointType Production -Generation 2 -JobGroup $JobGroup01 | Out-Null
        Write-Host  "Done"
         
        $JobGroup02 = [System.Guid]::NewGuid().ToString()
        Write-Host "Creating new Virtual Disk drive ..... " -NoNewLine
        New-SCVirtualDiskDrive -VMMServer $VMMServerName -SCSI -Bus 0 -LUN 0 -JobGroup $JobGroup02 -VirtualHardDiskSizeMB $vmdisk_num -CreateDiffDisk $false -Dynamic -Filename $vmdiskname -VolumeType BootAndSystem 
        Write-Host  "Done"
        $HardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServerName | where {$_.Name -eq "$script:vmname Temp Profile"}

        Write-Host "Creating new Virtual Machine Template ..... " -NoNewLine
        New-SCVMTemplate -Name "$script:vmname Temporary Template" -EnableNestedVirtualization $false -Generation 2 -HardwareProfile $HardwareProfile -JobGroup $JobGroup02 -NoCustomization | Out-Null
        Write-Host  "Done"

        $template = Get-SCVMTemplate -All | where { $_.Name -eq "$VMName Temporary Template" }
        $virtualMachineConfiguration = New-SCVMConfiguration -VMTemplate $template -Name $script:vmname
        Write-Output $virtualMachineConfiguration
        
        # bob configure this
        $vmHost = Get-SCVMHost -computername $vmhostname
        Write-Host "Creating Virtual Machine Configuration ..... " -NoNewLine    
        Set-SCVMConfiguration -VMConfiguration $virtualMachineConfiguration -VMHost $vmHost | Out-Null
        Write-Host  "Done"
        Write-Host "Updating Virtual Machine Configuration ..... " -NoNewLine 
        Update-SCVMConfiguration -VMConfiguration $virtualMachineConfiguration | Out-Null
        Write-Host  "Done"
        Write-Host "Setting Virtual Machine Configuration ..... " -NoNewLine 
        Set-SCVMConfiguration -VMConfiguration $virtualMachineConfiguration -VMLocation "$vmlun" -PinVMLocation $true | Out-Null
        Write-Host  "Done"

        $AllNICConfigurations = Get-SCVirtualNetworkAdapterConfiguration -VMConfiguration $virtualMachineConfiguration
        $VHDConfiguration = Get-SCVirtualHardDiskConfiguration -VMConfiguration $virtualMachineConfiguration
        Write-Host "Setting Virtual Hard Disk Configuration ..... " -NoNewLine 
        Set-SCVirtualHardDiskConfiguration -VHDConfiguration $VHDConfiguration -PinSourceLocation $false -PinDestinationLocation $false -PinFileName $false -StorageQoSPolicy $null -DeploymentOption "None" | Out-Null
        Write-Host  "Done"

        Write-Host "Updating Virtual Machine Configuration ..... " -NoNewLine 
        Update-SCVMConfiguration -VMConfiguration $virtualMachineConfiguration | Out-Null
        Write-Host  "Done"

# #$operatingSystem = Get-SCOperatingSystem | where { $_.Name -eq "Windows Server 2019 Standard" }
# #This command builds the new VM
        Write-Host "Building New Virtual Machine  ..... " -NoNewLine 
        New-SCVirtualMachine -Name $script:vmname -VMConfiguration $virtualMachineConfiguration -Description $script:vmdesc -BlockDynamicOptimization $false -JobGroup $JobGroup02 -ReturnImmediately -StartAction "AlwaysAutoTurnOnVM" -StopAction "SaveVM" | Out-Null # -startvm -OperatingSystem $operatingSystem
        Write-Host  "Done"


# Insert the iso file into the virual DVD drive.
if($script:vmos -eq "Windows") {
        Write-Host "Insert the ISO File into the Virtual DVD Drive .... " -NoNewLine
        sleep -s 20
        Get-SCVirtualMachine -name $script:vmname | get-scvirtualdvddrive | set-scvirtualdvddrive -iso $iso -link | Out-Null
        Write-Host "Done"
}
        start-sleep -s 2
# Connect the VMs virtual nic to the requested subnet.
        Write-Host "Connecting VM Virtual NIC to subnet .... " -NoNewLine
        get-scvirtualmachine -name $VMName | get-scvirtualnetworkadapter | set-scvirtualnetworkadapter -VMNetwork $script:vmnetwork | Out-Null
        Write-Host "Done"

#Cleanup the temporary template and hardware profile created earlier...
        Write-Host "Removing temporary Template and Hardware profile .... " -NoNewLine
        Remove-SCVMTemplate -VMTemplate $Template  | Out-Null
        Remove-SCHardwareProfile -HardwareProfile $HardwareProfile | Out-Null
        Write-Host "Done"

#setting the backup tag
        Write-Host "Setting Backup Tag  ..... " -NoNewLine 
        Set-SCVirtualMachine -VM $script:vmname -Tag $script:vmtag | Out-Null
        Write-Host  "Done"
        start-sleep -s 2

#send email
	$html = "<html>"
	$html += "<body><table border=2><tr><th style=padding:10px>VM Name</th><th style=padding:10px>VM Memory</th><th style=padding:10px>VM Network</th>"
	$html += "<th style=padding:10px>VM CPU</th><th style=padding:10px>VM Disk</th><th style=padding:10px>VM Host</th><th style=padding:10px>Backup Tag</th><th style=padding:10px>Prod</th></tr>"
	$html += "<tr><td style=padding:10px>" + $script:vmname + "</td><td style=padding:10px; text-align:center >" + $script:vmram + "</td><td style=padding:10px;text-align:center>" + $script:vmnetwork + "</td>"
	$html += "<td style=padding:10px; text-align:center >" + $script:vmcpu + "</td><td style=padding:10px;text-align:center>" + $script:vmdisk + "</td>"
	$html += "<td style=padding:10px; text-align:center >" + $script:vmhostcluster + "</td><td style=padding:10px;text-align:center>" + $script:vmtag + "</td>"
	$html += "<td style=padding:10px;text-align:center>" + $script:vmprod +"</td>/tr>"
	$html += "</table></body></html>"
	$body =  $html
	Send-MailMessage -From 'HyperV_VM_Creation@brown.edu' -To 'Robert_Morse@brown.edu' -Subject 'HyperV VM Created' -SmtpServer 'mail-relay.brown.edu' -Body "$body" -BodyAsHtml
}
Function Get-MyModule
{
 # Obtained from https://devblogs.microsoft.com/scripting/hey-scripting-guy-weekend-scripter-checking-for-module-dependencies-in-windows-powershell
Param([string]$name)
if(-not(Get-Module -name $name))
{
    if(Get-Module -ListAvailable | Where-Object { $_.name -eq $name })
    {
    Import-Module -Name $name
    $true
    } #end if module available then import
else { $false } #module not available
} # end if not module
else { $true } #module already loaded
} #end function get-MyModule

write-host "Checking to see if the SCVMM powershell module we need is loaded..."
if (get-mymodule -name "virtualmachinemanager") {write-host "The SCVMM module is loaded..." -ForegroundColor Green}
Clear-Variable vm*
$script:jobgroup01 = [System.Guid]::NewGuid().ToString()
#$vmhostname="hvih03.hvi.brown.edu"
$VMMServerName = "phvmmcit.hvi.brown.edu"
start-sleep -s 2

Main-Menu

