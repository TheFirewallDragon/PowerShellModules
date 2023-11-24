# Module ADCompInfo (Active Directory Computer Information) by Guillaume Carrier Couture, 2224664

# Definition of the function to retrieve the model of a computer
function Get-CompModel {
    <#
    .SYNOPSIS
    Gets the model of a computer (example: HP EliteDesk 800 G3 Desktop).

    .DESCRIPTION
    Gets the model of a computer or a group of computers.

    .PARAMETER Name
    The model of the computer with its name will be returned. By default, it is the local computer.

    .INPUTS
    Takes an array of computer names or AD objects as input via the pipeline.

    .OUTPUTS
    Returns PS objects for the computers passed, including the computer name and model.

    .EXAMPLE
    Get-CompModel -Name 'comp1'

    Returns a PS object with the computer name and the model of 'comp1'.

    .EXAMPLE
    'comp1','comp2' | Get-CompModel
    
    Returns a PS object for each computer containing the computer name and model.
    #>

    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('ComputerName')]
        [string]$Name = $env:COMPUTERNAME
    )

    begin{
        $CompModels = @()  # Initializing a list to store computer models
    }

    process{
        $CompModels += Get-CimInstance -ComputerName $Name -ClassName Win32_ComputerSystem -Property Model | Select-Object -Property @{n='ComputerName';e={$Name}},@{n='Model';e={$_.Model}}
    }

    end{
        return $CompModels  # Returns the list of computer models
    }
}

# Definition of the function to retrieve the processor of a computer
function Get-CompProcessor {
    <#
    .SYNOPSIS
    Gets the processor of a computer (e.g., Intel Core i7-8700K).

    .DESCRIPTION
    Gets the processor of a computer or a group of computers.

    .PARAMETER Name
    The processor of the computer with its name will be returned. By default, it is the local computer.

    .INPUTS
    Takes an array of computer names or AD objects as input via the pipeline.

    .OUTPUTS
    Returns PS objects for the computers passed, including the computer name and processor.

    .EXAMPLE
    Get-CompProcessor -Name 'comp1'

    Returns a PS object with the computer name and the processor of 'comp1'.

    .EXAMPLE
    'comp1','comp2' | Get-CompProcessor
    
    Returns a PS object for each computer containing the computer name and processor.
    #>

    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('ComputerName')]
        [string]$Name = $env:COMPUTERNAME
    )

    begin{
        $CompProcessors = @()  # Initializing a list to store computer processors
    }

    process{
        $CompProcessors += Get-CimInstance -ComputerName $Name -ClassName Win32_Processor -Property Name | Select-Object -Property @{n='ComputerName';e={$Name}},@{n='Processor';e={$_.Name}}
    }

    end{
        return $CompProcessors  # Returns the list of computer processors
    }
}

# Definition of the function to retrieve the memory in GB of a computer
function Get-CompMemory {
    <#
    .SYNOPSIS
    Gets the memory in GB of a computer (e.g., 60 GB).

    .DESCRIPTION
    Gets the memory in GB of a computer or a group of computers.

    .PARAMETER Name
    The memory of the computer with this name will be returned. By default, it is the local computer.

    .INPUTS
    Takes an array of computer names or AD objects as input via the pipeline.

    .OUTPUTS
    Returns PS objects for the computers passed, including the computer name and memory in GB.

    .EXAMPLE
    Get-CompMemory -Name 'comp1'

    Returns a PS object with the computer name and the memory in GB of 'comp1'.

    .EXAMPLE
    'comp1','comp2' | Get-CompMemory
    
    Returns a PS object for each computer containing the computer name and memory in GB.
    #>

    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('ComputerName')]
        [string]$Name = $env:COMPUTERNAME
    )

    begin{
        $CompMemories = @()  # Initializing a list to store computer memories
    }

    process{
        if (Test-Connection -ComputerName $Name -Count 1 -Quiet) {
            Write-Verbose -Message "Connecting to $Name."

            $CompMemories += [PSCustomObject]@{
                ComputerName = $Name
                MemoryGB = [math]::Round(((Get-CimInstance -ComputerName $Name -ClassName Win32_ComputerSystem -Property TotalPhysicalMemory).TotalPhysicalMemory / 1GB), 1)
            }
        } else {
            Write-Verbose -Message "$Name is offline."
        }
    }

    end{
        return $CompMemories  # Returns the list of computer memories
    }
}

# Definition of the function to retrieve information about the hard drives of a computer
function Get-CompHardDrive {
    <#
    .SYNOPSIS
    Gets information about the hard drives of a computer.

    .DESCRIPTION
    Returns information about the hard drives of a computer or a group of computers. Information includes the computer name, drive, size, free space, and whether the drive has less than 25% available space.

    .PARAMETER Name
    Specifies the computer from which the function will gather information.

    .INPUTS
    You can pass host names or AD objects of computers.

    .OUTPUTS
    Returns PS objects to the host with the following information about the hard drives of a computer: ComputerName, DeviceID, SizeGB, FreeSpaceGB, and indicates those with less than 25% available space.

    .NOTES
    Results include mapped drives.

    .EXAMPLE
    Get-CompHardDrive

    Gets information about the drives for the local host.

    .EXAMPLE
    Get-CompHardDrive -Name 'comp1'

    Gets information about the drives for "computer1".

    .EXAMPLE
    Get-ADComputer -Filter * | Get-CompHardDrive

    Gets information about the drives for all computers in AD.
    #>

    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('ComputerName')]
        [string]$Name = $env:COMPUTERNAME
    )

    begin{
        $DriveInfoList = @()  # Initializing a list to store drive information
    }

    process{
        $DriveInfoList += Get-CimInstance -ComputerName $Name -ClassName Win32_LogicalDisk -Property DeviceID,Size,FreeSpace,DriveType | 
            Where-Object -Property DriveType -EQ 3 | 
            Select-Object -Property @{n="ComputerName";e={$Name}},`
            @{n="DeviceID";e={$_.DeviceID}},`
            @{n="SizeGB";e={[math]::Round(($_.Size / 1GB), 1)}},`
            @{n="FreeSpaceGB";e={[math]::Round(($_.FreeSpace / 1GB), 1)}},`
            @{n="LessThan25Percent";e={if(($_.FreeSpace / $_.Size) -le 0.25){"True"}else{"False"}}}
    }

    end{
        $DriveInfoList = $DriveInfoList | Where-Object -Property SizeGB -NE 0
        return $DriveInfoList
    }  
}

# Definition of the function to retrieve the IPv4 address of a computer
function Get-CompIPAddress {
    <#
    .SYNOPSIS
    Gets the IPv4 address of a computer.

    .DESCRIPTION
    Gets the IPv4 address of a computer or computers.

    .PARAMETER Name
    The host name of the target computer.

    .INPUTS
    This function takes an array of host names or AD objects of computers.

    .OUTPUTS
    Returns an array of PS objects with the computer name and IP address.

    .EXAMPLE
    Get-CompIPAddress

    Returns a PS object with the name of the local computer and the IPv4 address.

    .EXAMPLE
    Get-CompIPAddress -Name 'comp1'

    Returns a PS object with the name of the computer 'comp1' and its IPv4 address.
    #>

    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('ComputerName')]
        [string]$Name = $env:COMPUTERNAME
    )

    begin{
        $ComputerIPAddressList = @()  # Initializing a list to store computer IP addresses
    }

    process{
        $ComputerIPAddressList += [PSCustomObject]@{
            ComputerName = $Name
            IPAddress = (Resolve-DnsName -Type A -Name $Name).IPAddress
        }
    }

    end{
        return $ComputerIPAddressList
    }
}

# Definition of the function to get the last startup time of a computer
function Get-CompLastStartup {
    <#
    .SYNOPSIS
    Gets the last time a computer started.

    .DESCRIPTION
    Gets the name and the last startup time of a computer or computers. By default, targets the local computer.

    .PARAMETER Name
    Hostname of the target computer.

    .INPUTS
    Can receive hostnames or AD objects of computers as input.

    .OUTPUTS
    Returns a PS object with the computer name and the last startup time.

    .EXAMPLE
    Get-CompLastStartup

    Returns the last time the local host started.

    .EXAMPLE
    Get-CompLastStartup -Name "comp1"

    Returns the last time the computer "comp1" started.

    .EXAMPLE
    "Comp1","Comp2" | Get-CompLastStartup

    Returns the last startup time for "Comp1" and "Comp2".
    #>

    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [Alias('ComputerName')]
        [string]$Name = $env:COMPUTERNAME
    )

    begin {
        $ListLastStartupTime = @()  # Initialize a list to store startup times
    }

    process {
        $ListLastStartupTime += Get-CimInstance -ComputerName $Name -Class Win32_OperatingSystem -Property LastBootUpTime | 
            Select-Object -Property @{n='Name';e={$_.PSComputerName}}, LastBootUpTime
        # Use Get-CimInstance to retrieve the instance of the Win32_OperatingSystem class containing the last startup time of the computer
        # Use Select-Object to format the results with the names 'Name' and 'LastBootUpTime'
    }

    end {
        return $ListLastStartupTime
    }
}

# Definition of the function to get general information about a computer
function Get-CompInfo {
    <#
    .SYNOPSIS
    Gets general information about a computer.

    .DESCRIPTION
    This function collects information about a computer or computers. By default, it collects information from the local host.

    .PARAMETER Name
    Specifies the name of the computer whose information is collected.

    .INPUTS
    You can pass host names or AD objects of computers.

    .OUTPUTS
    Returns an object with the computer name, model, processor, memory in GB, C drive size in GB, IP address, last startup time, and last login time.

    .NOTES
    Does not return information for offline computers.

    .EXAMPLE
    Get-CompInfo

    Returns information about the local computer.

    .EXAMPLE
    Get-CompInfo -Name "comp1"

    Returns information about the computer "comp1".

    .EXAMPLE
    Get-ADComputer -Filter * | Get-CompInfo

    Returns information about all AD computers.
    #>

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [Alias('ComputerName')]
        [string]$Name = $env:COMPUTERNAME
    )

    begin {
        # Initialize lists
        $Computers = [System.Collections.Generic.List[string]]::new()
        $ListCompInfo = [System.Collections.Generic.List[psobject]]::new()
    }

    process {
        # Add the computer name to the list
        $Computers.Add($Name)
    }

    end {
        # Use the ForEach-Object command to process multiple computers simultaneously
        $Computers | ForEach-Object {
            # Check if the computer is accessible
            if (Test-Connection -ComputerName $_ -Count 1 -Quiet) {
                # Create a PS object with the information retrieved from individual functions
                New-Object -TypeName PSObject -Property @{
                    Name             = $_
                    Model            = (Get-CompModel -Name $_).Model
                    Processor        = (Get-CompProcessor -Name $_).Processor
                    MemoryGB         = (Get-CompMemory -Name $_).MemoryGB
                    CDriveSizeGB     = (Get-CompHardDrive -Name $_ | Where-Object -Property DeviceID -Match 'C').SizeGB
                    IPAddress        = (Get-CompIPAddress -Name $_).IPAddress
                    LastStartup      = (Get-CompLastStartup -Name $_).LastBootUpTime
                }
            }
        } | ForEach-Object {
            # Add each created PS object to the list
            $ListCompInfo.Add($_)
        }

        # Return the final list of information about the computers
        return $ListCompInfo
    }
}
