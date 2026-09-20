# Windows Threat Detection 3: Command, Persistence & Impact

---

# 1. Scenario Overview

The investigation takes place on a compromised Windows host where a threat actor has gained initial access and is attempting to maintain control of the system. The objective is to reconstruct the attacker’s activity using Windows Security and Sysmon event logs, identifying evidence of Command and Control (C2), persistence mechanisms and other post-compromise activity.

During the investigation, multiple artifacts are examined across different stages of the attack, including a suspicious archive download, the deployment of a C2 malware component, the creation of a backdoor user account, privilege escalation through group membership and additional persistence mechanisms involving Windows services, scheduled tasks and user logon activity.

The investigation is performed against a controlled Windows environment provided by TryHackMe. The available Security and Sysmon logs are treated as the primary source of evidence, with selected artifacts subsequently validated through controlled execution on the provided host.

The investigation follows a SOC-oriented approach, focusing on the identification, correlation and interpretation of host-based evidence rather than simply identifying individual malicious events.

---

# 2. Investigation Objectives

The investigation aims to determine how the threat actor established and maintained access to the compromised Windows host and to identify the artifacts associated with each stage of the activity.

The primary objectives are:

- Identify evidence of Command and Control activity, including the downloaded payload, malware location and external C2 infrastructure.
- Investigate authentication activity surrounding the compromised `Administrator` account.
- Identify the creation of unauthorized or suspicious user accounts.
- Determine whether newly created accounts were granted elevated privileges.
- Detect persistence through Windows services and scheduled tasks.
- Investigate user-logon persistence mechanisms, including Startup folder and Run key activity.
- Correlate Security and Sysmon events to reconstruct the sequence of attacker actions.
- Validate selected malware artifacts through controlled execution where appropriate.
- Assess the potential impact of maintaining persistent access to the compromised host.
- Identify defensive measures that could help detect and contain similar activity at an earlier stage of an attack.

The investigation ultimately aims to demonstrate how multiple Windows telemetry sources can be correlated to detect post-compromise activity and identify an attack before it progresses toward more significant impact.

