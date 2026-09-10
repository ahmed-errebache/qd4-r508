# Git

Section « Gestion de projets » de la ressource Arche.

> « Maîtriser les dépôts Git est essentiel dans une équipe de développement. »
> Le support privilégie **GitHub**, avec GitHub Desktop pour débuter et le plugin
> **EGit** sous Eclipse.

---

## Configuration initiale

À faire une seule fois par machine :

```bash
git config --global user.name "Ahmed Errebache"
git config --global user.email "ahmed.errebache3@etu.univ-lorraine.fr"
```

**Utilise l'adresse universitaire.** Sur la SAÉ 5, le site du cours précise
qu'« une seule adresse sera utilisée pour les statistiques de contribution au
dépôt ». Un commit signé avec une autre adresse ne te sera pas attribué.

Vérifier :

```bash
git config --global --list
```

---

## Le cycle de base

```bash
git status                  # où j'en suis
git add .                   # préparer les modifications
git commit -m "message"     # enregistrer
git push                    # envoyer sur GitHub
git pull                    # récupérer les modifications des autres
```

## Les branches

```bash
git switch -c feature/api-articles   # créer et basculer
git switch main                      # revenir
git merge feature/api-articles       # fusionner
git branch -d feature/api-articles   # supprimer une fois fusionnée
```

`git switch` remplace `git checkout` pour changer de branche — plus clair, puisque
`checkout` faisait deux choses très différentes.

## Se sortir d'un mauvais pas

```bash
git restore fichier.java             # annuler les modifs non ajoutées
git restore --staged fichier.java    # retirer du staging, garder les modifs
git commit --amend                   # corriger le dernier commit (pas encore poussé)
git reset --soft HEAD~1              # défaire le dernier commit, garder le travail
git log --oneline --graph --all      # visualiser l'historique
```

**`git reset --hard` détruit ton travail sans confirmation.** Ne l'utilise que si tu
es certain de vouloir perdre les modifications en cours.

---

## Écrire des messages de commit

Mauvais : `update`, `fix`, `test`, `wip`, `ça marche`.

Bon : une ligne à l'impératif qui dit **ce que fait** le commit.

```
Ajouter l'endpoint GET /api/articles
Corriger le calcul de TVA sur les lots
Configurer H2 en mode fichier
```

Ce n'est pas de la cosmétique. Sur ce parcours, « des contributions régulières et
significatives sur le dépôt » font partie du barème. Un historique de trois commits
`update` la veille du rendu se voit immédiatement.

---

## Ce qu'il ne faut jamais committer

Le `.gitignore` du dépôt s'en charge, mais retiens le principe :

- `target/`, `build/` — le résultat de compilation se régénère
- `data/` — la base H2 en mode fichier
- `.idea/`, `.settings/`, `.vscode/` — la configuration de ton IDE
- **Tout mot de passe, clé d'API ou token**

Un secret poussé sur GitHub reste dans l'historique même après suppression du
fichier. Il faut réécrire l'historique **et** révoquer le secret. Autant ne jamais
l'y mettre : variables d'environnement, ou fichier `.env` ignoré.

Vérifie avant de committer :

```bash
git status
git diff --staged
```

Si tu vois des dizaines de fichiers inattendus, le `.gitignore` ne fait pas son
travail. Le site de la SAÉ le dit sans détour : « si vous validez des dizaines de
fichiers c'est qu'il y a un problème ».

---

## EGit sous Eclipse

Le plugin est fourni avec les versions récentes d'Eclipse et de Spring Tool Suite.

- Vue **Git Repositories** : `Window → Show View → Other → Git → Git Repositories`
- Importer un projet : `File → Import → Git → Projects from Git`
- Committer : clic droit sur le projet → `Team → Commit`

**GitHub Desktop** est plus simple pour visualiser les différences et gérer les
conflits — le support le présente comme la voie pédagogique, la ligne de commande
restant la voie professionnelle. Les deux se combinent très bien sur le même dépôt.

---

## Créer le dépôt distant

```bash
git init
git add .
git commit -m "Initialiser le dépôt du module R5.08"
git branch -M main
git remote add origin https://github.com/ahmed-errebache/qd4-r508.git
git push -u origin main
```

Le dépôt doit être créé au préalable sur GitHub, **sans** README ni `.gitignore` —
sinon le premier `push` sera rejeté pour historiques divergents.

Si ça arrive quand même :

```bash
git pull --rebase origin main
git push -u origin main
```
