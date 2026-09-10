<#
    Vérification de l'environnement de développement — R5.08 Qualité de développement
    IUT de Saint-Dié-des-Vosges

    Utilisation : clic droit sur le fichier → « Exécuter avec PowerShell »
    Ou depuis un terminal :  powershell -ExecutionPolicy Bypass -File .\verifier-environnement.ps1

    Le script ne modifie RIEN. Il se contente de regarder ce qui est installé.
#>

$ErrorActionPreference = 'SilentlyContinue'

function Titre($t) {
    Write-Host ""
    Write-Host ("=" * 62) -ForegroundColor DarkGray
    Write-Host "  $t" -ForegroundColor Cyan
    Write-Host ("=" * 62) -ForegroundColor DarkGray
}

# Teste une commande et affiche sa version
function Verifier($nom, $commande, $argsVersion, $obligatoire, $ouTrouver) {
    $exe = Get-Command $commande -ErrorAction SilentlyContinue
    if ($exe) {
        $v = (& $commande $argsVersion 2>&1 | Select-Object -First 1)
        Write-Host ("  [OK]      {0,-22}" -f $nom) -ForegroundColor Green -NoNewline
        Write-Host $v -ForegroundColor Gray
        return $true
    }
    else {
        $etiquette = if ($obligatoire) { "[MANQUE]" } else { "[absent] " }
        $couleur   = if ($obligatoire) { "Red" }      else { "DarkYellow" }
        Write-Host ("  {0}  {1,-22}" -f $etiquette, $nom) -ForegroundColor $couleur -NoNewline
        Write-Host $ouTrouver -ForegroundColor DarkGray
        return $false
    }
}

function VerifierVariable($nom) {
    $val = [Environment]::GetEnvironmentVariable($nom, 'Machine')
    if (-not $val) { $val = [Environment]::GetEnvironmentVariable($nom, 'User') }
    if ($val) {
        Write-Host ("  [OK]      {0,-22}" -f $nom) -ForegroundColor Green -NoNewline
        Write-Host $val -ForegroundColor Gray
        if (-not (Test-Path $val)) {
            Write-Host "            /!\ ce chemin n'existe pas sur le disque" -ForegroundColor Red
        }
    } else {
        Write-Host ("  [MANQUE]  {0,-22}" -f $nom) -ForegroundColor Red -NoNewline
        Write-Host "non definie" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "  R5.08 - Verification de l'environnement" -ForegroundColor White
Write-Host ("  " + (Get-Date -Format "dd/MM/yyyy HH:mm")) -ForegroundColor DarkGray

# ---------------------------------------------------------------- INDISPENSABLE
Titre "Indispensable"

$java  = Verifier "Java (JDK)"   "java"   "-version"   $true  "https://adoptium.net"
$javac = Verifier "Compilateur javac" "javac" "-version" $true "JRE seul installe -> il faut le JDK"
$mvn   = Verifier "Maven"        "mvn"    "-version"   $true  "https://maven.apache.org/download.html"
$git   = Verifier "Git"          "git"    "--version"  $true  "https://git-scm.com/download/win"

Write-Host ""
VerifierVariable "JAVA_HOME"
VerifierVariable "MAVEN_HOME"

# Le JDK doit etre en version 17 ou plus pour Spring Boot 3
if ($java) {
    $sortie = (java -version 2>&1 | Out-String)
    if ($sortie -match '"?(\d+)[\."]') {
        $majeure = [int]$Matches[1]
        Write-Host ""
        if ($majeure -ge 17) {
            Write-Host "  [OK]      JDK $majeure : compatible Spring Boot 3" -ForegroundColor Green
        } else {
            Write-Host "  [PROBLEME] JDK $majeure : Spring Boot 3 exige au minimum le JDK 17" -ForegroundColor Red
        }
    }
}

# ------------------------------------------------------------------ OPTIONNEL
Titre "Outils complementaires"

Verifier "Docker"      "docker" "--version" $false "https://www.docker.com/products/docker-desktop"
Verifier "Node.js"     "node"   "--version" $false "utile seulement pour un front React"
Verifier "curl"        "curl"   "--version" $false "livre avec Windows 10/11"
Verifier "MySQL client" "mysql" "--version" $false "facultatif : H2 suffit pour les TP"

Titre "Applications installees"

$aChercher = @(
    "IntelliJ", "Eclipse", "Spring Tools", "Visual Studio Code",
    "Postman", "DBeaver", "DbSchema", "MySQL", "GitHub Desktop"
)
$installes = Get-ItemProperty `
    HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, `
    HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, `
    HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName } | Select-Object -ExpandProperty DisplayName

foreach ($cible in $aChercher) {
    $trouve = $installes | Where-Object { $_ -like "*$cible*" } | Select-Object -First 1
    if ($trouve) {
        Write-Host ("  [OK]      {0,-22}" -f $cible) -ForegroundColor Green -NoNewline
        Write-Host $trouve -ForegroundColor Gray
    } else {
        Write-Host ("  [absent]  {0,-22}" -f $cible) -ForegroundColor DarkYellow
    }
}

# --------------------------------------------------------------------- BILAN
Titre "Bilan"

$manquants = @()
if (-not $java -or -not $javac) { $manquants += "JDK 17+ (https://adoptium.net)" }
if (-not $mvn)                  { $manquants += "Maven (https://maven.apache.org/download.html)" }
if (-not $git)                  { $manquants += "Git (https://git-scm.com/download/win)" }

if ($manquants.Count -eq 0) {
    Write-Host "  Tout l'indispensable est en place." -ForegroundColor Green
    Write-Host "  Prochaine etape : creer un projet sur https://start.spring.io" -ForegroundColor Gray
} else {
    Write-Host "  A installer :" -ForegroundColor Yellow
    foreach ($m in $manquants) { Write-Host "    - $m" -ForegroundColor Yellow }
    Write-Host ""
    Write-Host "  Le plus simple, si winget est disponible :" -ForegroundColor Gray
    Write-Host "    winget install EclipseAdoptium.Temurin.21.JDK" -ForegroundColor White
    Write-Host "    winget install Apache.Maven" -ForegroundColor White
    Write-Host "    winget install Git.Git" -ForegroundColor White
    Write-Host ""
    Write-Host "  Ferme et rouvre ton terminal apres chaque installation," -ForegroundColor DarkGray
    Write-Host "  sinon le PATH n'est pas rafraichi." -ForegroundColor DarkGray
}

Write-Host ""
Read-Host "Appuie sur Entree pour fermer"
