# SlackBuilds Maintained

This repository hosts my contributions to the
[SlackBuilds.org](https://www.slackbuilds.org) project, providing build
scripts for various software packages on Slackware Linux.

Leveraging SlackBuilds ensures a transparent and reproducible build process,
aligning with Slackware's philosophy of clarity and control.

## Available Packages

| Package        | Description                                                         |
|----------------|---------------------------------------------------------------------|
| `dirb`         | Utility for web content discovery, valuable for security            |
|                | assessments.                                                        |
| `dnsmasq`      | Lightweight DNS forwarder and DHCP server, ideal for local          |
|                | networks.                                                           |
| `fpc-source`   | Source distribution of the Free Pascal Compiler.                    |
| `lastpass-cli` | Command-line interface for secure password management via           |
|                | LastPass.                                                           |
| `usbguard`     | Framework for enforcing policies on USB device access.              |
| `zeek`         | Powerful, open-source network security monitoring engine.           |

## Installation Recommendations

For efficient management and installation of these and a broader range of
SlackBuilds, the [`sbotools`](https://pink-mist.github.io/sbotools/) suite is
the recommended approach.
```bash
sudo sbopkg -r
sudo sbopkg -i zeek
```

## Manual Build Procedure

For building individual packages directly:

1. **Clone the repository:**
   ```bash
   cd /tmp
   git clone https://github.com/tankmek/SlackBuilds.git
   cd SlackBuilds/<package_name>
   ```

2. **Retrieve Source:**
   ```bash
   export SOURCE_URL=$(grep DOWNLOAD= *.info | awk -F'"' '{print $2}')
   curl -O "$SOURCE_URL"
   ```

3. **Verify Integrity:**
   ```bash
   grep MD5SUM= *.info | awk -F'=' '{print $2}' | tr -d '"'
   md5sum "$(basename "$SOURCE_URL")" | awk '{print $1}'
   # Confirm the output matches "$MD5_SUM"
   ```

4. **Execute Build (requires root):**
   ```bash
   sudo su -
   cd /tmp/SlackBuilds/<package_name>
   chmod +x <package_name>.SlackBuild
   ./<package_name>.SlackBuild
   ```

   This generates a standard Slackware package (`.txz`) installable via
   `installpkg`.

---
