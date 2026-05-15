
Write-up in progress...


# SQL Injection (SQLi)

SQL Injection is a web application vulnerability that occurs when user input is directly included in SQL queries without proper sanitization or parameterization.

This allows an attacker to manipulate database queries and potentially access, modify or delete sensitive data.

---

# 1. Introduction

SQL Injection (SQLi) happens when an application fails to properly validate user input before using it in a SQL query.

## Why it happens

- Unsanitized user input is concatenated into SQL queries
- Lack of parameterized queries (prepared statements)
- Trusting client-side input

## Impact

SQL Injection can allow attackers to:

- Bypass authentication
- Extract sensitive data (users, passwords, etc.)
- Modify or delete database records
- In some cases, achieve remote code execution (RCE)

---

# 2. In-Band SQL Injection

In-Band SQL Injection is a type of SQL Injection where both the exploitation and data retrieval occur through the same communication channel (e.g., HTTP response).

This makes it one of the easiest types of SQL Injection to detect and exploit.

It is commonly divided into:

- Error-Based SQL Injection
- Union-Based SQL Injection


## 2.1 Error-Based SQL Injection

Error-based SQL Injection relies on forcing the database to return error messages that reveal information about its structure.

---

### Detection

The vulnerability was identified in the `id` parameter of the following endpoint:

```
https://website.thm/article?id=1
```

To test for SQL Injection, a single quote (`'`) was injected into the parameter:

```
https://website.thm/article?id=1'
```

This caused a database error, confirming that the input is directly included in a SQL query without proper sanitization.

---

### Evidence

![SQL error when injecting single quote](images/sqli_error_id_param_1_quote.png)

The application returns a SQL syntax error when malformed input is provided.

---

### Explanation

The error occurs because the application concatenates user input directly into an SQL query. When the query structure is broken using special characters (such as `'`), the database returns an error message that leaks internal information.

This confirms the existence of an Error-Based SQL Injection vulnerability.

---

### Security Impact

Error messages from the database can expose internal structure and help attackers enumerate the database schema.

---

# 3. Blind SQL Injection – Authentication Bypass


---

# 4. Blind SQL Injection – Boolean-Based


---

# 5. Blind SQL Injection – Time-Based

---

# 6. Out-of-Band SQL Injection

---

# 7. Impact of SQL Injection

---

# 8. Mitigations


