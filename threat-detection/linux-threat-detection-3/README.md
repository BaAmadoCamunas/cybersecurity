# Linux Threat Detection and Incident Investigation

# 1. Scenario Overview

This report documents a Linux security investigation focused on identifying suspicious activity associated with potential system compromise. The analysis examines host-level artifacts, command execution, privilege escalation attempts and persistence mechanisms to reconstruct relevant post-compromise activity.

The investigation follows a threat detection approach, correlating audit records, authentication logs, application behavior, and system configuration artifacts to identify potentially unauthorized actions and assess their security implications.

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



