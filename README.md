# QD4 — R5.08 Qualité de développement

TD et TP du module **R5.08 (QD4) — Qualité de développement**
BUT 3 Informatique · IUT de Saint-Dié-des-Vosges · 2026-2027

**Ahmed Errebache** — `ahmed.errebache3@etu.univ-lorraine.fr`

Le module porte sur **Java et Spring Boot** : injection de dépendances, API REST
en architecture MVC, persistance avec H2 ou MySQL, build Maven, conteneurisation.

---

## Démarrage rapide

```bash
git clone https://github.com/ahmed-errebache/qd4-r508.git
cd qd4-r508
powershell -ExecutionPolicy Bypass -File .\scripts\verifier-environnement.ps1
```

Le script liste ce qui est installé et ce qui manque. Il ne modifie rien.

## Arborescence

```
qd4-r508/
├── docs/                        Notes de cours et mémos
│   ├── 01-environnement.md      JDK, IDE, variables d'environnement
│   ├── 02-maven.md              Installation et commandes Maven
│   ├── 03-base-de-donnees.md    H2 / MySQL dans Spring Boot
│   ├── 04-outils.md             JavaFX, Docker JIB, Postman, DBeaver
│   └── 05-git.md                Workflow Git et commandes utiles
├── td/                          Un dossier par TD
├── tp/                          Un dossier par TP
└── scripts/
    └── verifier-environnement.ps1
```

## Convention

Un dossier par travail, nommé `td01-sujet`, `tp02-sujet`. Chacun contient son
propre `README.md` avec l'énoncé, la démarche et la manière de le lancer.

Chaque projet Spring Boot est autonome : son `pom.xml`, son `mvnw`, ses sources.
On le lance depuis son dossier avec `./mvnw spring-boot:run`.

## Rappels du module

- Le JDK **17 minimum** est exigé par Spring Boot 3.
- Ne jamais committer `target/`, `data/`, ni un mot de passe — voir `.gitignore`.
- Commits réguliers et lisibles : les contributions au dépôt font partie de
  l'évaluation dans ce parcours.

## Sources

Ressource Arche du module :
<https://arche.univ-lorraine.fr/course/view.php?id=67551>
