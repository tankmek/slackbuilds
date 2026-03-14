[![CI](https://github.com/tankmek/slackbuilds/actions/workflows/slackbuild.yml/badge.svg)](https://github.com/tankmek/slackbuilds/actions/workflows/slackbuild.yml)
[![License: BSD-2-Clause](https://img.shields.io/badge/License-BSD_2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)

# slackbuilds

Personal maintainer workspace for [SlackBuilds.org](https://slackbuilds.org/) contributions. This repository holds build scripts, CI automation, and version history for packages maintained by Michael Edie.

## What this repo is

- Maintainer workspace for developing and testing SlackBuild scripts
- CI validation via GitHub Actions (Slackware 15.0 container, sbopkglint)
- Version history and update tracking
- Automated version bump workflow

## What this repo is not

This is **not** the canonical source for these SlackBuilds. Users should install packages from [SlackBuilds.org](https://slackbuilds.org/). Versions here may differ from what is published upstream.

## Repository layout

```
<package>/          SlackBuild script, .info, slack-desc, and package files
pkgdefs/            JSON configs for download URLs and dependencies
scripts/            Automation helpers
.github/workflows/  CI pipelines for build validation and version updates
```

## Maintained packages

The following table is generated from SlackBuild metadata in the repository.

| Package | Version | Description | Slackware | Status |
|---|---|---|---|---|
| arping | 2.20 | ARP and IP ping utility | 15.0 | maintained |
| coolkey | 1.1.0 | PKCS#11 smart card library | 15.0 | maintained |
| dirb | 222 | Web content scanner | 15.0 | maintained |
| fpc-source | 3.2.2 | Free Pascal Compiler source | 15.0 | maintained |
| lastpass-cli | 1.6.1 | LastPass command-line client | 15.0 | maintained |
| nbtscan | 1.0.35 | NetBIOS nameserver scanner | 15.0 | maintained |
| nwipe | 0.34 | Secure disk eraser | 15.0 | maintained |
| tinyproxy | 1.11.3 | Lightweight HTTP proxy | 15.0 | maintained |
| usbguard | 1.1.3 | USB device access policy framework | 15.0 | maintained |
| zeek | 8.0.6 | Network security monitor | 15.0 | maintained |

## Development workflow

- Do not commit directly to `main`
- Create a feature branch for each package update or change
- Open a Pull Request
- CI workflows validate the build automatically
- Merge after validation passes

## Historical content

This repo may contain older versions or legacy artifacts kept intentionally as part of the maintenance record.

## Official source

For installing these packages, visit [SlackBuilds.org](https://slackbuilds.org/).

## Maintainer

Michael Edie
