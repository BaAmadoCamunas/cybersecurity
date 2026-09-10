# Snort: Network Detection and Traffic Analysis

A technical analysis of network traffic inspection, IDS/IPS detection, packet logging, PCAP investigation and rule-based threat detection using Snort.

---

# 1. Scenario Overview

Snort is an open-source, rule-based network security tool capable of operating as both an Intrusion Detection System (IDS) and an Intrusion Prevention System (IPS).

The analysis focuses on the inspection of network traffic, packet logging, offline PCAP investigation, IDS/IPS alert generation and the development of custom detection rules. These capabilities provide 
visibility into network activity and allow specific traffic patterns to be identified through configurable detection logic.

The investigation covers both real-time traffic inspection and retrospective analysis of captured network traffic. Different Snort configurations and rule sets are evaluated to demonstrate how detection 
results can vary depending on the applied configuration.

The overall analysis is focused on network-based threat detection and the application of Snort capabilities within a Security Operations Center (SOC) environment.

---

# 2. Investigation Objectives

The investigation aims to evaluate the use of Snort for network-based security monitoring and rule-driven threat detection.

The primary objectives are:

- Analyse network traffic and inspect packet-level information.
- Configure and evaluate packet logging capabilities.
- Detect suspicious network activity using IDS/IPS rules.
- Analyse captured network traffic through PCAP files.
- Develop and test custom Snort detection rules.
- Evaluate how different configurations and rule sets influence detection results.
- Assess the relevance of Snort capabilities within a SOC monitoring and investigation workflow.

---

# 3. Evidence Analysis

## 3.1. Network Traffic Inspection

Snort provides several operating parameters for inspecting network traffic at different levels of detail. Sniffer mode can be used to observe packets directly from a network interface, 
while additional parameters control the amount and type of information displayed.

The main inspection parameters are:

| Parameter | Function |
|---|---|
| `-v` | Displays TCP/IP packet information |
| `-d` | Displays packet payload data |
| `-e` | Displays link-layer information |
| `-X` | Displays packet data in hexadecimal and ASCII format |
| `-i` | Specifies the network interface |

These options allow network traffic to be examined from different perspectives, ranging from basic packet metadata to payload and link-layer information.

The combination of these parameters provides the initial visibility required for packet-level network analysis and supports subsequent investigation and detection activities.
