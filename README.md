![swiyu GitHub banner](./.resources/swiyuBanner.jpg)

# swiyu - iOS wallet

An official Swiss Government project made by the [Federal Office of Information Technology, Systems and Telecommunication FOITT](https://www.bit.admin.ch/en)
as part of the electronic identity (E-ID) project.

## Table of Contents

- [Overview](#overview)
- [Installation and building](#installation-and-building)
- [swiyu Sandbox Wallet](#swiyu-sandbox-wallet)
- [Missing Features and Known Issues](#missing-features-and-known-issues)
- [Contributions and feedback](#contributions-and-feedback)
- [License](#license)

## Overview

This repository is part of the ecosystem developed for the future official Swiss E-ID.
The goal of this repository is to engage with the community and collaborate on developing the Swiss ecosystem for E-ID and other credentials.
We warmly encourage you to engage with us by creating an issue in the repository.

For more information about the project please visit the [introduction into Public Beta](https://www.eid.admin.ch/en/public-beta-e). The technical documentation of the swiyu Public Beta Trust Infrastructure can be found [here](https://swiyu-admin-ch.github.io/).

## Installation and building

The app requires at least iOS 17.<br/>
The app has been build with Xcode 16.0.

In your terminal, after having cloned the current repository, run the following command:

```bash
make setup
```

The `make` command will set everything up and provide you with an up and running project.

Once in Xcode:
- Select the `swiyu Dev` scheme
- We are using some Macros part of our development process. Make sure to trust them.
- Be aware that it's more appropriate to run on real devices rather than in Simulator because of several restrictions and KeyChain usage
- Finally, just build & run in Xcode with `command + R`

## swiyu Sandbox Wallet

A sandbox version of the swiyu Wallet application is available for integration and testing purposes.

### Availability

The swiyu Sandbox Wallet is **not published in the App Store**. It can be downloaded directly from:

> [https://apps.apple.com/us/app/swiyu-sandbox-wallet/id6771296857](https://apps.apple.com/us/app/swiyu-sandbox-wallet/id6771296857)

This version is intended exclusively for testing against the **Sandbox registries**. It cannot be used with the productive registries.

### Current Limitations

The swiyu Sandbox Wallet currently operates without dedicated backend services. Backend functionality may be added in a future release.

As a result, the following features are **not available**:

- Reporting of non-compliant issuers and verifiers
- App version enforcement
- Key Attestation and Client Attestation
  - Consequently, **hardware-bound credentials cannot be issued**
- e-ID issuance flow

### Supported URI Schemes

The sandbox wallet currently registers only the following URI schemes:

- `openid-credential-offer`
- `openid4vp`
- `swiyu-sandbox`
- `swiyu-verify-sandbox`

## Missing Features and Known Issues

The swiyu Public Beta Trust Infrastructure was deliberately released at an early stage to enable future ecosystem participants. The [feature roadmap](https://github.com/orgs/swiyu-admin-ch/projects/1/views/7) shows the current discrepancies between Public Beta and the targeted productive Trust Infrastructure. There may still be minor bugs or security vulnerabilities in the test system. These are marked as [‘KnownIssues’](https://github.com/swiyu-admin-ch/eidch-ios-wallet/issues) in each repository.

## Contributions and feedback

The code for this repository is developed privately and will be released after each sprint. The published code can therefore only be a snapshot of the current development and not a thoroughly tested version. However, we welcome any feedback on the code regarding both the implementation and security aspects. Please follow the guidelines for contributing found in [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file for details.
