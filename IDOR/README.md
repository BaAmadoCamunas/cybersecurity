# IDOR (Insecure Direct Object Reference)

Write-up in progress...

---

# 1. Introduction

IDOR (Insecure Direct Object Reference) is a type of access control vulnerability that occurs when an application exposes direct references to internal objects without properly validating whether the user is authorized to access them.

Applications commonly use identifiers to retrieve resources such as:

- User profiles
- Documents
- Orders
- API objects
- Files

If the application trusts user-controlled input without validating ownership server-side, attackers may manipulate object identifiers to access unauthorized resources.

---

## Why it happens

IDOR vulnerabilities commonly occur because:

- Applications trust client-side input
- Authorization checks are missing
- Object identifiers are predictable
- Access control is only enforced on the client side

Unlike authentication vulnerabilities, IDOR issues usually occur after a user has already logged into the application.

---

## Authentication vs Authorization

Authentication verifies who the user is.

Authorization verifies what the user is allowed to access.

In many IDOR vulnerabilities, the application correctly authenticates the user but fails to validate whether the authenticated user is authorized to access the requested resource.

---

## Security Impact

IDOR vulnerabilities can allow attackers to:

- Access sensitive information
- Enumerate user data
- Perform horizontal privilege escalation
- Access private documents or files
- Abuse API endpoints
- Potentially compromise user accounts

---
