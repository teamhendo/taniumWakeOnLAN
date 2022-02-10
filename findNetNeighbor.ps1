<#
.SYNOPSIS
	This script is intended to be utilized with the Tanium platform. The script validates whether or not a given MAC address is found within the endpoint's ARP cache and
    returns a boolean value indicating as such.
	# LICENSE #
	Copyright (C) 2022 - Brent Henderson
	This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
	You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
#>

$LinkLayerAddress = $([System.Uri]::UnescapeDataString('||MAC_Address||'))

if ($LinkLayerAddress -eq '||$MAC_Address||'){
    Write-Output 'Unescape Failure'
    exit
}
else {
    if ([bool]$(Get-NetNeighbor | Where-Object {$_.LinkLayerAddress -match "$LinkLayerAddress"})) {
    return $true
} 
else {
    return $false
}

}

exit