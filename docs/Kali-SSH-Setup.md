# SSH Setup and Connection Guide: Kali Linux to ELK and Threat Intel VMs

This guide provides step-by-step instructions for setting up SSH on Kali Linux and using it to establish connections to the ELK and Threat Intel VMs.

---

## Prerequisites

- **Kali Linux VM** is installed and running.
- **Ubuntu VMs** (ELK and Threat Intel) are installed and accessible over the network.
- Both Ubuntu VMs have static IPs or are reachable through the internal network.

---

## Step 1: Configure SSH on Kali linux

1. **Check if SSH is Installed and Running on Kali:**
    ```bash
    sudo systemctl status ssh
    ```
 - If not running, start and enable it
    ```bash
    sudo systemctl start ssh
    sudo systemctl enable ssh
    ```
2. **Generate an SSH Key Pair:**
   ```bash
   ssh-keygen -t rsa -b 4096
   ```
 - Save the key pair in the default location (```~/.ssh/id_rsa```)

3. **Copy Public Key to both Ubuntu Servers:**
 - Replace ```<username>``` with your Ubuntu VM's username and ```<IP>``` with the VM's IP address:
    ```bash
    ssh-copy-id <username>@<IP_of_ELK_VM>
    ssh-copy-id <username>@<IP_of_ThreatIntel_VM>
    ```
4. **Test SSH Connections:**
    ```bash 
    ssh <username>@<IP_of_ELK_VM>
    ssh <username>@<IP_of_ThreatIntel_VM>
    ```