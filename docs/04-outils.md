# Outils complémentaires

Section « Outils complémentaires » de la ressource Arche.

---

## Ce que dit le support sur l'architecture

**Front-end**

- **JavaFX** — proposé par Oracle, mais le support déconseille de l'utiliser pour
  toute l'application : « applications de bureau, complexe en programmation, pas
  responsive, difficulté à générer des effets visuels, mais puissant ».
- **Vaadin** — composants responsive, fonctionne en HTTP.
- **React.js**, Angular.js, Node.js — « React.js est populaire parmi les
  développeurs Front-end ».

**Back-end**

- **Spring** — « framework Java back-end parmi les plus populaires ». Nombreux
  plugins, bases de données intégrées et en mémoire, paramètres par défaut pour les
  tests unitaires et d'intégration.
- **Spring Boot** — extension de Spring qui simplifie le développement, les tests et
  le déploiement.

**Bases de données** — voir `03-base-de-donnees.md`.

> **Lecture entre les lignes :** le support consacre un paragraphe à JavaFX pour
> expliquer pourquoi ne *pas* l'utiliser. Sur ce module, l'attendu est clairement
> une API REST Spring Boot, éventuellement consommée par un front React. Ton
> expérience Symfony et React sert directement.

---

## JavaFX

Nécessaire seulement si un TP impose une application de bureau. Depuis le JDK 11,
JavaFX n'est plus livré avec le JDK — c'est une dépendance à part.

SDK : <https://gluonhq.com/products/javafx/>

Ou, plus simple, en dépendance Maven :

```xml
<dependency>
    <groupId>org.openjfx</groupId>
    <artifactId>javafx-controls</artifactId>
    <version>21.0.4</version>
</dependency>
```

---

## H2

Rien à installer : c'est une dépendance Maven. Voir `03-base-de-donnees.md`.

La **console web** s'active dans `application.properties` :

```properties
spring.h2.console.enabled=true
```

Puis <http://localhost:8080/h2-console>. Pense à corriger le champ **JDBC URL** avec
celle de ton fichier de propriétés — la valeur pré-remplie pointe sur une base en
mémoire et n'affichera aucune table.

---

## Clients de base de données

Le support cite **MySQL Workbench** (MySQL uniquement) et **DBeaver** (généraliste),
avec une préférence affichée pour **[DbSchema](https://dbschema.com/)**.

- **[DBeaver Community](https://dbeaver.io/)** — gratuit, ouvre PostgreSQL, MySQL,
  H2, SQLite… Un seul outil pour tout. C'est aussi celui qui te servira pour le
  module Nouveaux paradigmes.
- **DbSchema** — payant, orienté conception visuelle et rétro-ingénierie de schéma.

Pour ouvrir un fichier H2 dans DBeaver, la base doit être **fermée** : H2 en mode
fichier n'accepte qu'une seule connexion. Arrête ton application Spring Boot d'abord.

---

## Docker et JIB

Le support fournit « Créer une image Docker avec JIB ».

**JIB** construit une image Docker **sans Dockerfile et sans démon Docker**. Il
assemble les couches directement depuis Maven. Plus rapide, plus reproductible.

```xml
<plugin>
    <groupId>com.google.cloud.tools</groupId>
    <artifactId>jib-maven-plugin</artifactId>
    <version>3.4.3</version>
</plugin>
```

```powershell
.\mvnw jib:dockerBuild      # construit l'image dans le Docker local
.\mvnw jib:build            # construit et pousse vers un registre
```

À rapprocher du module **R5.09 Virtualisation avancée**, qui traite Docker et
Kubernetes. Les deux modules se recoupent : autant réutiliser ce que tu y apprends.

---

## Ce que le support dit sur l'IA

Section « IA et programmation », à lire attentivement — elle donne le cadre du prof :

- Objectifs : productivité, efficacité, créativité
- Chatbots cités : ChatGPT, Claude, Gemini, Copilot
- « Connaître l'art du prompt »
- Ne pas divulguer d'informations confidentielles
- Attention aux licences des modèles si tu crées ton propre chatbot
- **« Comprendre le code ou les modifications proposées dont la qualité peut être variable »**
- **« Ne pas faire un simple copier/coller sans réfléchir ! »**

Ça rejoint le barème de la SAÉ 5 : la réalisation technique ne suffit plus comme
critère, l'évaluation regarde aussi les contributions au dépôt et la capacité à
expliquer son code. Autrement dit, savoir justifier ce qu'on rend.
