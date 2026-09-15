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

---

# 3. Evidence Analysis

The investigation was conducted by correlating web shell activity, Apache access logs and host-level file system evidence to reconstruct the observed compromise.

The analysis begins by examining the deployed web shell and demonstrating its ability to execute commands on the underlying server. This establishes the security impact of the malicious file before tracing the activity backwards through the Apache logs to identify the source of the attack and determine how the web shell was introduced.

The investigation then follows the activity chronologically, from initial reconnaissance and application discovery through web shell deployment, command execution and post-compromise reconnaissance. Finally, file system analysis is used to locate the malicious script and examine its contents.

This approach allows the individual pieces of evidence to be correlated into a single attack sequence rather than analysed as isolated events.

--- 

## 3.1. Web Shell Command Execution

---

### 3.1.1. Initial Access to the Web Shell

The first stage of the investigation involved interacting with the deployed web shell to establish whether the server-side script provided operating system command execution.

The `whoami` command was used as an initial test to determine the security context under which commands submitted through the web shell were executed. The command returned `www-data`, indicating that the web shell was operating within the security context of the web server process.

![Web shell command execution showing the compromised web server context](images/webshell-whoami.png)

The result demonstrated that the web shell was not simply serving static content. It was capable of passing attacker-controlled commands to the underlying operating system and returning the resulting output through the web application.

---

### 3.1.2. Command Execution

Additional commands were then executed through the web shell to determine the level of interaction available on the compromised host. Directory contents were enumerated using `ls`, followed by `cat` to inspect the contents of relevant files.

![Web shell command execution during file system enumeration](images/webshell-command-execution.png)

This activity demonstrated that the web shell provided interactive access to the underlying file system and could be used to retrieve information from the compromised server.

The observed command execution confirms the primary impact of the web shell: an attacker with access to the malicious server-side script could use the web application as a mechanism for executing operating system commands.

---

## 3.2. Apache Access Log Investigation

