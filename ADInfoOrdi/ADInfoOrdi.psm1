<#
______   ________  ____   ____   ___   _____  _______      
|_   _ `.|_   __  ||_  _| |_  _|.'   `.|_   _||_   __ \     
  | | `. \ | |_ \_|  \ \   / / /  .-.  \ | |    | |__) |    
  | |  | | |  _| _    \ \ / /  | |   | | | |    |  __ /     
 _| |_.' /_| |__/ |    \ ' /   \  `-'  /_| |_  _| |  \ \_   
|______.'|________|     \_/     `.___.'|_____||____| |___|  
   ______  _______   _    _    ______    __    ________     
 .' ___  ||_   __ \ | |  | |  / ____ `. /  |  |_   __  |    
/ .'   \_|  | |__) || |__| |_ `'  __) | `| |    | |_ \_|    
| |         |  __ / |____   _|_  |__ '.  | |    |  _| _     
\ `.___.'\ _| |  \ \_   _| |_| \____) | _| |_  _| |__/ |    
 `.____ .'|____| |___| |_____|\______.'|_____||________|   
#>

<#
      .o.       oooooooooo.   ooooo              .o88o.             .oooooo.                  .o8   o8o  
     .888.      `888'   `Y8b  `888'              888 `"            d8P'  `Y8b                "888   `"'  
    .8"888.      888      888  888  ooo. .oo.   o888oo   .ooooo.  888      888 oooo d8b  .oooo888  oooo  
   .8' `888.     888      888  888  `888P"Y88b   888    d88' `88b 888      888 `888""8P d88' `888  `888  
  .88ooo8888.    888      888  888   888   888   888    888   888 888      888  888     888   888   888  
 .8'     `888.   888     d88'  888   888   888   888    888   888 `88b    d88'  888     888   888   888  
o88o     o8888o o888bood8P'   o888o o888o o888o o888o   `Y8bod8P'  `Y8bood8P'  d888b    `Y8bod88P" o888o 
#>

# Module ADInfoOrdi (Active Directory Information Ordinateur) par Guillaume Carrier Couture, 2224664

# Definition de la fonction pour obtenir le modele d'un ordinateur
function Get-ModeleOrdi {
    <#
    .SYNOPSIS
    Obtient le modele d'un ordinateur (exemple: HP EliteDesk 800 G3 Desktop).

    .DESCRIPTION
    Obtient le modele d'un ordinateur ou d'un groupe d'ordinateurs.

    .PARAMETER Nom
    Le modele de l'ordinateur avec son nom sera retourne. Par defaut, il s'agit de l'ordinateur local.

    .INPUTS
    Prend un tableau de noms d'ordinateurs ou d'objets AD en entree via le pipeline.

    .OUTPUTS
    Renvoie des objets PS pour les ordinateurs qui sont passes, incluant le nom de l'ordinateur et le modele.

    .EXAMPLE
    Get-ModeleOrdi -Nom 'ordi1'

    Renvoie un objet PS avec le nom de l'ordinateur et le modele de 'ordi1'.

    .EXAMPLE
    'ordi1','ordi2' | Get-ModeleOrdi
    
    Renvoie un objet PS pour chaque ordinateur contenant le nom de l'ordinateur et le modele.
    #>

    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('NomOrdinateur')]
        [string]$Nom = $env:COMPUTERNAME
    )

    begin{
        $ModelesOrdi = @()  # Initialisation d'une liste pour stocker les modeles d'ordinateurs
    }

    process{
        $ModelesOrdi += Get-CimInstance -ComputerName $Nom -ClassName Win32_ComputerSystem -Property Model | Select-Object -Property @{n='Nom';e={$Nom}},@{n='Modele';e={$_.Model}}
        # Utilisation de Get-CimInstance pour recuperer l'instance de la classe Win32_ComputerSystem contenant le modele de l'ordinateur
        # La propriete Select-Object est utilisee pour formater les resultats avec les noms 'Nom' et 'Modele'
    }

    end{
        return $ModelesOrdi  # Renvoie la liste des modeles d'ordinateurs
    }
}

# Definition de la fonction pour obtenir le processeur d'un ordinateur
function Get-ProcesseurOrdi {
    <#
    .SYNOPSIS
    Obtient le processeur d'un ordinateur(ex: Intel Core i7-8700K).

    .DESCRIPTION
    Obtient le processeur d'un ordinateur ou d'un groupe d'ordinateurs.

    .PARAMETER Name
    Le processeur de l'ordinateur avec son nom sera retourne. Par defaut, il s'agit de l'ordinateur local.

    .INPUTS
    Prend un tableau de noms d'ordinateurs ou d'objets AD en entree via le pipeline.

    .OUTPUTS
    Renvoie des objets PS pour les ordinateurs qui lui sont passes, comprenant le nom de l'ordinateur et le processeur.

    .EXAMPLE
    Get-ProcesseurOrdi -Nom 'ordi1'

    Renvoie un objet PS avec le nom de l'ordinateur et le processeur de 'ordi1'.

    .EXAMPLE
    'ordi1','ordi2' | Get-ProcesseurOrdi
    
    Renvoie un objet PS pour chaque ordinateur contenant le nom de l'ordinateur et le processeur.
    #>

    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('NomOrdinateur')]
        [string]$Nom = $env:COMPUTERNAME
    )

    begin{
        $ProcesseursOrdi = @()  # Initialisation d'une liste pour stocker les processeurs d'ordinateurs
    }

    process{
        $ProcesseursOrdi += Get-CimInstance -ComputerName $Nom -ClassName Win32_Processor -Property Name | Select-Object -Property @{n='Nom';e={$Nom}},@{n='Processeur';e={$_.Name}}
        # Utilisation de Get-CimInstance pour recuperer l'instance de la classe Win32_Processor contenant le nom du processeur de l'ordinateur
        # La propriete Select-Object est utilisee pour formater les resultats avec les noms 'Nom' et 'Processeur'
    }

    end{
        return $ProcesseursOrdi  # Renvoie la liste des processeurs d'ordinateurs
    }
}

# Definition de la fonction pour obtenir la memoire en Go d'un ordinateur
function Get-MemoireOrdi {
    <#
    .SYNOPSIS
    Obtient la memoire en Go d'un ordinateur (ex: 60 Go).

    .DESCRIPTION
    Obtient la memoire en Go d'un ordinateur ou d'un groupe d'ordinateurs.

    .PARAMETER Name
    La memoire de l'ordinateur avec ce nom sera retournee. Par defaut, il s'agit de l'ordinateur local.

    .INPUTS
    Prend un tableau de noms d'ordinateurs ou d'objets AD en entree via le pipeline.

    .OUTPUTS
    Renvoie des objets PS pour les ordinateurs qui lui sont passes, comprenant le nom de l'ordinateur et la memoire en Go.

    .EXAMPLE
    Get-MemoireOrdi -Nom 'ordi1'

    Renvoie un objet PS avec le nom de l'ordinateur et la memoire en Go de 'ordi1'.

    .EXAMPLE
    'ordi1','ordi2' | Get-MemoireOrdi
    
    Renvoie un objet PS pour chaque ordinateur contenant le nom de l'ordinateur et la memoire en Go.
    #>

    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('NomOrdinateur')]
        [string]$Nom = $env:COMPUTERNAME
    )

    begin{
        $MemoiresOrdi = @()  # Initialisation d'une liste pour stocker les memoires d'ordinateurs
    }

    process{
        if (Test-Connection -ComputerName $Nom -Count 1 -Quiet) {
            Write-Verbose -Message "Connexion a $Nom en cours."

            $MemoiresOrdi += [PSCustomObject]@{
                Nom = $Nom;
                MemoireGo = [math]::Round(((Get-CimInstance -ComputerName $Nom -ClassName Win32_ComputerSystem -Property TotalPhysicalMemory).TotalPhysicalMemory / 1GB), 1)
            }
            # Utilisation de [PSCustomObject] pour creer un objet PS personnalise avec le nom de l'ordinateur et la memoire en Go
        } else {
            Write-Verbose -Message "$Nom est hors ligne."
        }
    }

    end{
        return $MemoiresOrdi  # Renvoie la liste des memoires d'ordinateurs
    }
}

# Definition de la fonction pour obtenir des informations sur les disques d'un ordinateur
function Get-DisqueDurOrdi {
    <#
    .SYNOPSIS
    Obtient des informations sur les disques d'un ordinateur.

    .DESCRIPTION
    Renvoie des informations sur les disques d'un ordinateur ou d'un groupe d'ordinateurs. Les informations incluent le nom de l'ordinateur, le lecteur, la taille, l'espace libre et si le lecteur a moins de 25% d'espace disponible.

    .PARAMETER Name
    Specifie l'ordinateur a partir duquel la fonction recueillera des informations.

    .INPUTS
    Vous pouvez transmettre des noms d'hotes ou des objets AD d'ordinateurs.

    .OUTPUTS
    Renvoie des objets PS a l'hote avec les informations suivantes sur les disques d'un ordinateur : Nom, DeviceID, TailleGo, EspaceLibreGo et indique ceux ayant moins de 25% d'espace disponible.

    .NOTES
    Les resultats incluent les lecteurs mappes.

    .EXAMPLE
    Get-DisqueDurOrdi

    Obtient des informations sur les disques pour l'hote local.

    .EXAMPLE
    Get-DisqueDurOrdi -Nom 'ordi1'

    Obtient des informations sur les disques pour "ordinateur".

    .EXAMPLE
    Get-ADComputer -Filter * | Get-DisqueDurOrdi

    Obtient des informations sur les disques pour tous les ordinateurs dans AD.
    #>

    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('NomOrdinateur')]
        [string]$Nom = $env:COMPUTERNAME
    )

    begin{
        $ListeInformationsDisque = @()  # Initialisation d'une liste pour stocker les informations sur les disques
    }

    process{
        $ListeInformationsDisque += Get-CimInstance -ComputerName $Nom -ClassName win32_logicaldisk -Property DeviceID,Size,FreeSpace,DriveType | 
            Where-Object -Property DriveType -EQ 3 | 
            Select-Object -Property @{n="Ordinateur";e={$Nom}},`
            @{n="DeviceID";e={$_.deviceid}},`
            @{n="TailleGo";e={$_.size / 1GB -as [int]}},`
            @{n="EspaceLibreGo";e={$_.freespace / 1GB -as [int]}},`
            @{n="MoinsDe25Pourcent";e={if(($_.freespace / $_.size) -le 0.25){"Vrai"}else{"Faux"}}}
        # Utilisation de Get-CimInstance pour recuperer l'instance de la classe win32_logicaldisk contenant des informations sur les disques
        # La propriete Where-Object est utilisee pour filtrer les lecteurs de type 3 (lecteurs locaux)
        # La propriete Select-Object est utilisee pour formater les resultats avec les noms appropries
    }

    end{
        $ListeInformationsDisque = $ListeInformationsDisque | Where-Object -Property TailleGo -NE 0
        return $ListeInformationsDisque
    }  
}

# Definition de la fonction pour obtenir l'adresse IPv4 d'un ordinateur
function Get-AdresseIPOrdi {
    <#
    .SYNOPSIS
    Obtient l'adresse IPv4 d'un ordinateur.

    .DESCRIPTION
    Obtient l'adresse IPv4 d'un ordinateur ou d'ordinateurs.

    .PARAMETER Name
    Le nom d'hote de l'ordinateur cible.

    .INPUTS
    Cette fonction prend un tableau de noms d'hotes ou d'objets AD d'ordinateurs.

    .OUTPUTS
    Renvoie un tableau d'objets PS avec le nom de l'ordinateur et l'adresse IP.

    .EXAMPLE
    Get-AdresseIPOrdi

    Renvoie un objet PS avec le nom de l'ordinateur local et l'adresse IPv4.
    
    .EXAMPLE
    Get-AdresseIPOrdi -Nom 'ordi1'

    Renvoie un objet PS avec le nom de l'ordinateur 'ordi1' et son adresse IPv4.
    #>

    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('NomOrdinateur')]
        [string]$Nom = $env:COMPUTERNAME
    )

    begin{
        $ListeAdresseIPOrdinateur = @()  # Initialisation d'une liste pour stocker les adresses IP des ordinateurs
    }

    process{
        $ListeAdresseIPOrdinateur += [PSCustomObject]@{
            Nom = $Nom;
            AdresseIP = (Resolve-DnsName -Type A -Name $Nom).IPAddress
        }
        # Utilisation de [PSCustomObject] pour creer un objet PS personnalise avec le nom de l'ordinateur et l'adresse IP
    }

    end{
        return $ListeAdresseIPOrdinateur
    }
}

# Definition de la fonction pour obtenir la derniere heure de demarrage d'un ordinateur
function Get-DernierDemarrageOrdi {
    <#
    .SYNOPSIS
    Obtient la derniere heure a laquelle un ordinateur a demarre.

    .DESCRIPTION
    Obtient le nom et la derniere heure a laquelle un ordinateur ou des ordinateurs ont demarre. Par defaut, cible l'ordinateur local.

    .PARAMETER Name
    Nom d'hote de l'ordinateur cible.

    .INPUTS
    Peut recevoir des noms d'hotes ou des objets AD d'ordinateurs en entree.

    .OUTPUTS
    Renvoie un objet PS avec le nom de l'ordinateur et la derniere heure de demarrage.

    .EXAMPLE
    Get-DernierDemarrageOrdi

    Renvoie la derniere heure a laquelle l'hote local a demarre.

    .EXAMPLE
    Get-DernierDemarrageOrdi -Nom "ordi1"

    Renvoie la derniere heure a laquelle l'ordinateur "ordi1" a demarre.

    .EXAMPLE
    "Ordi1","Ordi2" | Get-DernierDemarrageOrdi

    Renvoie la derniere heure de demarrage pour "Ordi1" et "Ordi2".
    #>

    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('NomOrdinateur')]
        [string]$Nom = $env:COMPUTERNAME
    )

    begin{
        $ListeHeureDernierDemarrage = @()  # Initialisation d'une liste pour stocker les heures de demarrage
    }

    process{
        $ListeHeureDernierDemarrage += Get-CimInstance -ComputerName $Nom -Class Win32_OperatingSystem -Property LastBootUpTime | 
            Select-Object -Property @{n='Nom';e={$_.pscomputername}},LastBootUpTime
        # Utilisation de Get-CimInstance pour recuperer l'instance de la classe Win32_OperatingSystem contenant la derniere heure de demarrage de l'ordinateur
        # La propriete Select-Object est utilisee pour formater les resultats avec les noms 'Nom' et 'LastBootUpTime'
    }

    end{
        return $ListeHeureDernierDemarrage
    }
}

# Definition de la fonction pour obtenir des informations generales sur un ordinateur
function Get-InfoOrdi {
    <#
    .SYNOPSIS
    Obtient des informations generales sur un ordinateur.

    .DESCRIPTION
    Cette fonction recueille des informations sur un ordinateur ou des ordinateurs. Par defaut, elle collecte des informations de l'hote local.

    .PARAMETER Name
    Specifie le nom de l'ordinateur dont les informations sont collectees.

    .INPUTS
    Vous pouvez transmettre des noms d'hotes ou des objets AD d'ordinateurs.

    .OUTPUTS
    Renvoie un objet avec le nom de l'ordinateur, le modele, le processeur, la memoire en Go, la taille du lecteur C en Go, l'adresse IP, la derniere heure de demarrage et la derniere heure de connexion.

    .NOTES

    Ne renvoie pas d'informations sur les ordinateurs hors ligne.

    .EXAMPLE
    Get-InfoOrdi

    Renvoie les informations sur l'ordinateur local.

    .EXAMPLE
    Get-InfoOrdi -Nom "ordi1"

    Renvoie les informations sur l'ordinateur "ordi1".

    .EXAMPLE
    Get-ADComputer -Filter * | Get-InfoOrdi

    Renvoie les informations sur tous les ordinateurs AD.
    #>

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [Alias('NomOrdinateur')]
        [string]$Nom = $env:COMPUTERNAME
    )

    begin {
        # Initialisation des listes
        $Ordinateurs = [System.Collections.Generic.List[string]]::new()
        $ListeInfoOrdinateur = [System.Collections.Generic.List[psobject]]::new()
    }

    process {
        # Ajout du nom de l'ordinateur a la liste
        $Ordinateurs.Add($Nom)
    }

    end {
        # Utilisation de la commande ForEach-Object pour traiter plusieurs ordinateurs simultanement
        $Ordinateurs | ForEach-Object {
            # Verification si l'ordinateur est accessible
            if (Test-Connection -ComputerName $_ -Count 1 -Quiet) {
                # Creation d'un objet PS avec les informations recuperees a partir des fonctions individuelles
                New-Object -TypeName PSObject -Property @{
                    Nom              = $_
                    Modele           = (Get-ModeleOrdi -Nom $_).Modele
                    Processeur       = (Get-ProcesseurOrdi -Nom $_).Processeur
                    MemoireGo        = (Get-MemoireOrdi -Nom $_).MemoireGo
                    TailleCDriveGo   = (Get-DisqueDurOrdi -Nom $_ | Where-Object -Property DeviceID -Match 'C').TailleGo
                    AdresseIP        = (Get-AdresseIPOrdi -Nom $_).AdresseIP
                    DernierDemarrage = (Get-DernierDemarrageOrdi -Nom $_).LastBootUpTime
                }
            }
        } | ForEach-Object {
            # Ajout de chaque objet PS cree a la liste
            $ListeInfoOrdinateur.Add($_)
        }

        # Retourne la liste finale des informations sur les ordinateurs
        return $ListeInfoOrdinateur
    }

}