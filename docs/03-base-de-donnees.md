# H2 et MySQL dans Spring Boot

D'après le support « Configuration MySQL ou H2 » du module, avec les corrections
nécessaires pour Spring Boot 3 / Hibernate 6.

---

## Le choix du prof

> « L'objectif est la qualité de développement. Ce module n'est pas dédié aux bases
> de données et a peu d'heures. »

D'où **H2** : une base rapide et légère, suffisante pour des prototypes et des
tests. MySQL reste possible si le projet en a besoin.

| | H2 | MySQL |
|---|---|---|
| Installation | aucune, c'est une dépendance Maven | serveur à installer |
| Stockage | en mémoire, ou dans un fichier | serveur permanent |
| Usage | prototypes, tests unitaires | production |
| `ddl-auto` par défaut | `create-drop` | `none` |

---

## Dépendance Maven

Dans `pom.xml`, en `runtime` — le driver n'est chargé qu'à l'exécution, pas à la
compilation.

**H2**

```xml
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>
```

**MySQL**

```xml
<dependency>
    <groupId>com.mysql</groupId>
    <artifactId>mysql-connector-j</artifactId>
    <scope>runtime</scope>
</dependency>
```

> `mysql-connector-j` remplace l'ancien `mysql-connector-java`, qui est déprécié.
> Un tutoriel qui donne l'ancien nom date d'avant 2022.

---

## application.properties

**H2 persistant dans un fichier**

```properties
spring.application.name=NomDuProjet

spring.datasource.url=jdbc:h2:file:./data/myDB
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password

spring.jpa.hibernate.ddl-auto=update

# Console web : http://localhost:8080/h2-console
spring.h2.console.enabled=true
```

`jdbc:h2:file:./data/myDB` crée un dossier `data/` à la racine du projet.
**À mettre dans le `.gitignore`** — c'est une base de travail, pas du code.

Pour une base purement en mémoire, remise à zéro à chaque démarrage :
`jdbc:h2:mem:myDB`.

**MySQL**

```properties
spring.application.name=NomDuProjet

spring.datasource.url=jdbc:mysql://localhost:3306/myDB?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=motdepasse
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

### Deux corrections par rapport au support

**Le dialecte ne se déclare plus.** Le support indique :

```properties
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
```

`MySQL8Dialect` est **déprécié depuis Hibernate 6** (donc Spring Boot 3). Hibernate
détecte le dialecte tout seul à partir de la connexion. **Supprime la ligne.** Si tu
tiens vraiment à la garder, écris `org.hibernate.dialect.MySQLDialect`, sans le 8.

**Le mot de passe n'a rien à faire dans le fichier.** Utilise une variable
d'environnement :

```properties
spring.datasource.password=${DB_PASSWORD}
```

Un `application.properties` avec le mot de passe root en clair, committé sur GitHub,
c'est le genre de détail qui coûte des points — et qui, en entreprise, coûte bien plus.

---

## Le paramètre ddl-auto

Il décide de ce qu'Hibernate fait au schéma de la base au démarrage.

| Valeur | Effet |
|---|---|
| `none` | ne touche à rien |
| `update` | ajoute les tables et colonnes manquantes, ne supprime jamais |
| `create` | recrée tout à chaque démarrage, ne supprime pas à l'arrêt |
| `create-drop` | recrée au démarrage, **supprime à l'arrêt** |
| `validate` | vérifie que le schéma correspond aux entités, sans rien modifier |

**En pratique :**

- Première exécution → `create` ou `update`, pour initialiser la structure
- Ensuite → `update` si le modèle bouge encore, `none` si le schéma est figé
- Tests unitaires → `create-drop`, chaque test part d'une base propre

`update` a une limite qu'il faut connaître : il **n'applique jamais de suppression**.
Renommer un champ dans une entité crée une nouvelle colonne et laisse l'ancienne en
place, avec ses données. Sur un vrai projet, on passe à Flyway ou Liquibase pour
versionner les migrations.

**Attention à `create-drop` :** c'est la valeur par défaut pour H2 et les bases
embarquées. Si tu configures H2 en mode fichier mais que tu ne fixes pas `ddl-auto`,
tes données disparaissent à chaque arrêt de l'application.

---

## Vérifier que ça marche

Console H2 : lancer l'application, ouvrir <http://localhost:8080/h2-console>.
Le champ **JDBC URL** doit reprendre exactement l'URL du fichier de propriétés,
`jdbc:h2:file:./data/myDB` — la valeur pré-remplie est celle d'une base en mémoire
et ne montrera aucune table.

Pour voir les requêtes générées par Hibernate :

```properties
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
```

Utile pour comprendre ce que fait le mapping, et repérer les requêtes N+1.

---

Documentation officielle : <https://spring.io/guides/gs/accessing-data-mysql>
