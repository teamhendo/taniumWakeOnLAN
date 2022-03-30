<#
.SYNOPSIS
This script sends Magic Packets to one or many MAC addresses depending on the $TargetMAC variable. A value of FF:FF:FF:FF:FF:FF sends the packet to all ARP entries that are known
to be in an Incomplete, Stale, or Unreachable state.  Only one machine will be targeted with a Magic Packet broadcast if any other MAC address value is provided.
# LICENSE #
Copyright (C) 2022 - Brent Henderson
This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
#>

[cmdletbinding()]
param([string] $TargetMAC)

#Requires -Version 3.0

# Script directory preamble

if (Test-Path -LiteralPath 'variable:HostInvocation') { 
     $InvocationInfo = $HostInvocation 
     [string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent
} 
else { 
     $InvocationInfo = $MyInvocation 
     [string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent
}

# Decode encoded string passed via Tanium Package 

$TargetMAC = [System.Uri]::UnescapeDataString("$TargetMAC")

Write-Output "Received $TargetMAC as parameter input."

# Dot-source Send-Packet prerequisite and validate that it is present

. "$scriptDirectory\Send-Packet.ps1"

if ([bool]$(Get-Command -Name Send-Packet) -eq $false) 
{
     Write-Output 'Send-Packet is a mandatory prerequisite and was not detected.  Please ensure that the Send-Packet.ps1 file is included in the Tanium Package.'
     
     exit
}

# Send Magic Packets to different audiences depending on the value of $TargetMAC

if ($TargetMAC -eq 'FFFFFFFFFFFF') {
     # Gathering inactive entries from within the ARP cache
     
     $netNeighbors = Get-NetNeighbor -AddressFamily IPv4 -State Incomplete,Stale,Unreachable | `
                         Where-Object {$null -ne $_.LinkLayerAddress -and '' -ne $_.LinkLayerAddress} | `
                         Select-Object -Property LinkLayerAddress -Unique 

     foreach ($neighbor in $netNeighbors) {
          $intRandomSleep = Get-Random -Minimum 5 -Maximum 15

          Write-Output "Sleeping for $intRandomSleep seconds."
          
          Start-Sleep -Seconds $intRandomSleep

          Write-Output "Sending Magic Packet to $($neighbor.LinkLayerAddress)."

          Send-Packet -MacAddress "$($neighbor.LinkLayerAddress)"
     }
}
else 
{
     Send-Packet -MacAddress "$TargetMAC"
}