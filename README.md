# Kitsune Sentry - Threat Intelligence

**Version:** 1.0  
**Context:** ISO/IEC 27001 Proof of Concept (Control A.16.1 - Incident Management)

## Overview

**Kitsune Sentry** is a lightweight, Bash-based URL reputation scanner designed for Incident Response teams. It allows security analysts and staff to verify the safety of suspicious links without visiting them directly, leveraging the **VirusTotal API v3**.

This tool supports compliance with **ISO 27001 Control A.16.1 (Information Security Incident Management)** by providing a rapid method to assess potential threats during the initial triage phase of an incident.

## Prerequisites

Before using the scanner, ensure you have the following installed on your Linux system:

*   **curl**: For making API requests.
*   **jq**: For parsing JSON responses.

To install dependencies on Debian/Ubuntu:

```bash
sudo apt update
sudo apt install curl jq
```

## Setup Instructions

### 1. Obtain a VirusTotal API Key

1.  Go to [VirusTotal](https://www.virustotal.com/) and create a free account.
2.  Once logged in, click your username in the top-right corner and select **API Key**.
3.  Copy your personal **API Key**.

### 2. Configure the Script

1.  Open `kitsune_scanner.sh` in a text editor.
    ```bash
    nano kitsune_scanner.sh
    ```
2.  Locate the configuration line at the top:
    ```bash
    VT_API_KEY="YOUR_API_KEY_HERE"
    ```
3.  Replace `YOUR_API_KEY_HERE` with the API key you copied.
4.  Save and exit.

### 3. Make Executable

Grant execution permissions to the script:

```bash
chmod +x kitsune_scanner.sh
```

## Usage

Run the script by providing a target URL as an argument:

```bash
./kitsune_scanner.sh <url>
```

**Example:**

```bash
./kitsune_scanner.sh www.example.com
```

### Output Interpretation

*   **GREEN (CLEAN):** No security vendors flagged the URL as malicious.
*   **RED (DANGER):** One or more security vendors have flagged the URL. Proceed with extreme caution.

## Disclaimer

This tool is provided for **educational and internal audit purposes only**. It is a Proof of Concept (PoC) and should not be the sole mechanism for determining the safety of a URL. The authors rely on third-party data (VirusTotal) and are not responsible for any false positives or negatives. Always follow your organization's established Incident Response procedures.
