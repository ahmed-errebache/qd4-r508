<#
    Installation de l'environnement de développement — R5.08 Qualité de développement
    IUT de Saint-Dié-des-Vosges

    Le script VERIFIE d'abord, puis n'installe QUE ce qui manque.
    Rien n'est réinstallé si c'est déjà présent.

    A LANCER EN ADMINISTRATEUR.
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = 'Continue'

function Titre($t) {
    Write-Host ""
    Write-Host ("=" * 64) -ForegroundColor DarkGray
    Write-Host "  $t" -ForegroundColor Cyan
    Write-Host ("=" * 64) -ForegroundColor DarkGray
}

function Info($m)    { Write-Host "  $m" -ForegroundColor Gray }
function Ok($m)      { Write-Host "  [OK]     $m" -ForegroundColor Green }
function Action($m)  { Write-Host "  [INSTAL] $m" -ForegroundColor Yellow }
function Souci($m)   { Write-Host "  [SOUCI]  $m" -ForegroundColor Red }

# Recharge le PATH depuis le registre, pour voir les outils installés
# pendant cette même session sans avoir à rouvrir le terminal.
function RechargerPath {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user    = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
}

function EstPresent($commande) {
    RechargerPath
    return [bool](Get-Command $commande -ErrorAction SilentlyContinue)
}

Write-Host ""
Write-Host "  R5.08 - Installation de l'environnement" -ForegroundColor White
Write-Host ("  " + (Get-Date -Format "dd/MM/yyyy HH:mm")) -ForegroundColor DarkGray

# =====================================================================  JDK
Titre "1. JDK (Java Development Kit)"

if (EstPresent 'javac') {
    $v = (javac -version 2>&1 | Out-String).Trim()
    Ok "deja installe : $v"
} else {
    Action "installation du JDK 21 Temurin..."
    winget install --id EclipseAdoptium.Temurin.21.JDK --silent --accept-package-agreements --accept-source-agreements
    RechargerPath
}

# --- JAVA_HOME
$javaHome = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'Machine')
if ($javaHome -and (Test-Path $javaHome)) {
    Ok "JAVA_HOME = $javaHome"
} else {
    $candidat = Get-ChildItem "C:\Program Files\Eclipse Adoptium\jdk-*" -Directory -ErrorAction SilentlyContinue |
                Sort-Object Name -Descending | Select-Object -First 1
    if ($candidat) {
        [Environment]::SetEnvironmentVariable('JAVA_HOME', $candidat.FullName, 'Machine')
        $env:JAVA_HOME = $candidat.FullName
        Action "JAVA_HOME defini sur $($candidat.FullName)"
    } else {
        Souci "JDK introuvable dans C:\Program Files\Eclipse Adoptium\ - definis JAVA_HOME a la main"
    }
}

# ===================================================================  MAVEN
Titre "2. Maven"

if (EstPresent 'mvn') {
    $v = (mvn -version 2>&1 | Select-Object -First 1)
    Ok "deja installe : $v"
} else {
    # winget ne publie pas Maven sous un identifiant stable :
    # on prend directement l'archive officielle d'Apache.
    $racine = "C:\Program Files\Maven"
    $versions = @("3.9.11", "3.9.10", "3.9.9")
    $installe = $false

    foreach ($ver in $versions) {
        $url = "https://dlcdn.apache.org/maven/maven-3/$ver/binaries/apache-maven-$ver-bin.zip"
        $zip = "$env:TEMP\apache-maven-$ver-bin.zip"

        Action "tentative avec Maven $ver..."
        try {
            Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing -ErrorAction Stop
        } catch {
            Info "  version $ver indisponible, on essaie la suivante"
            continue
        }

        New-Item -ItemType Directory -Force -Path $racine | Out-Null
        Expand-Archive -Path $zip -DestinationPath $racine -Force
        Remove-Item $zip -Force

        $maisonMaven = "$racine\apache-maven-$ver"
        [Environment]::SetEnvironmentVariable('MAVEN_HOME', $maisonMaven, 'Machine')

        # On ajoute au PATH machine, sans jamais l'ecraser
        $pathMachine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
        if ($pathMachine -notlike "*$maisonMaven\bin*") {
            [Environment]::SetEnvironmentVariable('Path', "$pathMachine;$maisonMaven\bin", 'Machine')
        }
        RechargerPath
        Ok "Maven $ver installe dans $maisonMaven"
        $installe = $true
        break
    }

    if (-not $installe) {
        Souci "telechargement impossible - recupere le zip sur https://maven.apache.org/download.html"
    }
}

# =====================================================================  GIT
Titre "3. Git"

if (EstPresent 'git') {
    Ok "deja installe : $(git --version)"
} else {
    Action "installation de Git..."
    winget install --id Git.Git --silent --accept-package-agreements --accept-source-agreements
    RechargerPath
}

# ================================================================  INTELLIJ
Titre "4. IntelliJ IDEA"

$dejaLa = Get-ItemProperty `
    HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, `
    HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "*IntelliJ*" } | Select-Object -First 1

if ($dejaLa) {
    Ok "deja installe : $($dejaLa.DisplayName)"
} else {
    Action "installation d'IntelliJ IDEA Ultimate..."
    winget install --id JetBrains.IntelliJIDEA.Ultimate --silent --accept-package-agreements --accept-source-agreements
    Info "Licence etudiante gratuite : https://www.jetbrains.com/community/education/"
    Info "Active-la avec ton adresse @etu.univ-lorraine.fr"
}

# ===========================================================  COMPLEMENTAIRES
Titre "5. Outils complementaires"

$optionnels = @(
    @{ Nom = "DBeaver";       Id = "dbeaver.dbeaver";        Cmd = $null },
    @{ Nom = "Postman";       Id = "Postman.Postman";        Cmd = $null },
    @{ Nom = "Docker Desktop";Id = "Docker.DockerDesktop";   Cmd = "docker" }
)

foreach ($o in $optionnels) {
    $present = $false
    if ($o.Cmd) { $present = EstPresent $o.Cmd }
    if (-not $present) {
        $reg = Get-ItemProperty `
            HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, `
            HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, `
            HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*$($o.Nom)*" } | Select-Object -First 1
        if ($reg) { $present = $true }
    }

    if ($present) {
        Ok "$($o.Nom) deja installe"
    } else {
        Action "installation de $($o.Nom)..."
        winget install --id $o.Id --silent --accept-package-agreements --accept-source-agreements
    }
}

# =================================================================  BILAN
Titre "Bilan"

RechargerPath
$resultats = @(
    @{ Nom = "JDK (javac)"; Cmd = "javac"; Arg = "-version" },
    @{ Nom = "Maven";       Cmd = "mvn";   Arg = "-version" },
    @{ Nom = "Git";         Cmd = "git";   Arg = "--version" }
)

$tousOk = $true
foreach ($r in $resultats) {
    if (Get-Command $r.Cmd -ErrorAction SilentlyContinue) {
        $v = (& $r.Cmd $r.Arg 2>&1 | Select-Object -First 1)
        Ok ("{0,-14} {1}" -f $r.Nom, $v)
    } else {
        Souci "$($r.Nom) toujours introuvable"
        $tousOk = $false
    }
}

Write-Host ""
Write-Host "  JAVA_HOME  : $([Environment]::GetEnvironmentVariable('JAVA_HOME','Machine'))" -ForegroundColor Gray
Write-Host "  MAVEN_HOME : $([Environment]::GetEnvironmentVariable('MAVEN_HOME','Machine'))" -ForegroundColor Gray

Write-Host ""
if ($tousOk) {
    Write-Host "  Tout est en place." -ForegroundColor Green
} else {
    Write-Host "  Certains outils manquent encore - relis les lignes rouges ci-dessus." -ForegroundColor Yellow
}
Write-Host "  IMPORTANT : ferme et rouvre ton terminal pour que le PATH soit pris en compte." -ForegroundColor DarkYellow

Write-Host ""
Read-Host "Appuie sur Entree pour fermer"
