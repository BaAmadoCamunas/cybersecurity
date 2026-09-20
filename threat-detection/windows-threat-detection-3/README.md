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

---

# 3. Evidence Analysis

The investigation was conducted using Windows Security and Sysmon event logs collected from the compromised host. The analysis focused on reconstructing the threat actor's activity across Command and Control and multiple persistence mechanisms.

---

## 3.1. Command and Control Setup

The investigation began by examining Sysmon logs from:

```plaintext
C:\Users\Administrator\Desktop\Practice\Task 2\Sysmon.evtx
```

The first stage of the analysis focused on identifying evidence of the Command and Control infrastructure established by the threat actor.

A suspicious archive named **`URGENT!.zip`** was identified as having been downloaded to the compromised host. The archive represented the initial artifact associated with the subsequent deployment of the C2 component.

![C2 Archive Download](images/c2-archive-download.png)

Further analysis identified the C2 malware executable as **`update.exe`**, located in the following directory:

```plaintext
C:\Users\Administrator\AppData\Roaming\update.exe
```

The use of a generic filename such as `update.exe` and its placement within the user's `AppData\Roaming` directory were considered relevant indicators for further investigation.

![C2 Malware Location](images/c2-malware-location.png)

Network-related Sysmon events were then examined to identify external communication associated with the suspicious executable. The analysis identified the following domain:

```plaintext
route.m365officesync.workers.dev
```

The relationship between the malicious executable and this external domain provided evidence consistent with a C2 communication channel.

![C2 Network Connection](images/c2-network-connection.png)

The resulting C2 activity can therefore be summarized as:

```text
URGENT!.zip
     ↓
update.exe
     ↓
C:\Users\Administrator\AppData\Roaming\update.exe
     ↓
route.m365officesync.workers.dev
```

---

## 3.2. Persistence via Backdoored User Account

The investigation then moved to the Windows Security logs to determine whether the threat actor had established an additional account for persistent access.

The analysis focused on:

```plaintext
C:\Users\Administrator\Desktop\Practice\Task 3\Security.evtx
```

Initial authentication events revealed **six failed login attempts** against the `Administrator` account before a successful authentication was observed. This activity was relevant because repeated failed authentication attempts followed by a successful login can indicate an attempt to gain access to a privileged account.

![Persistence Failed Logons](images/persistence-failed-logons.png)

Following the successful authentication, a new local user account named **`support`** was created. The account creation was recorded in the Windows Security logs and provided evidence of a new identity being established on the compromised host.

![Persistence User Creation](images/persistence-user-creation.png)

Further analysis revealed that the newly created `support` account was subsequently added to the **`Administrators`** group. This granted the account elevated privileges on the Windows host and significantly increased its ability to maintain access and perform privileged actions.

![Persistence Admin Group](images/persistence-admin-group.png)

The sequence of events established a clear relationship between the authentication activity and the creation of a privileged account:

```text
Failed Administrator Logons
          ↓
Successful Authentication
          ↓
support Account Created
          ↓
support Added to Administrators
          ↓
Privileged Persistent Access
```

This activity provided evidence of a persistence mechanism based on the creation of a new privileged user account. The combination of the account creation and subsequent administrative group membership made the `support` account an important artifact for detection and incident response.

---

## 3.3. Persistence via Windows Services and Scheduled Tasks

The investigation continued by examining additional persistence mechanisms involving Windows services and scheduled tasks.

The analysis focused on the artifacts available in:

```plaintext
C:\Users\Administrator\Desktop\Practice\Task 4\
```

Two separate persistence mechanisms were identified during the investigation.

The first mechanism involved a Windows service created to maintain persistence for the **Nessie** malware. The service was identified as:

```plaintext
Data Protection Service
```

The creation of a new Windows service provided the malware with a mechanism to execute through the operating system's service infrastructure, allowing the malicious component to remain available beyond the initial compromise.

![Service Persistence](images/service-persistence.png)

The investigation then examined scheduled task activity associated with the **Troy** malware. A scheduled task named:

```plaintext
AmazonSync
```

was identified as another persistence mechanism.

Scheduled tasks can allow malicious programs to execute automatically according to a configured trigger, providing an additional method for maintaining access to a compromised Windows host.

![Scheduled Task Persistence](images/scheduled-task-persistence.png)


The associated `troy.exe` executable was subsequently located and executed from the command line in the controlled lab environment to validate the identified artifact.

![Troy Execution](images/troy-execution.png)


A second execution capture was used to document the resulting behavior. The challenge-specific output has been intentionally omitted from this report.

![Troy Result](images/troy-result.png)


The persistence mechanisms identified in this stage can be summarized as:

```text
Nessie
  ↓
Data Protection Service
  ↓
Windows Service Persistence


Troy
  ↓
AmazonSync
  ↓
Scheduled Task Persistence
```

The identification of multiple independent persistence mechanisms demonstrates how a threat actor can establish redundant methods of maintaining access to a compromised Windows host. Detecting service creation and scheduled task activity is therefore an important component of post-compromise Windows monitoring.

---

## 3.4. Persistence via Run Keys and Startup

The investigation then examined persistence mechanisms associated with Windows user logon activity, focusing on artifacts that could allow malicious programs to execute when a user logs into the system.

The analysis focused on the artifacts available in:

```plaintext
C:\Users\Administrator\Desktop\Practice\Task 5\
```

The first artifact investigated was the **Odin** executable. Sysmon process creation evidence was examined to identify the parent process associated with its execution.

The analysis identified:

```plaintext
C:\Windows\explorer.exe
```

as the parent process of Odin.

![Odin Parent Process](images/odin-parent-process.png)

![Odin Parent Process](images/odin.png)


The relationship between `explorer.exe` and the Odin process was considered relevant when investigating user-logon persistence. Processes launched through mechanisms associated with user logon can inherit `explorer.exe` as their parent process, making process creation telemetry useful for identifying suspicious execution.

The Odin executable was subsequently executed in the controlled lab environment to validate the identified artifact. The program produced the following output:

```text
Done doing bad stuff!
```

![Odin Execution Output](images/odin-execution-output.png)


The investigation then identified another suspicious artifact associated with the **Kitten** malware. Event Viewer evidence was used to locate the executable before it was manually executed in the controlled environment.

![Kitten Malware Location](images/kitten-malware-location.png)


The identified Kitten executable was subsequently executed from the command line to validate the artifact and observe its behavior. The challenge-specific output has been intentionally omitted from this report.

![Kitten Execution](images/kitten-execution.png)


The user-logon persistence investigation can therefore be summarized as:

```text
User Logon Activity
        ↓
explorer.exe
        ↓
 Odin
        ↓
Suspicious Execution


Event Viewer Evidence
        ↓
Kitten Executable Located
        ↓
Controlled Execution
```

These findings demonstrate the importance of correlating process creation and user-logon activity when investigating persistence on Windows systems. A suspicious process launched in the context of a user session may provide valuable evidence when combined with additional telemetry such as Sysmon process creation events, file creation events and registry activity.

---

