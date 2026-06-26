# The Greenholt Phish

# 1.Scenario Overview

A sales executive at Greenholt PLC reported a suspicious email allegedly received from a known customer. The employee noticed several unusual characteristics, including a generic greeting, an unexpected request involving a financial transaction and an unsolicited attachment. According to the recipient, these elements did not match the customer's normal communication patterns.

Due to the potential risk of phishing or business email compromise (BEC), the email was escalated to the Security Operations Center (SOC) for further analysis.

The objective of this investigation was to determine whether the email was legitimate or malicious by examining its contents, verifying its origin and identifying any indicators of compromise (IOCs).

---

# 2.Investigation Objectives

- Analyze the email and extract relevant artifacts.
- Verify the authenticity and origin of the message.
- Identify indicators commonly associated with phishing activity.
- Assess the attachment and any suspicious content.
- Determine the overall risk posed by the email.

---

# 3.Investigation Methodology

The investigation was performed by analyzing the provided EML file in a controlled environment. Thunderbird Mail was used to inspect both the email content and its underlying metadata.

The analysis focused on:

- Sender and recipient information
- Email headers and routing details
- Email authentication mechanisms (SPF and DMARC)
- Reply-To and Return-Path addresses
- Attachment analysis
- Threat intelligence enrichment

The objective was to determine whether the email originated from a legitimate sender or was part of a phishing attempt.

---

# 4.Evidence Analysis

## 4.1.Email Overview

Initial inspection of the email revealed the following information:

| Artifact | Value |
|-----------|---------|
| Subject | Transfer Reference Number: 09674321 |
| Display Name | Mr. James Jackson |
| Sender Address | info@mutawamarine.com |
| Reply-To Address | info.mutawamarine@mail.com |

![Email Overview](images/email-overview.png)

---
