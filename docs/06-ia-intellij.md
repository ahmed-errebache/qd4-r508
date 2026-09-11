# Agents IA dans IntelliJ

Support : `IntelliJ - Agents IA.pdf` (R5.08, section Outils complémentaires).
Ce n'est pas un TP — aucun rendu — mais une mise en place d'environnement.

---

## Ce que le support montre

IntelliJ IDEA 2026 expose deux choses distinctes qu'il ne faut pas confondre :

| | Rôle | Où |
|---|---|---|
| **AI Assistant** | chat intégré à l'IDE, complétion en ligne, génération de messages de commit | panneau *AI Chat*, mode **Chat** |
| **Agents** | outils autonomes qui lisent et modifient les fichiers du projet | même panneau, sélecteur en bas à gauche |

Agents disponibles en bundle : **Claude Agent**, **Codex**, **GitHub Copilot**,
**Junie** (celui de JetBrains). D'autres s'ajoutent via *Install From ACP
Registry* — une centaine de références.

Réglages : `Settings → Tools → AI Assistant`, avec les sous-sections *Agents*,
*Providers & API keys*, *Model Context Protocol (MCP)*, *Prompt Library*,
*Rules*, *Skills*, *Trusted Domains*.

---

## Le point principal : brancher un modèle local

`Settings → Tools → AI Assistant → Providers & API keys` → section
**Third-party AI providers**.

1. Dans **LM Studio** : télécharger un modèle adapté au matériel, le charger,
   puis onglet *Developer* → **Local Server** → démarrer.
   Le serveur écoute sur `http://127.0.0.1:1234`, en API **compatible OpenAI**.
2. Dans IntelliJ : Provider = **LM Studio**, URL = `http://127.0.0.1:1234`,
   puis **Test Connection**.
3. **Model Assignment** : choisir le modèle pour *Core features* et
   *Instant helpers*, et fixer la *Context window*.

Le support est franc sur le compromis :

> aucun coût · vitesse d'inférence très faible, surtout avec une fenêtre de
> contexte élevée · réponses moins bonnes qu'un modèle « dernier cri »

---

## Ce qu'il faut en retenir pour le module

La section « IA et programmation » du cours pose déjà le cadre :
**« comprendre le code ou les modifications proposées dont la qualité peut être
variable »** et **« ne pas faire un simple copier/coller sans réfléchir ! »**

Un agent qui écrit dans le dépôt rend cette consigne plus concrète, pas moins :

- relire le **diff** avant d'accepter, jamais accepter en bloc ;
- garder des commits séparés et des messages qui disent ce qui a changé — le
  barème regarde les contributions au dépôt ;
- ne pas exposer de code sous NDA ou de secrets à un service tiers (c'est
  d'ailleurs le seul argument réel en faveur du modèle local).

**Côté matériel :** le modèle du support pèse 18 Go sur disque et suppose
autant de VRAM/RAM disponible. Sans GPU dédié confortable, l'expérience est
inutilisable — mieux vaut alors un modèle distant, ou aucun.
