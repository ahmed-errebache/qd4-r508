# TP01 — Conteneuriser une application Spring Boot avec Docker

Module **R5.08 — Qualité de développement** · Ahmed Errebache
Support : `docs/Docker et Spring Boot (TP).pdf`

---

## Les trois notions du support

| Terme | Définition |
|---|---|
| **Dockerfile** | la liste d'instructions qui permet de construire une image |
| **Image** | un modèle de l'application, empaqueté avec toutes ses dépendances |
| **Conteneur** | une instance isolée dans laquelle l'application s'exécute |

Le rapport entre les trois est le même qu'entre un fichier source, une classe et
un objet : le Dockerfile se compile en image, l'image s'instancie en conteneur.

---

## 1. Vérifier l'application en local

```powershell
cd tp/tp01-docker-spring-boot
mvn clean package
java -jar target/spring-boot-docker.jar
```

<http://localhost:8080/greeting> doit afficher `Greetings from Docker!`

C'est l'étape que le support insiste à faire **avant** Docker : si le `.jar` ne
tourne pas sur la machine, il ne tournera pas mieux dans un conteneur. On isole
les problèmes un par un.

---

## 2. Construire l'image

```powershell
docker build -t spring-boot-docker .
docker images
```

Le `.` final est le **contexte de build** : le dossier envoyé au démon Docker.
C'est pour ça qu'un `.dockerignore` est utile — sans lui, `target/` et `.git/`
partent aussi.

## 3. Lancer un conteneur

```powershell
docker ps                                    # aucun conteneur au depart
docker run -p 80:8080 spring-boot-docker
```

Dans un **second terminal** :

```powershell
docker ps
```

<http://localhost/greeting> — plus besoin du `:8080`.

`-p 80:8080` mappe le port **80 de la machine** sur le port **8080 du
conteneur**. L'application n'a pas changé de port : elle écoute toujours 8080,
mais à l'intérieur de son réseau isolé.

## 4. Nettoyer

```powershell
# Ctrl+C arrete le conteneur : docker ps ne le montre plus
docker images                  # l'image, elle, reste
docker rmi spring-boot-docker -f
```

Un conteneur arrêté disparaît ; l'image survit. C'est la distinction que le TP
fait vérifier concrètement.

---

## 5. La version multi-étapes

Le support propose ensuite un Dockerfile qui intègre Maven. Il est fourni ici
dans `Dockerfile.multistage` :

```powershell
docker build -f Dockerfile.multistage -t spring-boot-docker:multi .
docker run -p 80:8080 spring-boot-docker:multi
```

**Ce que ça change :** plus besoin de Maven ni de JDK sur la machine, ni de
lancer `mvn package` avant. Le build est reproductible — même résultat sur
n'importe quel poste, ce qui est précisément le sujet du module.

Deux améliorations par rapport au Dockerfile du support :

- **Étape finale sur `eclipse-temurin:21-jre`** et non `-jdk`. Exécuter ne
  demande pas de compilateur. L'image finale perd plusieurs centaines de Mo.
- **`COPY pom.xml` puis `dependency:go-offline` avant `COPY src`.** Docker met
  chaque instruction en cache. En copiant le `pom.xml` seul d'abord, une simple
  modification de code ne réinvalide pas le téléchargement des dépendances.

---

## 6. Publier sur Docker Hub

```powershell
docker login
docker tag spring-boot-docker <utilisateur>/spring-boot-docker:1.0
docker push <utilisateur>/spring-boot-docker:1.0
```

Récupérer et exécuter depuis n'importe quelle machine :

```powershell
docker pull <utilisateur>/spring-boot-docker:1.0
docker run -p 80:8080 <utilisateur>/spring-boot-docker:1.0
```

> `docker push` publie sur un dépôt **public** par défaut. Ne jamais construire
> une image contenant un mot de passe, une clé d'API ou un fichier `.env` : tout
> ce qui entre dans une couche y reste, même supprimé par une instruction
> suivante.

---

## Écart assumé avec le support

Le support demande **Java 25**. Ce projet est en **Java 21** — la version LTS
installée sur ma machine, et celle utilisée par tous les autres TP du module.
Rien d'autre ne change : pour repasser en 25, remplacer `<java.version>21</java.version>`
dans le `pom.xml` et les tags `21-jdk` / `21-jre` des Dockerfile par leurs
équivalents `25`.

---

## À rapprocher du reste du semestre

- **R5.09 Virtualisation avancée** traite Docker en profondeur (volumes,
  réseaux, Compose, Kubernetes). Ce TP en est la porte d'entrée côté Java.
- **JIB** (`docs/04-outils.md` du dépôt) fait le même travail *sans* Dockerfile
  ni démon Docker, directement depuis Maven. À essayer une fois ce TP compris,
  pour voir ce que l'outil automatise.
