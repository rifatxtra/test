# Virtualmin GPL (Custom Fork)

This is a modified version of Virtualmin GPL that enables features typically restricted to the Pro version.

## Key Features

1. **Shared Disk Quota**
      - Users have a _single_ disk quota shared across all their domains.
      - Limits are aggregated: If a user has a 10GB limit, it applies to the total usage of all their websites combined.

2. **Shared RAM (Process Pool)**
      - Enabled via **Sub-servers**.
      - When users create additional domains as Sub-servers of their main account, they share the same Unix user and PHP-FPM worker pool.
      - This allows you to host multiple sites in a single RAM footprint (e.g., 20 sites sharing 512MB RAM).

3. **Multi-Domain Ownership**
      - Server owners are allowed to create multiple Top-level servers (if permitted by the Plan).

## New Plan Limits

To enforce the "Shared RAM" policy, two new limits have been added to **System Settings -> Plans and Templates**:

- **Max top-level servers**: Limit the number of parent accounts (Set to **1** to force shared RAM).
- **Max sub-servers**: Limit the number of add-on domains.

## Installation on VPS

To install this custom version on a fresh VPS (Ubuntu/Debian/CentOS/AlmaLinux):

1. **Clone this repository**:

      ```bash
      git clone https://github.com/rifatxtra/test.git
      ```

2. **Enter the directory**:

      ```bash
      cd test
      ```

3. **Run the setup script**:
      ```bash
      chmod +x setup-vps.sh
      sudo ./setup-vps.sh
      ```

### What the script does:

1. Installs the full official Virtualmin stack (LAMP/LEMP).
2. Removes the stock `virtual-server` module.
3. Installs this custom modified version in its place.
4. Restarts Webmin.
