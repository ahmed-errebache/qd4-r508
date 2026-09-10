# Maven

D'après le support « Installation Maven » du module, avec les pièges rencontrés.

---

## Installation sous Windows

### Le plus rapide : winget

```powershell
winget install Apache.Maven
```

Le PATH est configuré automatiquement. Ferme et rouvre le terminal, puis vérifie.

### À la main

1. Télécharger l'archive **Binary zip** sur <https://maven.apache.org/download.html>
   (fichier `apache-maven-3.x.y-bin.zip`)
2. Décompresser dans `C:\Program Files\Maven\` → `C:\Program Files\Maven\apache-maven-3.9.10`
3. Créer la variable système `MAVEN_HOME` pointant sur ce dossier
4. Ajouter `%MAVEN_HOME%\bin` au `Path`

**Par l'interface graphique :** clic droit sur le menu Démarrer → Système →
Paramètres avancés du système → Variables d'environnement.

**Ou en ligne de commande, dans un terminal administrateur :**

```powershell
setx MAVEN_HOME "C:\Program Files\Maven\apache-maven-3.9.10" /M
setx PATH "%PATH%;%MAVEN_HOME%\bin" /M
```

> ### Le piège du support
>
> Le support propose :
> ```
> set PATH="C:\Program Files\Maven\apache-maven-3.9.10\bin";%PATH%
> ```
> **`set` ne dure que le temps de la fenêtre.** Ferme le terminal, tout est perdu.
> C'est `setx` qu'il faut, ou l'interface graphique. Et `setx` ne prend effet que
> dans les terminaux ouverts **après** la commande — celui où tu l'as tapée ne voit
> toujours rien.

---

## Vérifier

```powershell
mvn -version
```

La sortie doit afficher la version de Maven **et** le JDK utilisé :

```
Apache Maven 3.9.10
Java version: 21.0.4, vendor: Eclipse Adoptium
Maven home: C:\Program Files\Maven\apache-maven-3.9.10
```

Si `JAVA_HOME` est absent ou faux, Maven refuse de démarrer :

```powershell
echo %JAVA_HOME%
java -version
```

`JAVA_HOME` doit pointer sur la **racine du JDK**, pas sur son `bin`, et pas sur un
JRE. Exemple correct : `C:\Program Files\Eclipse Adoptium\jdk-21.0.4.7-hotspot`.

> Le support écrit `Java --version` avec un J majuscule. Windows n'y voit rien à
> redire mais autant prendre l'habitude : `java -version` (un tiret) ou
> `java --version` (deux tirets, depuis le JDK 9).

---

## Les commandes du quotidien

| Commande | Effet |
|---|---|
| `mvn clean` | vide `target/` |
| `mvn compile` | compile les sources |
| `mvn test` | lance les tests |
| `mvn package` | produit le `.jar` dans `target/` |
| `mvn clean install` | build complet + dépôt local `~/.m2` |
| `mvn spring-boot:run` | démarre l'application Spring Boot |
| `mvn dependency:tree` | affiche l'arbre des dépendances |

### Le wrapper

Un projet généré par [start.spring.io](https://start.spring.io) contient `mvnw` et
`mvnw.cmd`. Ils téléchargent la version de Maven attendue par le projet :

```powershell
.\mvnw spring-boot:run
```

**Tout le monde compile avec la même version de Maven**, quelle que soit la machine.
C'est de la reproductibilité — exactement le sujet du module. Utilise `mvnw` plutôt
que `mvn` dès qu'il est présent, et committe-le : il fait partie du projet.

---

## Créer un projet Spring Boot

Le plus simple reste <https://start.spring.io> : choisir Maven, Java 17 ou 21,
Spring Boot 3.x, puis les dépendances **Spring Web**, **Spring Data JPA**, **H2
Database**.

En ligne de commande, avec curl (livré avec Windows) :

```powershell
curl https://start.spring.io/starter.zip -d dependencies=web,data-jpa,h2 -d type=maven-project -d javaVersion=21 -d name=demo -o demo.zip
```

---

## Dépannage

**`mvn` n'est pas reconnu** → le PATH n'est pas pris en compte. Rouvre le terminal.
Si ça persiste, vérifie que le chemin dans `Path` se termine bien par `\bin`.

**Build très lent la première fois** → normal, Maven télécharge tout le dépôt local
dans `C:\Users\<toi>\.m2\repository`. Les fois suivantes sont rapides.

**Erreur de version Java** → le `<java.version>` du `pom.xml` ne correspond pas à ton
JDK. Ajuste l'un ou l'autre.
