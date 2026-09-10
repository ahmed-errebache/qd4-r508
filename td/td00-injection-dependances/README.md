# TD0 — Injection de dépendances avec Spring Boot

Module **R5.08 — Qualité de développement** · Ahmed Errebache

---

## Le sujet

Le projet fourni par l'enseignant (`5. Projet Spring Boot students.zip`) est un
**squelette** : son README annonce les paquets `controller/`, `service/` et
`repository/`, mais l'archive ne contient que `StudentsApplication`. Le travail
consiste à écrire ces classes en appliquant l'injection de dépendances vue en cours.

## Lancer

```bash
cd td/td00-injection-dependances
mvn spring-boot:run
```

## Tester

```bash
# Ajouter un étudiant
curl.exe -X POST "http://localhost:8080/students/add?name=Paul"

# Lister
curl.exe http://localhost:8080/students
```

> Sous PowerShell, écrire **`curl.exe`** et non `curl` : `curl` y est un alias
> d'`Invoke-WebRequest`, qui n'accepte pas la même syntaxe.

Lancer les tests :

```bash
mvn test
```

---

## Ce qui a été écrit

```
com.example.students
├── StudentsApplication.java          point d'entrée, @SpringBootApplication
├── controller
│   └── StudentController.java        @RestController — couche web
├── service
│   └── StudentService.java           @Service — logique métier
└── repository
    ├── StudentRepository.java        l'interface : le contrat
    ├── InMemoryStudentRepository.java @Repository @Primary
    └── ConsoleStudentRepository.java  @Repository — implémentation alternative
```

Chaîne d'injection : `StudentController` → `StudentService` → `StudentRepository`.
Aucun `new` n'est écrit par le développeur, c'est le conteneur IoC qui construit
et relie les objets.

---

## Choix de conception

### Injection par constructeur, pas `@Autowired`

Le support présente les trois formes. J'ai retenu **l'injection par constructeur** :

| Forme | Inconvénient |
|---|---|
| Sur l'attribut | le champ ne peut pas être `final` ; impossible d'instancier la classe sans Spring, donc les tests unitaires deviennent lourds |
| Sur le setter | la dépendance devient optionnelle : l'objet peut exister dans un état incomplet |
| **Sur le constructeur** | aucun — la dépendance est obligatoire et l'objet immuable |

Détail qui surprend souvent : **`@Autowired` est facultatif depuis Spring 4.3**
quand la classe n'a qu'un seul constructeur. Son absence dans le code n'est pas
un oubli, c'est la pratique actuelle.

### Deux implémentations du repository

Le support conclut : « on peut facilement remplacer `StudentRepositoryImpl` par
un `FakeStudentRepository` pour les tests ». J'ai poussé l'idée jusqu'au bout en
fournissant **deux implémentations réelles**.

Conséquence immédiate : deux beans candidats pour la même interface. Spring
refuse alors de démarrer avec :

```
NoUniqueBeanDefinitionException: expected single matching bean but found 2
```

Deux façons d'arbitrer :

- **`@Primary`** sur l'implémentation par défaut — le choix fait ici
- **`@Qualifier("consoleStudentRepository")`** au point d'injection, pour nommer
  explicitement le bean voulu

C'est une erreur qu'on rencontre dès qu'un projet grossit ; autant l'avoir
provoquée volontairement une fois.

### Les tests

`StudentServiceTest` n'utilise **ni Spring, ni base de données, ni serveur** : il
construit le service à la main avec un faux repository.

C'est la démonstration concrète de l'intérêt de la DI. Avec la version « sans DI »
du support — un `new StudentRepository()` en dur dans le service — ce fichier
serait impossible à écrire.

---

## Une correction apportée au `pom.xml` fourni

Le `pom.xml` du prof déclare :

```xml
<properties>
  <java.version>17</java.version>
</properties>
```

**Cette propriété n'a aucun effet ici.** `java.version` n'est interprétée que par
`spring-boot-starter-parent`, or ce `pom.xml` n'en hérite pas : il importe
`spring-boot-dependencies` en `dependencyManagement`. Le compilateur reste donc
sur sa cible par défaut.

J'ai ajouté la propriété réellement lue :

```xml
<maven.compiler.release>17</maven.compiler.release>
<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
```

J'ai aussi versionné explicitement `spring-boot-maven-plugin` — sans le parent,
il n'hérite d'aucune version et Maven échoue au `spring-boot:run`.

---

## Rappel du cours

**Injection de dépendances** : les objets dont une classe a besoin ne sont pas
créés par elle, mais fournis de l'extérieur. But : réduire le couplage, faciliter
les tests et la maintenance.

**IoC Container** : Spring scanne le projet au démarrage, repère les classes
annotées, les instancie, et les injecte là où elles sont attendues.

| Annotation | Où | Création du bean |
|---|---|---|
| `@RestController` | classe | automatique (component scan) |
| `@Service` | classe | automatique |
| `@Repository` | classe | automatique |
| `@Component` | classe | automatique |
| `@Bean` | méthode d'une classe `@Configuration` | manuelle |

Le `@ComponentScan` inclus dans `@SpringBootApplication` ne scanne que le package
de la classe principale **et ses sous-packages**. Une classe annotée placée en
dehors ne sera jamais détectée — c'est la cause la plus fréquente d'un bean
introuvable au démarrage.
