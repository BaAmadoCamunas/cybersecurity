# Detecting Web Shells

---

# 1. Scenario Overview

Web shells represent a significant security risk because they can transform a compromised web application into a direct interface for operating system command execution. A web shell is typically a malicious 
server-side script that has been placed on a web server through an exploited vulnerability, insecure file upload functionality or another form of unauthorised access. Once successfully deployed, the attacker 
can interact with the compromised host by sending commands through HTTP or HTTPS requests.

The impact of a web shell extends beyond the initial compromise. Depending on the privileges of the web server process, an attacker may use the shell to perform system reconnaissance, access sensitive files, download additional tools, search for credentials, attempt privilege escalation and establish further persistence. This makes web shell activity an important detection opportunity for security monitoring teams, as the initial 
web application compromise can quickly develop into broader host-level activity.

Detecting this type of compromise can be challenging because web shells are often placed inside legitimate application directories or locations intended for user-uploaded content. A malicious PHP file within a WordPress upload directory for example, may initially appear to be an ordinary application resource. However, when its presence is correlated with unusual HTTP requests, suspicious upload activit, and subsequent command execution, the same file can become strong evidence of compromise.

This investigation examines a suspected web shell compromise affecting a WordPress application. The analysis begins with Apache access logs to reconstruct the sequence of requests made against the application and identify the source of the suspicious activity. The investigation then follows the attack through resource discovery and file upload activity before examining subsequent interactions with the deployed web shell.

The investigation also extends beyond web server telemetry to the underlying file system. By locating the malicious script and analysing its contents, the investigation establishes a direct connection between the observed HTTP activity and the server-side file responsible for command execution. This correlation provides a more complete understanding of the compromise than analysing individual log entries in isolation.

The overall objective is to reconstruct the attack from a SOC analyst's perspective, identify the relevant indicators of compromise, determine the extent of the observed activity and extract defensive lessons that can be applied to the detection and prevention of similar web shell attacks.

---

# 2. Objectives

The investigation aims to determine how the suspected web shell compromise occurred, how the attacker interacted with the affected WordPress application and what activity followed the initial compromise. The analysis is focused on reconstructing the attack sequence from the available evidence and establishing a clear relationship between web application activity and actions performed on the underlying server.

The first objective is to identify the source and nature of the suspicious activity recorded in the Apache access logs. This includes determining the originating IP address, identifying the resources targeted by the attacker and distinguishing unsuccessful reconnaissance attempts from requests that resulted in successful access to the application.

The investigation then seeks to determine how the web shell was introduced into the environment. Particular attention is given to file upload activity and the application endpoint associated with the deployment of the malicious script. Establishing this part of the attack chain is important for understanding how the attacker moved from web application reconnaissance to server-side code execution.

A further objective is to establish what actions were performed after the web shell became accessible. The investigation examines requests made to the malicious file, the commands executed through it and any additional files or tools downloaded during the observed activity. This provides insight into the attacker's immediate objectives and helps determine whether the compromise progressed beyond the initial web shell deployment.

Finally, the investigation aims to locate the malicious file on the host and analyse its contents to confirm its role in the compromise. By correlating Apache access logs with file system evidence, the analysis seeks to produce a coherent timeline of the incident and identify reliable indicators that could support future detection, threat hunting and incident response activities.

