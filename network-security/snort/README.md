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
