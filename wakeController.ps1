<#
.SYNOPSIS
This script sends Magic Packets to one or many MAC addresses depending on the $TargetMAC variable. 
A value of FF:FF:FF:FF:FF:FF sends the packet to all ARP entries that are known to be in an Incomplete, Stale, or Unreachable state.  
Only one machine will be targeted with a Magic Packet broadcast if any other MAC address value is provided.
# LICENSE #
Copyright (C) 2024 - Brent Henderson
This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
#>

[cmdletbinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TargetMAC
)

# Requires -Version 3.0

# Define script directory using $PSScriptRoot
$scriptDirectory = $PSScriptRoot

Write-Output "Received $TargetMAC as parameter input."

# Load Send-Packet.ps1 script, ensure it exists
$sendPacketPath = Join-Path $scriptDirectory "Send-Packet.ps1"

# Validate the existence of Send-Packet.ps1
if (-not [System.IO.File]::Exists($sendPacketPath)) {
    throw 'Send-Packet.ps1 not found in the script directory.'
}

# Load Send-Packet function
. $sendPacketPath

# Validate the existence of Send-Packet function
if (-not (Get-Command -Name Send-Packet -ErrorAction SilentlyContinue)) {
    throw 'Send-Packet function is not available.'
}

# Send Magic Packets to different audiences depending on the value of $TargetMAC
if ($TargetMAC -eq 'FF:FF:FF:FF:FF:FF' -or $TargetMAC -eq 'FFFFFFFFFFFF') {
    # Gather inactive ARP cache entries
    $netNeighbors = Get-NetNeighbor -AddressFamily IPv4 -State Incomplete,Stale,Unreachable |
                     Where-Object { $_.LinkLayerAddress -and $_.LinkLayerAddress.Trim() } |
                     Select-Object -Property LinkLayerAddress -Unique

    if ($netNeighbors.Count -eq 0) {
        Write-Warning "No inactive ARP entries found."
    }

    foreach ($neighbor in $netNeighbors) {
        $intRandomSleep = Get-Random -Minimum 5 -Maximum 15
        Write-Host "Sleeping for $intRandomSleep seconds."
        Start-Sleep -Seconds $intRandomSleep
        Write-Host "Sending Magic Packet to $($neighbor.LinkLayerAddress)."
        Send-Packet -MacAddress $neighbor.LinkLayerAddress
    }
} else {
    Write-Host "Sending Magic Packet to $TargetMAC."
    Send-Packet -MacAddress $TargetMAC
}
