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

The investigation was conducted by correlating multiple sources of evidence to reconstruct the activity associated with the suspected web shell compromise. The primary source of telemetry was the Apache access log, which provided visibility into HTTP requests made against the WordPress application. This evidence was complemented by host-level file system analysis to establish whether suspicious server-side files were present and to determine their role in the observed activity.

Rather than treating individual requests, files or command executions as isolated events, the investigation focused on identifying relationships between them. Reconnaissance activity, successful resource discovery, file upload requests, access to the newly deployed PHP file, command execution and subsequent tool downloads were analysed as stages of a broader attack sequence.

The analysis therefore follows the incident from both a detection and investigation perspective. Initial sections establish the characteristics of web shells and the telemetry that can be used to detect them, while the later sections apply those concepts to the observed environment and reconstruct the attack using the available evidence.

This approach provides a clearer understanding of how the compromise developed from web application reconnaissance into server-side code execution and subsequent post-compromise activity. It also establishes the evidentiary basis for the indicators of compromise and findings presented later in the report.

---

## 3.1. Web Shell Fundamentals

A web shell is a malicious server-side program that provides an attacker with the ability to execute commands on a compromised web server through web requests. Unlike a conventional remote shell, which typically requires a direct network connection to a command-line service, a web shell can use the application's existing HTTP or HTTPS interface as the communication channel.

Web shells are commonly introduced through vulnerabilities that allow an attacker to write files to a web-accessible location. Insecure file upload functionality is one example, particularly when an application fails to properly validate the uploaded file type, extension, content or destination. Once a server-side script has been successfully placed in an executable web directory, requests to that file may cause the web server to execute attacker-controlled code.

The functionality of a web shell can vary considerably. A minimal implementation may simply accept a command through an HTTP parameter and pass it to an operating system execution function. More advanced web shells may provide authentication mechanisms, file browsing, command history, file upload and download capabilities, or other functionality designed to support continued access to the compromised system.

From a security monitoring perspective, the most important characteristic is the relationship between web activity and operating system activity. A request to a PHP resource may appear legitimate when viewed in isolation, but becomes significantly more suspicious when the same resource accepts arbitrary command parameters and produces command output. This creates an observable connection between HTTP requests recorded by the web server and actions performed on the underlying host.

The privileges available to the web shell are also important when assessing the impact of a compromise. Commands are normally executed within the security context of the web server process, which on Linux systems may commonly be associated with accounts such as `www-data`. Although this account may have limited privileges, it can still provide an attacker with access to application files, configuration data, credentials and other resources available to the web service.

For this reason, web shell investigations should not focus exclusively on identifying a suspicious PHP file. Analysts should also examine how the file was introduced, which requests interacted with it, what commands were executed and whether additional activity occurred after the initial access. These relationships provide the context required to distinguish a potentially malicious web shell from legitimate server-side application functionality.

---

## 3.2. Web Shell Command Execution

During the investigation, the deployed web shell was accessed to verify its ability to execute commands on the compromised server. The `whoami` command was used as an initial test to determine the security context under which commands were being executed.

The command returned `www-data`, indicating that the web shell was executing commands within the security context of the web server process. This is consistent with the account commonly used by web server processes on Linux systems and demonstrates that the malicious script had successfully provided operating system-level command execution through the web application.

![Web shell command execution showing the compromised web server context](images/webshell-whoami.png)

The investigation then continued with basic file system enumeration. Commands such as `ls` were used to identify files accessible from the current working directory, followed by `cat` to inspect the contents of relevant files. This demonstrated that the web shell could be used to interact with the underlying file system rather than being limited to a single predefined command.

![Web shell command execution during file system enumeration](images/webshell-command-execution.png)

The observed behaviour confirms the primary security impact of the web shell. An attacker with access to the malicious PHP file could use HTTP requests as a mechanism for executing operating system commands and retrieving their output from the compromised server.

