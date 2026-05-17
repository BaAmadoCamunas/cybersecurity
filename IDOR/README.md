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

# 2. Identifying IDOR Vulnerabilities

IDOR vulnerabilities can appear in multiple forms depending on how applications reference internal objects and resources.

Common targets include:

- User profiles
- API endpoints
- Files and documents
- Orders and invoices
- Account settings
- Internal application objects

The most common indicator of an IDOR vulnerability is the presence of user-controlled identifiers that reference sensitive resources without proper authorization checks.

---

## 2.1 Predictable IDs

One of the most common forms of IDOR occurs when applications use sequential or predictable identifiers.

Example:

```http
/profile?user_id=1001
/profile?user_id=1002
```

If changing the identifier grants access to another user's data, the application is vulnerable to IDOR.

Predictable identifiers make enumeration attacks significantly easier because attackers can iterate through object references and collect sensitive information from multiple users.

---

## 2.2 Encoded IDs

Some applications encode identifiers before sending them to the client.

A common example is Base64 encoding.

Example:

```text
MTIz
```

Decoded value:

```text
123
```

Although encoding may visually obscure the identifier, it does not provide security.

Attackers can:

1. Decode the value
2. Modify the identifier
3. Re-encode the value
4. Resubmit the request

If the server does not validate ownership of the requested object, unauthorized access may still be possible.

---

## 2.3 Hashed IDs

Applications may also use hashed identifiers instead of raw integer values.

Example:

```text
202cb962ac59075b964b07152d234b70
```

This value corresponds to the MD5 hash of:

```text
123
```

Although hashes may appear secure, predictable hashing schemes can still expose applications to IDOR vulnerabilities.

Attackers may:

- Identify predictable patterns
- Use public hash databases
- Brute-force weak identifiers
- Correlate hashes with sequential values

Hashing identifiers alone does not replace proper authorization controls.

---

## 2.4 Unpredictable IDs

Some applications use random or non-sequential identifiers.

In these cases, a common testing approach is to create multiple accounts and compare requests between them.

If one user can access another user's resources by replacing object identifiers, the application may still be vulnerable to IDOR despite using unpredictable values.

This technique is particularly useful when identifiers cannot easily be enumerated.

---

## 2.5 Hidden Parameters and API Endpoints

IDOR vulnerabilities are not always visible directly in the browser address bar.

Modern web applications frequently retrieve data through:

- API requests
- AJAX calls
- JavaScript endpoints
- Hidden parameters

These requests can often be identified using browser developer tools and the Network tab.

Example:

```http
/api/v1/customer?id=123
```

Applications may unintentionally expose undocumented parameters or internal API functionality that can be manipulated by attackers.

This makes API inspection and parameter analysis important techniques during IDOR testing.

---
