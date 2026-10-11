
# Threat Detection

---

## Overview

This repository contains practical cybersecurity investigations focused on threat detection, log analysis and incident investigation across Linux and Windows environments.

Each write-up documents a security investigation from a SOC analyst's perspective, focusing on identifying suspicious activity, correlating evidence, reconstructing attack sequences and documenting relevant Indicators of Compromise (IOCs).

The projects cover web shell detection, Windows Command and Control (C2) activity and persistence mechanisms and Linux threats such as command injection, credential exposure, privilege escalation attempts and persistence-related artifacts.

The objective is to develop practical threat detection and investigation skills while demonstrating how security telemetry supports evidence-based findings and defensive recommendations.

---

## Repository Structure

    threat-detection/
    │
    ├── detecting-web-shells/
    │   ├── README.md
    │   └── images/
    │
    ├── windows-threat-detection-3/
    │   ├── README.md
    │   └── images/
    │
    ├── linux-threat-detection/
    │   ├── README.md
    │   └── images/
    │
    └── README.md

---

## Write-Ups

| Project | Environment | Focus Areas |
|---|---|---|
| [Detecting Web Shells](./detecting-web-shells/README.md) | Linux / Apache / WordPress | Apache log analysis, web shell detection, suspicious command execution, file upload activity, IOC identification and post-compromise reconnaissance. |
| [Windows Threat Detection 3: Command, Persistence & Impact](./windows-threat-detection-3/README.md) | Windows | Windows Security and Sysmon log analysis, C2 detection, suspicious authentication, privileged account creation and persistence mechanisms. |
| [Linux Threat Detection and Incident Investigation](./linux-threat-detection/README.md) | Linux | Audit log analysis, command injection, credential exposure, privilege escalation attempts, systemd and cron persistence and SSH-related investigation. |

---

## Skills Demonstrated

- **Log Analysis:** investigating Apache access logs, Linux audit records, Windows Security events and Sysmon telemetry.
- **Threat Detection:** identifying suspicious command execution, web shells, C2 activity and persistence-related behavior.
- **Incident Investigation:** correlating evidence from multiple sources to reconstruct attack sequences and build incident timelines.
- **IOC Identification:** documenting suspicious IP addresses, domains, file paths, executables, accounts and persistence artifacts.
- **Persistence Detection:** investigating Windows services, scheduled tasks, systemd services, cron jobs and SSH authorized keys.
- **Authentication and Privilege Analysis:** reviewing suspicious login activity, account creation, privileged group membership and privilege escalation attempts.
- **Host-Based Investigation:** examining file systems, application behavior, process execution and system configuration artifacts.
- **Evidence-Based Reporting:** distinguishing confirmed observations from unverified hypotheses and documenting findings with supporting evidence.
- **Security Hardening:** recommending improvements to access control, credential protection, application security, monitoring and incident response.

---

## Tools Used

- **Linux**
- **Apache**
- **WordPress**
- **Windows Event Viewer**
- **Command Prompt (CMD):** command-line investigation and controlled artifact validation.



