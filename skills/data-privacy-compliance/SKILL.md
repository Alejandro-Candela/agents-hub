---
name: data-privacy-compliance
description: "Data privacy and compliance **specialist** — use whenever someone asks about GDPR, CCPA, HIPAA, privacy policies, data subject rights, consent management, DPIAs, or data protection. Also trigger when building or reviewing any system that stores personal data, chat logs, user profiles, or AI conversation history — especially on a Supabase/RAG stack. Must run when someone says 'is this GDPR compliant', 'can we store this', 'what are our obligations', 'do we need a DPIA', 'right to deletion', or 'privacy review'. Covers AI-specific obligations: conversation log retention, embeddings as PII, right-to-deletion in RAG systems, LLM provider DPAs, and DPIA requirements for AI applications. Based on 2026 regulatory standards.

Does NOT apply to generic security review — for broad code/system audits, defer to `vulnerability-scanner`; for pre-build architecture, defer to `ai-system-build-gate`. This skill is the privacy/compliance deep-dive consulted from those broader reviews."
---

# Data Privacy Compliance

Comprehensive guidance for implementing data privacy compliance across GDPR, CCPA, HIPAA, and other global data protection regulations.

## When to Use This Skill

Use this skill when:
- Implementing GDPR, CCPA, or HIPAA compliance
- Conducting Data Protection Impact Assessments (DPIA)
- Managing data subject rights (access, deletion, portability)
- Implementing consent management systems
- Drafting privacy policies and notices
- Handling data breaches and incident response
- Designing privacy-by-design systems
- Conducting privacy audits and assessments

## Key Regulations Overview

### GDPR (General Data Protection Regulation)
**Scope:** EU residents' data, regardless of where company is located
**Key Requirements:**
- Lawful basis for processing (consent, contract, legitimate interest, etc.)
- Data subject rights (access, deletion, portability, objection)
- Data Protection Impact Assessments for high-risk processing
- 72-hour breach notification requirement
- Records of processing activities
- Privacy by design and by default

**Penalties:** Up to €20M or 4% of global annual revenue

### CCPA/CPRA (California Consumer Privacy Act)
**Scope:** California residents' data
**Key Requirements:**
- Right to know what data is collected
- Right to delete personal information
- Right to opt-out of sale/sharing
- Right to correct inaccurate information
- Right to limit use of sensitive personal information

**Penalties:** Up to $7,500 per intentional violation

### HIPAA (Health Insurance Portability and Accountability Act)
**Scope:** Protected Health Information (PHI) in the US
**Key Requirements:**
- Privacy Rule (patient rights and information uses)
- Security Rule (safeguards for ePHI)
- Breach Notification Rule (60-day notification)
- Business Associate Agreements (BAAs)

**Penalties:** Up to $1.5M per violation category per year

## Consent Management

### Consent Requirements (GDPR)

**Valid Consent Must Be:**
1. Freely given (no coercion)
2. Specific (for each purpose)
3. Informed (clear language)
4. Unambiguous (clear affirmative action)
5. Withdrawable (as easy to withdraw as to give)

**Consent Implementation:**
```html
<!-- Good: Granular consent -->
<form>
  <h3>Privacy Preferences</h3>

  <label>
    <input type="checkbox" name="essential" checked disabled>
    <strong>Essential cookies (Required)</strong>
    <p>Necessary for website functionality</p>
  </label>

  <label>
    <input type="checkbox" name="analytics" value="analytics">
    <strong>Analytics cookies</strong>
    <p>Help us improve our website by collecting usage data</p>
  </label>

  <label>
    <input type="checkbox" name="marketing" value="marketing">
    <strong>Marketing cookies</strong>
    <p>Show you personalized ads based on your interests</p>
  </label>

  <button type="submit">Save Preferences</button>
  <a href="/privacy-policy">Learn More</a>
</form>
```

**Consent Record Storage:**
```javascript
const consentRecord = {
  userId: 'user123',
  timestamp: new Date().toISOString(),
  consentVersion: '2.0',
  purposes: {
    essential: { granted: true, required: true },
    analytics: { granted: true, purpose: 'Website improvement' },
    marketing: { granted: false, purpose: 'Personalized advertising' }
  },
  ipAddress: '192.168.1.1', // For proof
  userAgent: 'Mozilla/5.0...', // For context
  method: 'explicit_opt_in' // or 'implicit', 'presumed'
};

await saveConsentRecord(consentRecord);
```

### Cookie Banner (GDPR Compliant)

```html
<div id="cookie-banner" role="dialog" aria-labelledby="cookie-title">
  <h2 id="cookie-title">Cookie Preferences</h2>
  <p>
    We use cookies to enhance your experience. Choose which cookies you
    allow us to use. You can change your preferences at any time.
  </p>

  <button onclick="acceptAll()">Accept All</button>
  <button onclick="rejectNonEssential()">Reject Non-Essential</button>
  <button onclick="showPreferences()">Manage Preferences</button>
</div>

<script>
// Must not load non-essential cookies until consent given
function acceptAll() {
  setConsent({ analytics: true, marketing: true });
  loadAnalyticsCookies();
  loadMarketingCookies();
  hideBanner();
}

function rejectNonEssential() {
  setConsent({ analytics: false, marketing: false });
  hideBanner();
}
</script>
```

## Privacy by Design Principles

### 1. Data Minimization

**Principle:** Collect only data necessary for specified purpose

**Implementation:**
```javascript
// ❌ Bad: Collecting unnecessary data
const userRegistration = {
  email: req.body.email,
  password: req.body.password,
  fullName: req.body.fullName,
  phoneNumber: req.body.phoneNumber, // Not needed
  dateOfBirth: req.body.dateOfBirth, // Not needed
  address: req.body.address, // Not needed
  socialSecurityNumber: req.body.ssn // Definitely not needed!
};

// ✅ Good: Only essential data
const userRegistration = {
  email: req.body.email,
  password: hashPassword(req.body.password),
  displayName: req.body.displayName // Optional
};
```

### 2. Purpose Limitation

**Principle:** Use data only for specified, explicit purposes

**Implementation:**
```javascript
// Document and enforce purpose
const dataProcessingPurpose = {
  email: [
    'account_authentication',
    'order_confirmations',
    'password_reset'
  ],
  phoneNumber: [
    'order_delivery_notifications'
    // NOT: 'marketing_calls' (requires separate consent)
  ],
  purchaseHistory: [
    'order_fulfillment',
    'customer_support'
    // NOT: 'targeted_advertising' (requires separate consent)
  ]
};

async function processData(data, purpose) {
  if (!isAllowedPurpose(data.type, purpose)) {
    throw new Error('Purpose not authorized for this data');
  }
  // Proceed with processing
}
```

### 3. Storage Limitation

**Principle:** Retain data only as long as necessary

**Implementation:**
```javascript
const retentionPolicy = {
  userAccounts: {
    active: 'indefinite',
    inactive: '2 years',
    deleted: '30 days grace period'
  },
  orderRecords: '7 years', // Legal requirement
  supportTickets: '3 years',
  analytics: '26 months',
  marketingData: '1 year or until consent withdrawn'
};

// Automated data deletion
async function enforceRetentionPolicy() {
  const now = new Date();

  // Delete inactive accounts
  await User.deleteMany({
    lastActive: { $lt: subYears(now, 2) },
    status: 'inactive'
  });

  // Anonymize old analytics
  await Analytics.updateMany(
    { createdAt: { $lt: subMonths(now, 26) } },
    { $unset: { userId: 1, ipAddress: 1 } }
  );

  // Delete expired marketing consent
  await MarketingConsent.deleteMany({
    $or: [
      { expiresAt: { $lt: now } },
      { withdrawnAt: { $lt: subDays(now, 30) } }
    ]
  });
}

// Schedule daily
cron.schedule('0 2 * * *', enforceRetentionPolicy);
```

## Data Protection Impact Assessment (DPIA)

**When Required (GDPR Art. 35):**
- Systematic and extensive profiling
- Large-scale processing of sensitive data
- Systematic monitoring of publicly accessible areas
- New technologies with high privacy risks

**DPIA Template:**
```markdown
# Data Protection Impact Assessment

## Processing Overview
- **Purpose**: [Describe the processing activity]
- **Data Types**: [Personal data categories]
- **Data Subjects**: [Who is affected]
- **Recipients**: [Who receives the data]

## Necessity Assessment
- [ ] Is processing necessary for the stated purpose?
- [ ] Could the purpose be achieved with less data?
- [ ] Is the retention period justified?

## Risk Assessment
| Risk | Likelihood | Severity | Mitigation |
|------|------------|----------|------------|
| Data breach | Medium | High | Encryption, access controls |
| Unauthorized access | Low | High | 2FA, audit logs |
| Purpose creep | Medium | Medium | Purpose documentation, training |

## Safeguards
- [ ] Encryption at rest and in transit
- [ ] Access controls and authentication
- [ ] Regular security audits
- [ ] Data minimization applied
- [ ] Retention policies enforced
- [ ] DPO consulted
- [ ] Data subject rights mechanism in place

## Conclusion
Processing is/is not acceptable with proposed safeguards.

Signed: [Data Protection Officer]
Date: [Assessment Date]
```

## Compliance Checklist

### GDPR Compliance
- [ ] Lawful basis documented for all processing
- [ ] Privacy policy published and accessible
- [ ] Consent mechanism implements granular controls
- [ ] Data subject rights request process established
- [ ] Records of processing activities maintained
- [ ] Data Protection Officer appointed (if required)
- [ ] DPIA conducted for high-risk processing
- [ ] Data breach notification procedure in place
- [ ] Vendor contracts include data processing agreements
- [ ] International data transfer safeguards implemented
- [ ] Staff training on data protection completed

### CCPA Compliance
- [ ] "Do Not Sell My Personal Information" link on homepage
- [ ] Privacy policy discloses data collection and sales
- [ ] Mechanisms for verifiable consumer requests
- [ ] Process for opt-out requests (48-hour response)
- [ ] Annual report on requests and compliance
- [ ] Service provider agreements updated
- [ ] Notice at collection provided

### HIPAA Compliance
- [ ] Risk assessment completed
- [ ] Security policies and procedures documented
- [ ] Workforce trained on HIPAA requirements
- [ ] Business Associate Agreements signed
- [ ] Access controls and audit trails implemented
- [ ] Encryption for ePHI
- [ ] Breach notification procedures established
- [ ] Contingency plan and disaster recovery

Privacy compliance is an ongoing process, not a one-time checklist. Regularly review and update practices as regulations evolve and your data processing changes.

---

## AI & LLM Platform Privacy Considerations

AI-powered platforms introduce new privacy risks that standard GDPR/CCPA checklists don't address. This section covers the compliance obligations specific to LLM applications, RAG systems, and AI assistants.

### New Data Categories in AI Systems

| Data Type | Privacy Risk | Compliance Obligation |
|-----------|-------------|----------------------|
| **Conversation history** | Highly personal; users reveal sensitive info in chat | Data subject access/deletion rights apply; strong access controls required |
| **System prompts** | Contain business logic, potentially personal context | Business confidentiality + user data if personalized |
| **Embeddings (RAG)** | Encoded representation of personal data — still PII | Deletion requests require re-embedding; "right to be forgotten" is complex |
| **LLM inference logs** | May contain full user messages at provider | Review cloud provider DPA; ensure no retention beyond business need |
| **User feedback/ratings** | Links user to AI output quality | Subject to standard data rights |

### Conversation Data — Key Compliance Requirements

**GDPR obligations for AI chat logs:**
- Must inform users at collection that conversations are stored (Art. 13/14)
- Legal basis required — usually contract or legitimate interest
- Must respond to access requests: provide full conversation history in portable format
- Must honor deletion requests: purge conversations + any derived embeddings
- Retention period must be documented and enforced (not indefinite)

**Implementation checklist:**
```markdown
- [ ] Privacy notice updated to disclose AI conversation logging
- [ ] Retention policy defined for conversations (recommend: 12–24 months max)
- [ ] Automated deletion job scheduled and tested
- [ ] Access request handler covers conversation table
- [ ] Deletion handler covers: conversations + embeddings + derived data
- [ ] Cross-tenant isolation confirmed (User A cannot access User B's chats)
- [ ] AI provider DPA reviewed and signed (OpenAI, Anthropic, Azure, etc.)
```

### Right to Deletion in AI Systems — The Hard Parts

Standard deletion is complex when AI has "learned" from or indexed user data:

```markdown
Standard deletion checklist for AI platforms:
- [ ] Delete from conversations/sessions table
- [ ] Delete from vector/embedding store (Supabase pgvector, Pinecone, Weaviate, etc.)
- [ ] Re-embed or flag any RAG documents that referenced the user
- [ ] Purge from LLM provider inference logs (per provider policy)
- [ ] Anonymize any analytics derived from the user's sessions
- [ ] Remove from fine-tuning datasets if applicable
- [ ] Confirm no user-identifiable data remains in backup within retention window
```

> ⚠️ **Embeddings are PII.** A vector embedding of "John Smith's medical question" is still personal data under GDPR even though it's not human-readable. Deletion obligations apply.

### System Prompt Confidentiality vs. Transparency

This creates a direct tension between privacy compliance and security:

| Obligation | Requirement |
|-----------|-------------|
| **GDPR Art. 13/14** | Must disclose "automated decision-making" logic in general terms |
| **Security best practice** | System prompts should not be extractable by users |
| **User rights** | Users can request info about how their data is processed |

**Recommended approach:**
- Disclose the *existence* and *general purpose* of system prompts in your privacy notice
- Do **not** need to reveal verbatim system prompt content
- If system prompts are personalized with user data → that data is subject to access rights
- Example disclosure: *"Our AI assistant uses configuration instructions to shape its responses. These do not include your personal information."*

### AI Provider Data Processing Agreements

Before deploying any AI model in a client context, verify:

```markdown
AI Provider DPA Checklist:
- [ ] DPA signed with LLM provider (OpenAI, Anthropic, Azure OpenAI, etc.)
- [ ] Provider confirms: data NOT used for model training (unless opted in)
- [ ] Retention period for inference data is documented and acceptable
- [ ] Data residency requirements met (EU data stays in EU if required)
- [ ] Sub-processor list reviewed (providers use sub-processors too)
- [ ] Breach notification obligations flow through (72hr GDPR requirement)
- [ ] Right to audit or equivalent assurance mechanism exists
```

### DPIA Requirement for AI Applications

A DPIA is **mandatory** under GDPR Art. 35 for most AI chat applications because they involve:
- Systematic monitoring of behavior (conversation tracking)
- Large-scale processing of personal data
- New technology (AI/LLM) with unpredictable risks

**AI-specific additions to DPIA risk table:**

| Risk | Likelihood | Severity | Mitigation |
|------|-----------|----------|-----------|
| Conversation cross-contamination | Low | Critical | Row-level security, session isolation |
| Prompt injection exposing other user data | Medium | High | Input sanitization, output filtering |
| LLM provider data breach | Low | High | DPA, minimal data sent to provider |
| User inadvertently shares PII in chat | High | Medium | Privacy notice, auto-redaction option |
| Embeddings persist after deletion request | Medium | High | Embedding deletion pipeline |
| System prompt manipulation reveals personal data | Low | High | Prompt isolation from user data |

### Minimal Data Principle for AI Platforms

Apply data minimization aggressively:

```javascript
// ❌ Bad: Sending rich user context to LLM
const systemPrompt = `
  User: ${user.fullName}, ${user.email}
  Account since: ${user.createdAt}
  Subscription: ${user.plan}
  Last 50 searches: ${user.searchHistory.join(', ')}
`;

// ✅ Better: Only what's needed for the task
const systemPrompt = `
  User is a ${user.role} on ${user.plan} plan.
  Answer questions about internal processes.
`;
// Never include email, name, history unless functionally required
```

### AI Privacy Compliance Checklist

- [ ] Privacy notice discloses AI conversation logging and purpose
- [ ] Legal basis documented for AI conversation processing
- [ ] Retention policy for conversations defined and automated
- [ ] Data subject access requests include conversation history
- [ ] Deletion requests cover conversations + embeddings + analytics
- [ ] AI provider DPA signed and reviewed
- [ ] DPIA completed for AI application
- [ ] Cross-tenant data isolation tested (not just assumed)
- [ ] Minimal data sent to LLM provider (no unnecessary PII in prompts)
- [ ] System prompt disclosed in general terms in privacy notice
- [ ] Breach notification procedure covers AI provider incidents

---

For the data-subject-rights code implementation, a fill-in-the-blank privacy policy template, and a breach-notification letter template, see [reference.md](reference.md).
