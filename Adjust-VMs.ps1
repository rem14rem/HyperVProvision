#
#
# Version 1.0.5
#
#
If ((test-path -Path $args[0]))
{
Import-Module virtualmachinemanager

get-scvmmserver -ComputerName phvmmcit.hvi.brown.edu | out-null

$filepath = $args[0]

$Targets = import-csv -Path $filepath -Delimiter "," -header "Name", "cluster", "tag"

ForEach ($Target in $Targets)
{
    if ($Target.name  -like "#*") {
        $aa = $Target.name -replace "#",''
	Write-Host $aa "Machine not ready for adustment. Skipping.`n"-ForegroundColor Yellow
	continue
    }
	$VM = Get-SCVirtualMachine -name $Target.name
	if ($VM.Status -ne "PowerOff") {
        	Write-host $Target.name "Shutting down VM."
                Get-SCVirtualMachine -name $Target.name | Stop-SCVirtualMachine | out-null
                sleep -s 5
        } else {
		Write-host $Target.name "Already powered off." -ForegroundColor Yellow
	}

	#region Convert Disks (VHD to VHDX)
        Write-Host $vm.Name "Verifying disk type..."
        $vDiskDrives = Get-SCVirtualDiskDrive -VM $VM
        foreach ($vDiskDrive in $vDiskDrives) {
             if ($vDiskDrive.VirtualHardDisk.VHDFormatType -eq "VHD") {
                        Write-Host $VM.name "Converting disks to VHDX format..."
                        $vDiskName = $vDiskDrive.VirtualHardDisk.Name
			$vDiskId = $vDiskDrive.ID
			$vDiskBusType = $vDiskDrive.BusType
			$vDiskBus = $vDiskDrive.Bus
			$vDiskLun = $vDiskdrive.Lun

			Write-Host "Converting disk $($vDiskName) to VHDX..."
			#Convert-SCVirtualDiskDrive -VirtualDiskDrive $vDiskDrive -VHDX -RunAsynchronously | Out-Null
			Convert-SCVirtualDiskDrive -VirtualDiskDrive $vDiskDrive -VHDX -DeleteSource -RunAsynchronously | Out-Null
			$vmmJob = Get-SCJob -VMMServer $VMMServer | where-object { ($_.CmdletName -eq "Convert-SCVirtualDiskDrive") -and `
			($_.Status -eq "running") -and `
			($_.Owner -eq [System.Security.Principal.WindowsIdentity]::GetCurrent().Name) } | Select-Object -Property ID

			if ([string]::IsNullOrEmpty($vmmJob)) {
			Write-Host "No Running jobs."
			Exit
			}

			While ((Get-SCJob -ID $vmmJob.ID).Status -eq 'Running') {
			$progress = (Get-SCJob -ID $vmmJob.ID).Progress
			$progressVal = (Get-SCJob -ID $vmmJob.ID).ProgressValue
			Write-Progress -Activity "Converting Disk: $vdiskName" -Status "Complete: $progress"
			Start-Sleep -Seconds 1
			}
			Write-Progress -Activity "Converting Disk: $vdiskName" -Status "Complete: $progress" -Completed
			# Set the disk properties
			$vitrualDiskDrive = Get-SCVirtualDiskDrive -VM $vm | ? { $_.ID -eq $vDiskId }
			if ($vDiskBusType -eq "IDE") {
				Set-SCVirtualDiskDrive -VirtualDiskDrive $vitrualDiskDrive -Bus $vDiskBus -LUN $vDiskLun -VolumeType None -IDE -IOPSMaximum 0 | Out-Null
			} else {
				Set-SCVirtualDiskDrive -VirtualDiskDrive $vitrualDiskDrive -Bus $vDiskBus -LUN $vDiskLun -VolumeType None -SCSI -IOPSMaximum 0 | Out-Null
			}
		} else {
			Write-Host $vm.Name "No conversion needed for $($vDiskName)"
		}
	}
	Write-Host "Disk conversion complete."




#region Set Dynamic Memory

Write-Host $VM.name "Setting Dynamic Memory"

Switch ($VM.memory){

"1024" {Set-SCVirtualMachine -VM $VM -DynamicMemoryEnabled $True -MemoryMB 1024 -DynamicMemoryMinimumMB 512 -DynamicMemoryBufferPercentage 20 -DynamicMemoryMaximumMB 2048 | Out-Null}

"2048" {Set-SCVirtualMachine -VM $VM -DynamicMemoryEnabled $True -MemoryMB 1024 -DynamicMemoryMinimumMB 512 -DynamicMemoryBufferPercentage 20 -DynamicMemoryMaximumMB 2048 | Out-Null}

"3072" {Set-SCVirtualMachine -VM $VM -DynamicMemoryEnabled $True -MemoryMB 1024 -DynamicMemoryMinimumMB 512 -DynamicMemoryBufferPercentage 20 -DynamicMemoryMaximumMB 3072 | Out-Null}

"4096" {Set-SCVirtualMachine -VM $VM -DynamicMemoryEnabled $True -MemoryMB 2048 -DynamicMemoryMinimumMB 512 -DynamicMemoryBufferPercentage 20 -DynamicMemoryMaximumMB 4096 | Out-Null}

"6122" {Set-SCVirtualMachine -VM $VM -DynamicMemoryEnabled $True -MemoryMB 3072 -DynamicMemoryMinimumMB 512 -DynamicMemoryBufferPercentage 20 -DynamicMemoryMaximumMB 6122 | Out-Null}

"8192" {Set-SCVirtualMachine -VM $VM -DynamicMemoryEnabled $True -MemoryMB 4096 -DynamicMemoryMinimumMB 512 -DynamicMemoryBufferPercentage 20 -DynamicMemoryMaximumMB 8192 | Out-Null}

"12288"{Set-SCVirtualMachine -VM $VM -DynamicMemoryEnabled $True -MemoryMB 6144 -DynamicMemoryMinimumMB 512 -DynamicMemoryBufferPercentage 20 -DynamicMemoryMaximumMB 12288 | Out-Null}

"16384"{Set-SCVirtualMachine -VM $VM -DynamicMemoryEnabled $True -MemoryMB 8192 -DynamicMemoryMinimumMB 512 -DynamicMemoryBufferPercentage 20 -DynamicMemoryMaximumMB 16384 | Out-Null}

"32768" {Set-SCVirtualMachine -VM $VM -DynamicMemoryEnabled $True -MemoryMB 8192 -DynamicMemoryMinimumMB 512 -DynamicMemoryBufferPercentage 20 -DynamicMemoryMaximumMB 32768 | Out-Null}

"40960" {Set-SCVirtualMachine -VM $VM -DynamicMemoryEnabled $True -MemoryMB 8192 -DynamicMemoryMinimumMB 512 -DynamicMemoryBufferPercentage 20 -DynamicMemoryMaximumMB 40960 | Out-Null}

"51200" {Set-SCVirtualMachine -VM $VM -DynamicMemoryEnabled $True -MemoryMB 8192 -DynamicMemoryMinimumMB 512 -DynamicMemoryBufferPercentage 20 -DynamicMemoryMaximumMB 51200 | Out-Null}


Default {write-host $VM.name "No Memory Value Matches. Setting Max Memory to 8gb"-ForegroundColor Yellow
	Set-SCVirtualMachine -VM $VM -DynamicMemoryEnabled $True -MemoryMB 8192 -DynamicMemoryMinimumMB 512 -DynamicMemoryBufferPercentage 20 -DynamicMemoryMaximumMB 8192 | Out-Null }

}


#endregion

#region Linux MAC setting

#if ($vm.operatingsystem -like "Windows*"){Write-Host $VM.name "OS is Windows, no MAC adjustment necessary"}
#Else
#{


$Adapters = Get-SCVirtualNetworkAdapter -VM $VM
$length = $Adapters.length
sleep -s 10
$count = 1
$index = 0
While ($count -le $length) {
	Write-Host $VM "Setting $Adapters[$index].SlotId to Static"
	Set-SCVirtualNetworkAdapter -VirtualNetworkAdapter $Adapters[$index] -MACAddressType "Static" | Out-Null
	$count+=1;$index+=1
}

sleep -s 5

Write-Host $VM.name "MAC address set to static"
#}

sleep 3
#endregion

#region HA
# Check and Fix HA
Write-Host $VM.name "Checking HA configuration." 
if ($VM.IsHighlyAvailable -eq $False) {
	Write-Host $VM.Name "HA not enabled"  -ForegroundColor Yellow
	Write-Host $VM.name "Enabling HA" 
	get-cluster -name $target.cluster | Add-ClusterVirtualMachineRole -virtualmachine $VM.Name -Name "SCVMM $VMname Resources" | Out-Null
	get-scvirtualmachine -name $VM.Name | read-scvirtualmachine | Out-Null
	$VM = Get-SCVirtualMachine -Name $VM.Name
	If ($VM.IsHighlyAvailable -eq $True){Write-Host "Operation successful..." -ForegroundColor green}
	else {Write-Host "Operation NOT successful..." -ForegroundColor Yellow}
} elseif ($VM.IsHighlyAvailable -eq "True") {
	Write-host $VM.name "is already Highly Available..." -foregroundcolor Green
}
Write-Host
#endregion HA

	#region Set VM QOS
	$NonProdMemWeight = 0
	$NonProdHAPriority = 1000
	$ProdMemWeight = 5000
	$ProdHAPriority = 2000



	if ($VM.MemoryWeight -eq $ProdMemWeight -and $VM.HAVMPriority -eq $ProdHAPriority){
		Write-Host $VM.name "memory settings OK no changes needed."}
	else {
		Write-Host $VM.name "Incorrect memory settings found, making adjustments."
		Set-SCVirtualMachine -VM $VM.name  -MemoryWeight $ProdMemWeight -HAVMPriority $ProdHAPriority | Out-Null
		Write-Host $VM.name "Memory and HA priority set to production server settings."
	}
#endregion
#
#region CPU
#Check and Fix CPU Compatibility
#
	Write-Host $VM.name "VM CPU compatibility check..." 
	if ($VM.limitcpuformigration -eq $false -and $VM.Status -eq "PowerOFF") {
		$VMName =$VM.name 
		Write-Host "$VMName CPU compatibility not set..." -ForegroundColor Yellow
		Write-Host "$VMName is powered OFF..." -ForegroundColor Yellow
		Write-Host "$VMName Setting CPU compatibility..."
		set-scvirtualmachine -VM $VMName -cpulimitformigration $true | out-null
		$VM = get-scvirtualmachine -name $VMName
		if ($VM.limitcpuformigration -eq $True) {Write-Host "$VMName Operation successful..." -foregroundcolor Green}
		Else {Write-Host "$VMName Operation NOT successful..." -foregroundcolor red} 
	} elseif ($VM.limitcpuformigration -eq $false -and $VM.Status -ne "PowerOFF") {
		Write-Host "$VMName CPU compatibility Cannot be set while the VM is powered ON." -ForegroundColor Yellow
		Write-Host "$VMName Please PowerOFF the VM and re-run this script to set CPU Compatibility... " -ForegroundColor Yellow
	} elseif ($VM.limitcpuformigration -eq $true) {
		Write-Host "$VMName CPU compatibility already set. No Action Necessary." -ForegroundColor Green
	} 
#endregion CPU

	#region Set Backup Tag

	Write-Host $VM.name "Setting backup tag and StartAction..."
	get-scvirtualmachine -name $target.name | Set-SCVirtualMachine -StartAction AlwaysAutoTurnOnVM  -Tag $Target.tag | Out-Null
	Write-Host $target.name "Done setting backup tag and StartAction."
	Write-Host $target.name "Starting VM"
	Get-SCVirtualMachine -name $Target.name | Start-SCVirtualMachine | out-null
	Write-Host
	#endregion Set Backup Tag
	} 
}      
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Write-Host
