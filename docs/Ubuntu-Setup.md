# Ubuntu Server 24.04.1 Setup Guide

This guide walks you through the steps to configure the initial boot settings for an Ubuntu Server 24.04.1 virtual machine.

---

## 1. Start the Virtual Machine
- Boot the VM using the installation medium (ISO file or disk).
- If prompted, select the installation medium.

---

## 2. Select Language
- Choose your preferred language and press **Enter**.

---

## 3. Configure Keyboard Layout
- Select your keyboard layout or customize it if needed.
- Press **Enter** to confirm.

---

## 4. Network Configuration
- The installer will try to configure networking automatically via **DHCP**.
  - If it succeeds, you’ll see the assigned IP address.
  - If manual configuration is required:
    1. Select **Configure network manually**.
    2. Enter the static IP, subnet mask, gateway, and DNS information.

---

## 5. Configure Proxy (Optional)
- If your network requires a proxy, provide the details.
- Leave this blank if no proxy is needed.

---

## 6. Configure Mirrors
- Use the default mirror for updates or customize it based on your needs.

---

## 7. Partition Disks
- Select **Use an entire disk** for automatic partitioning.
  - Advanced users can choose **Custom storage layout** for manual configuration.
- Confirm the changes and proceed.

---

## 8. Create User and Hostname
- Provide the following information:
  - **Your name**: Full name or alias.
  - **Server name**: The hostname of the server (e.g., `ubuntu-server`).
  - **Username**: Primary user’s name (e.g., `adrian`).
  - **Password**: Create a strong password.

---

## 9. Install OpenSSH Server 
- Select **Yes** to install OpenSSH during setup.

---

## 10. Select Featured Server Snaps (Optional)
- Choose from the provided list of commonly used server applications or skip.

---

## 11. Wait for Installation
- The installation process will take a few minutes.
- Monitor for any errors during the process.

---

## 12. Reboot System
- Remove the installation medium (ISO) when prompted.
- Reboot the server to complete the setup.

---

## 13. Login to the Server
- Use the username and password you created during the setup process.

---

## 14. Update and Upgrade Packages
- Update the server to ensure it’s up to date:
  ```bash
  sudo apt update && sudo apt upgrade -y
