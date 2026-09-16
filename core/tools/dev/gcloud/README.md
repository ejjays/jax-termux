# Google Cloud CLI

Official CLI for Google Cloud and Firebase project management (`gcloud`, `gsutil`, `bq`)

**Package:** google-cloud-cli (tarball, linux-arm / linux-x86_64)  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://cloud.google.com/sdk/docs  
**Type:** Development tool (binary)  
**License:** Apache 2.0

## Description

`gcloud` manages Google Cloud projects, IAM service accounts, and Firebase
projects from the terminal. Installed alongside `gsutil` (Cloud Storage) and
`bq` (BigQuery). Ships its own Python, so no extra runtime is needed.

## Dependencies

- curl, tar, python3 (auto-installed via `pkg`)

## Install

```bash
jax install dev --gcloud
```

## Login (Termux has no browser handoff, use the printed URL)

```bash
gcloud auth login --no-launch-browser
gcloud config set project <project-id>
gcloud projects list
```

## Uninstall

```bash
jax uninstall dev --gcloud
```

Login and config in `~/.config/gcloud` are kept on uninstall.

## Update

```bash
jax update dev --gcloud
```

## Notes

- Commands: `gcloud`, `gsutil`, `bq`
- SDK lives in `~/.local/share/core-termux-data/gcloud`
- First run never phones home: usage reporting is disabled at install
