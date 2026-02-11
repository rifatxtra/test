# Installation Guide

This guide explains how to install this custom Virtualmin GPL version on a fresh VPS.

## Prerequisites

- **OS:** Ubuntu 20.04 LTS or 22.04 LTS (Recommended), Debian 10/11, CentOS 7/8.
- **Fresh Install:** It is highly recommended to use a server with NO previous control panel installed.

## Quick Install

Run these commands as `root`:

1. **Clone the Repository:**

      ```bash
      git clone https://github.com/rifatxtra/test.git
      cd test
      ```

2. **Run the Setup Script:**

      ```bash
      chmod +x setup-vps.sh
      sudo ./setup-vps.sh
      ```

      **What this does:**
      - Installs the full official Virtualmin stack (LAMP).
      - Replaces the stock `virtual-server` module with this custom version.
      - **Automatically fixes** common SQL configuration errors (`mysql_mail=0`).

## Post-Installation

1. **Access Virtualmin:**
   Open your browser and go to: `https://YOUR_SERVER_IP:10000`

2. **Login:**
      - **Username:** `root`
      - **Password:** Your VPS root password.

      _(If you don't know the root password, reset it via SSH: `sudo passwd root`)_

3. **Post-Install Wizard:**
   Follow the on-screen wizard to configure your server.

## Troubleshooting

### 1. "Failed to login to database cyberpanel" / Postfix Error

If your VPS previously had **CyberPanel** installed, Postfix might still be trying to use its database.

**Fix:**
Run the included cleanup script:

```bash
sudo sh clean-postfix.sh
```

### 2. "Column 'email' specified twice"

This error occurs if "Store mail aliases in database" is enabled but the database is not configured correctly.
**Note:** The `setup-vps.sh` script now fixes this automatically.

If you still see it, run:

```bash
sudo sh fix-sql-config.sh
```

### 3. Cannot Access Port 10000 (Google Cloud / AWS)

Cloud providers often block port 10000 by default.

**Fix (Google Cloud):**

1. Go to **VPC Network -> Firewall**.
2. Create a rule named `allow-webmin`.
3. Target: "All instances".
4. Source IP ranges: `0.0.0.0/0`.
5. Protocols/ports: `tcp:10000`.
6. Save.
