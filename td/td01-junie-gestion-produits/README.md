# TD — Application de gestion de produits, pilotée par un agent IA (Junie)

Module **R5.08 — Qualité de développement** · Ahmed Errebache
Supports : `docs/TD Spring Boot avec Junie 2025-2026.pdf`, `docs/Ollama.pdf`
Projet de référence du prof : `docs/demojunie.zip`

---

## Ce que la séance demande

Deux objectifs, dans cet ordre :

1. **Installer un agent IA dans IntelliJ** (Junie, ou un autre via le registre ACP)
2. **Construire une application de gestion de produits fonctionnelle, uniquement
   à partir de prompts** — puis la comprendre, la corriger et la tester

Le second point est le vrai sujet. Le support le dit lui-même :

> « Les personnes qui ne connaissent pas Spring Boot auront du mal à corriger et
> à améliorer le code […] L'assistant contribue à améliorer la productivité du
> développeur mais celui-ci doit acquérir les connaissances nécessaires à la
> compréhension du code. »

Autrement dit, l'évaluation ne portera pas sur « l'IA a généré le projet », mais
sur ce que tu sais en dire. **Ce fichier ne contient donc pas le code à copier** :
il contient la suite de prompts à jouer, et les réponses aux questions que le TD
pose en chemin — à vérifier toi-même une fois l'application lancée.

---

## Étape 0 — Installer l'agent

`Settings → Plugins → Marketplace` → chercher **Junie** → Install → redémarrer.

Junie apparaît alors dans le panneau **AI Chat**, sélecteur en bas à gauche
(`Chat` ↔ `Claude Agent` / `Codex` / `GitHub Copilot` / `Junie`).

Deux points de vocabulaire, utiles à l'oral :

| | Rôle |
|---|---|
| **AI Chat** (mode Chat) | pose des questions, ne touche à rien |
| **Agent** (Junie, Claude Agent…) | lit et **écrit** les fichiers du projet, lance des commandes |

Le TD utilise les deux : Junie pour produire, l'AI Chat pour comprendre et
déboguer.

> **Alternative locale, gratuite** — support `Ollama.pdf` : installer Ollama,
> `ollama pull llama3.2:3b`, puis le brancher dans
> `Settings → Tools → AI Assistant → Providers & API keys`.
> À réserver au chat : un 3B ne tiendra pas un agent sur un projet Spring Boot.

---

## Étape 1 — Créer le projet

`File → New → Project → Spring Boot` (Spring Initializr).

- Maven · Java 21 · JAR · Spring Boot 3.x (version **GA**)
- Group `com.demojunie`, Artifact `demo-junie`
- Dépendances : **Spring Web**, **Spring Data JPA**, **H2 Database**,
  **Thymeleaf**, **Lombok** (celle-ci par l'onglet recherche)

---

## Étape 2 — Le prompt initial

Ouvrir Junie et coller **exactement** :

```
Créer une application qui permet de gérer des produits (id, name, price,
quantity) en utilisant Spring Boot, Spring Data JPA, H2 Database et Thymeleaf
```

> Le support écrit volontairement `nama` pour montrer que l'agent corrige la
> faute de frappe. Aucun intérêt à la reproduire.

Approuver les propositions, puis **Run** `DemoJunieApplication`.

Structure attendue :

```
com.demojunie
├── DemoJunieApplication.java     + un CommandLineRunner qui insère 3 produits
├── WebConfig.java                redirige / vers /products
└── product
    ├── Product.java              @Entity
    ├── ProductController.java    @Controller (pas @RestController : vues Thymeleaf)
    └── ProductRepository.java    interface JpaRepository
resources/templates
├── products.html
└── product-form.html
```

Vérifier : <http://localhost:8080/products>

---

## Étape 3 — Travail à faire (le TD)

### a) Supprimer tous les warnings

IntelliJ signale que les getters/setters écrits à la main sont remplaçables par
Lombok. Dans le projet du prof, `Product` finit avec `@Getter @Setter` et garde
ses deux constructeurs.

**Attention à `@Data` sur une `@Entity`** : il génère `equals`/`hashCode` sur
tous les champs, y compris l'`id` — ce qui casse le comportement attendu d'une
entité JPA avant et après persistance. `@Getter @Setter` est le bon choix ici.
C'est exactement le genre de point qu'un agent ne soulève pas tout seul.

### b) Changer le port 8080 en 8084

Question du TD : **où ?** → `src/main/resources/application.properties`

```properties
server.port=8084
```

### c) Générer un README

```
Génère un fichier README pour ce projet
```

### d) Console H2

```properties
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
spring.datasource.url=jdbc:h2:mem:productsdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.username=sa
spring.datasource.password=
```

<http://localhost:8084/h2-console>

**Le piège :** le champ *JDBC URL* est pré-rempli avec `jdbc:h2:~/test`. Il faut
le remplacer par la valeur de `spring.datasource.url` ci-dessus, sinon la console
ouvre une base vide et aucune table n'apparaît.

Puis, dans la console :

```sql
INSERT INTO PRODUCT (NAME, PRICE, QUANTITY) VALUES ('Ordi', 899.00, 5);
SELECT * FROM PRODUCT;
```

et rafraîchir `/products` pour voir la ligne apparaître.

### e) Générer les tests unitaires

```
Génère les tests unitaires pour cette application
```

**L'erreur annoncée par le TD**, dans `ProductRepositoryTest` : le
`CommandLineRunner` de `DemoJunieApplication` insère « Clavier », « Souris »,
« Écran » au démarrage du contexte de test. Une recherche sur `SOURIS` renvoie
donc **3** résultats au lieu des 2 attendus.

Correction :

```java
@BeforeEach
void setUp() {
    repository.deleteAll();
}
```

> Le fond du problème n'est pas le test, c'est le **jeu de données de démarrage
> qui fuit dans les tests**. Un test doit partir d'un état connu — c'est le « I »
> de FIRST (*Isolated*). À dire à l'oral si on te demande pourquoi.

### f) Couverture de code

```
Quelle est la couverture du code ? Vérifie.
```

Junie ajoute le plugin **JaCoCo** au `pom.xml` et lance les tests. Rapport :
`target/site/jacoco/index.html` — à ouvrir dans un navigateur.

### g) Tests d'intégration

```
Ajoute les tests d'intégration et un rapport.
```

Question du TD : **que constates-tu dans `test/` ?** Le projet du prof finit avec
cinq fichiers :

| Fichier | Ce qu'il teste |
|---|---|
| `ProductValidationTest` | les annotations `@NotBlank`, `@DecimalMin`… sans Spring |
| `ProductRepositoryTest` | la couche JPA (`@DataJpaTest`) |
| `ProductControllerWebMvcTest` | la couche web seule (`@WebMvcTest`, repository simulé) |
| `ProductIntegrationTest` | l'application entière (`@SpringBootTest`) |
| `ProductDataSeedIntegrationTest` | que le `CommandLineRunner` insère bien ses 3 produits |

C'est la **pyramide des tests** : beaucoup de tests unitaires rapides et isolés,
quelques tests d'intégration lents mais qui vérifient l'assemblage. La couverture
monte parce que les tests d'intégration traversent du code que les tests unitaires
ne touchent pas.

### h) Dépôt GitHub

```
Faites un dépôt du projet demo-junie sur mon compte github.
```

Junie crée `.gitignore` et `.github/workflows/ci.yml`.

**L'erreur de permission annoncée par le TD** : sous Linux (le runner GitHub),
`mvnw` n'a pas le bit exécutable après un checkout depuis Windows. D'où :

```
corrige le fichier ci.yml car il y a une erreur de permission pour lancer mvn
```

La correction attendue est une étape supplémentaire avant le build :

```yaml
- name: Grant execute permission for Maven Wrapper
  run: chmod +x mvnw

- name: Build and test
  run: ./mvnw -q -e -B clean verify
```

Puis commit, push, et vérifier l'onglet **Actions** sur GitHub.

---

## Étape 4 — Les prompts « à faire » de la fin du TD

À poser à l'**AI Chat** (pas à l'agent : ce sont des questions, pas des
modifications) :

```
Pour le plugin lombok en Java, fais moi une liste des annotations et de leur usage.
Génère un tableau en Word.
Quelle est l'annotation qui permet l'écriture du code comme en POJO ?
POJO versus lombok pour les tests unitaires ?
```

Les deux réponses attendues, pour que tu puisses juger celles de l'IA :

**« l'annotation qui permet d'écrire comme en POJO »** → **`@Data`**. Elle
regroupe `@Getter`, `@Setter`, `@ToString`, `@EqualsAndHashCode` et
`@RequiredArgsConstructor` : la classe s'écrit avec ses seuls champs, et se
comporte comme un POJO complet. (`@Value` en est la version immuable.)

**POJO vs Lombok pour les tests unitaires** → le bytecode produit est le même,
donc les tests sont identiques à écrire. Les vraies différences :

- Lombok génère `equals`/`hashCode` sur **tous** les champs : sur une entité JPA,
  ça casse les comparaisons entre objet persisté et non persisté
- le débogueur ne pose pas de point d'arrêt dans un getter généré
- la couverture JaCoCo compte le code généré, ce qui **gonfle artificiellement**
  le pourcentage — argument direct pour ce module

---

## Étape 5 — `toString` → `StringBuilder`

Dernier travail à faire du TD. La concaténation dans une boucle crée un nouvel
objet `String` à chaque tour ; `StringBuilder` travaille sur un tampon unique.

Sur un `toString()` d'une classe à trois champs la différence est nulle en
pratique — **le compilateur convertit déjà les concaténations simples en
`StringBuilder`**. L'exercice est là pour le principe, pas pour le gain. Dire
cela en soutenance vaut mieux que de réciter « StringBuilder c'est plus rapide ».

---

## Rendu et honnêteté

Pas de rendu annoncé pour cette séance. Mais pour la SAÉ 5 comme pour ce module,
le barème regarde les contributions au dépôt et la capacité à expliquer son code.
Un projet généré à 90 % par un agent se repère ; un projet généré à 90 % par un
agent **dont l'auteur sait expliquer chaque fichier** ne pose aucun problème —
c'est précisément ce que le support demande.

Les deux consignes du cours, à garder en tête :

> « Comprendre le code ou les modifications proposées dont la qualité peut être
> variable » · « Ne pas faire un simple copier/coller sans réfléchir ! »
