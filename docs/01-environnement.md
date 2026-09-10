# Environnement de développement

Synthèse de la section « Installer et Configurer » de la ressource Arche.

---

## Le JDK

**Spring Boot 3 exige le JDK 17 au minimum.** Le 21 est la version LTS actuelle,
c'est celle à prendre.

```powershell
winget install EclipseAdoptium.Temurin.21.JDK
```

Ou manuellement depuis <https://adoptium.net>.

Vérification — les deux commandes doivent répondre :

```powershell
java -version     # présent si le JRE est installé
javac -version    # présent seulement avec le JDK
```

Si `java` répond mais pas `javac`, tu n'as que le **JRE**. Maven ne pourra rien
compiler. C'est l'erreur la plus fréquente au démarrage.

Le support mentionne aussi la **JEP de Java 25 LTS** — c'est la prochaine version au
support long terme. Bon à connaître pour la culture, mais reste sur le 21 pour les TP.

---

## L'IDE

Le support en cite quatre :

| IDE | Remarque du support |
|---|---|
| **IntelliJ IDEA** | « la préférence des développeurs professionnels » — version Ultimate |
| **Eclipse** | possible avec des plugins complémentaires |
| **Spring Tool Suite** | Eclipse « customisé », dispose d'un Boot Dashboard |
| **VS Code** | alternative possible |

**IntelliJ IDEA Ultimate est gratuite pour les étudiants** avec l'adresse
`@etu.univ-lorraine.fr` : <https://www.jetbrains.com/community/education/>
Ça vaut le détour, c'est la version payante à 600 €/an.

Si tu restes sur Eclipse, prends directement **Spring Tool Suite** :
<https://spring.io/tools> — le Boot Dashboard permet de démarrer et redémarrer une
application Spring Boot d'un clic, ce qui change le confort de travail.

---

## Les variables d'environnement

Deux à connaître :

| Variable | Valeur | Rôle |
|---|---|---|
| `JAVA_HOME` | racine du JDK | utilisée par Maven et les IDE |
| `MAVEN_HOME` | racine de Maven | référencée dans le `Path` |

Vérification :

```powershell
echo %JAVA_HOME%
echo %MAVEN_HOME%
```

**Où les définir :** clic droit sur le menu Démarrer → Système → Paramètres avancés
du système → Variables d'environnement.

**Trois erreurs classiques :**

- `JAVA_HOME` pointe sur le `bin` au lieu de la racine du JDK
- `JAVA_HOME` pointe sur un JRE — Maven exigera un JDK
- La variable est bien créée, mais le terminal ouvert avant ne la voit pas : il faut
  le fermer et le rouvrir

Pour lister toutes les variables d'un coup : `set` sous cmd, `Get-ChildItem Env:`
sous PowerShell.

---

## Tester les API REST

Le support cite deux outils :

- **[Postman](https://www.postman.com/)** — client complet, avec collections et
  historique. Le classique.
- **[reqbin](https://reqbin.com/)** — dans le navigateur, rien à installer.
  Pratique pour un test rapide.

Une troisième voie, sans rien installer : **curl**, livré avec Windows 10 et 11.

```powershell
curl http://localhost:8080/api/articles
curl -X POST http://localhost:8080/api/articles -H "Content-Type: application/json" -d "{\"nom\":\"Test\"}"
```

Sous PowerShell, `curl` est un alias de `Invoke-WebRequest` qui ne prend pas la même
syntaxe. Écris **`curl.exe`** pour forcer le vrai curl.

---

## Vérifier l'ensemble

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verifier-environnement.ps1
```

Le script contrôle le JDK, Maven, Git, les variables, et les applications installées.
Il ne modifie rien.
