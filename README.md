# Nanitor Agent Puppet Module

This Puppet module installs and configures the [Nanitor Agent](https://nanitor.com) on supported Linux systems. It sets up the appropriate package repository, installs the agent, and performs a one-time signup using a `signup_url` from the Nanitor Portal.

## Requirements

- Puppet 5+
- Supported platforms:
  - Debian 12 (bookworm)
  - RHEL 7+ (including Rocky, AlmaLinux, CentOS)

## ⚙️ How It Works

The module:

1. Adds the Nanitor package repository (APT or YUM).
2. Imports the GPG key used to verify packages.
3. Installs the `nanitor-agent` package.
4. Checks whether the agent is already signed up.
5. If not signed up, runs the signup command using the provided `signup_url`.
6. Ensures the Nanitor Agent service is running and enabled on boot.

## 🛠️ Usage

```puppet
class { 'nanitor_agent':
  signup_url => 'https://myinstance.nanitor.net/your-signup-token',
}
```

## 🐧 Platform Compatibility

This module is officially **tested on Debian 12 (bookworm)** and **RHEL 7+**.

However, the Nanitor Agent binary is written in Go and compiled using `CGO_ENABLED=0`, meaning it is fully statically linked and does not rely on system libraries. As a result, it is expected to work on a wider set of distributions, including:

- Debian 10 (buster)
- Debian 11 (bullseye)
- Ubuntu 20.04, 22.04, 24.04
- Linux Mint, Pop!\_OS
- Other compatible systemd-based Linux systems

⚠️ These platforms are **not officially tested**, but are expected to work correctly.

If you experience compatibility issues or confirm successful installs on other distributions, please let us know:

📧 **operations@nanitor.com**

## Support

For technical questions or support requests, contact the Nanitor Operations Team:  
📧 **operations@nanitor.com**

## Attribution

This module is based on the original version created by:

👤 **Sverrir Arason** (<sverrir@sverrir.org>)  
🔗 [https://github.com/samarason](https://github.com/samarason)

We thank him for contributing the first version of this module.

## License

Copyright © 2017–2025  
Nanitor ehf. — All rights reserved.

