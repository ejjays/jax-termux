# Firebase CLI

Deploy and manage Firebase projects (Hosting, Functions, Firestore, Auth, Storage)

**Package:** firebase-tools  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://firebase.google.com/docs/cli  
**Type:** Node.js global module (npm)  
**License:** MIT

## Description

Firebase CLI manages Firebase projects from the terminal: deploy Hosting and Cloud Functions, run Firestore and Auth emulators, and manage project configuration.

## Dependencies

- Node.js LTS (nodejs-lts)

## Install

```bash
jax install npm --firebase
```

## Uninstall

```bash
jax uninstall npm --firebase
```

## Update

```bash
jax update npm --firebase
```

## Notes

- Command: `firebase`
- Login with `firebase login --no-localhost` on Termux
- Emulators run locally with `firebase emulators:start`
