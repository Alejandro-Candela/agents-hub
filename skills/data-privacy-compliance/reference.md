# Data Privacy Compliance — Templates & Implementation Reference

Code implementation examples, privacy policy template, and breach-notification template — split out of SKILL.md to stay under the 500-line skill cap.

## Data Subject Rights Implementation

### 1. Right to Access (GDPR Art. 15 / CCPA § 1798.100)

**Request Handler:**
```javascript
async function handleAccessRequest(userId, email) {
  // Verify identity
  const verified = await verifyIdentity(email);
  if (!verified) throw new Error('Identity verification failed');

  // Collect all personal data
  const userData = await collectUserData(userId);

  // Format for readability
  const report = {
    personalInfo: userData.profile,
    activityLogs: userData.activities,
    preferences: userData.settings,
    thirdPartySharing: userData.dataSharing,
    retentionPeriod: '2 years from last activity',
    dataProtectionOfficer: '<dpo@yourcompany.com>'
  };

  // Generate downloadable report
  const pdf = await generatePDFReport(report);

  // Log request for compliance
  await logAccessRequest(userId, 'completed');

  return pdf;
}
```

**Response Timeline:**
- GDPR: 1 month (extendable to 3 months)
- CCPA: 45 days (extendable to 90 days)

### 2. Right to Deletion (GDPR Art. 17 / CCPA § 1798.105)

**Deletion Handler:**
```javascript
async function handleDeletionRequest(userId, email) {
  // Verify identity
  const verified = await verifyIdentity(email);
  if (!verified) throw new Error('Identity verification failed');

  // Check for legal obligations to retain
  const mustRetain = await checkRetentionRequirements(userId);
  if (mustRetain.required) {
    return {
      status: 'partial_deletion',
      retained: mustRetain.data,
      reason: mustRetain.legalBasis,
      retentionPeriod: mustRetain.period
    };
  }

  // Delete from all systems
  await Promise.all([
    deleteFromDatabase(userId),
    deleteFromBackups(userId), // Mark for deletion in next backup cycle
    deleteFromAnalytics(userId),
    deleteFromThirdPartyServices(userId),
    revokeAPIKeys(userId),
    anonymizeHistoricalRecords(userId)
  ]);

  // Confirm deletion
  await sendDeletionConfirmation(email);
  await logDeletionRequest(userId, 'completed');

  return { status: 'deleted', timestamp: new Date() };
}
```

**Exceptions (when deletion can be refused):**
- Legal obligations (tax records, contracts)
- Public interest/scientific research
- Defense of legal claims
- Exercise of freedom of expression

### 3. Right to Data Portability (GDPR Art. 20)

**Export Handler:**
```javascript
async function handlePortabilityRequest(userId, format = 'json') {
  const userData = await collectUserData(userId);

  // Structure in machine-readable format
  const portableData = {
    exportDate: new Date().toISOString(),
    userId: userId,
    data: {
      profile: userData.profile,
      content: userData.userGeneratedContent,
      settings: userData.preferences,
      history: userData.activityHistory
    }
  };

  // Support multiple formats
  if (format === 'csv') {
    return convertToCSV(portableData);
  } else if (format === 'xml') {
    return convertToXML(portableData);
  }

  return portableData; // JSON by default
}
```

**Requirements:**
- Structured, commonly used, machine-readable format
- Ability to transmit directly to another controller
- Only applies to data provided by data subject
- Only for automated processing based on consent or contract

### 4. Right to Object (GDPR Art. 21)

**Objection Handler:**
```javascript
async function handleObjectionRequest(userId, processingType) {
  switch (processingType) {
    case 'direct_marketing':
      // Must stop immediately
      await disableMarketing(userId);
      await updateConsent(userId, 'marketing', false);
      break;

    case 'legitimate_interest':
      // Assess if we have compelling grounds
      const assessment = await assessLegitimateInterest(userId);
      if (!assessment.compelling) {
        await stopProcessing(userId, processingType);
      }
      return assessment;

    case 'profiling':
      await disableProfiling(userId);
      await updateConsent(userId, 'profiling', false);
      break;

    default:
      throw new Error('Invalid processing type');
  }

  await logObjectionRequest(userId, processingType, 'granted');
}
```

## Privacy Policy Requirements

**Essential Elements:**
```markdown
# Privacy Policy

## 1. Identity of Controller
Company Name, Address, Contact Information
Data Protection Officer: <dpo@yourcompany.com>

## 2. Data We Collect
- Account data: email, name
- Usage data: pages visited, features used
- Technical data: IP address, browser type

## 3. Legal Basis for Processing
- **Consent**: Marketing communications
- **Contract**: Order fulfillment
- **Legitimate Interest**: Fraud prevention
- **Legal Obligation**: Tax records

## 4. How We Use Your Data
- Provide services you requested
- Improve our products
- Send important updates
- [Be specific, avoid vague statements]

## 5. Data Sharing
- Payment processors (Stripe, PayPal)
- Shipping providers (FedEx, UPS)
- Analytics (Google Analytics)

We do NOT sell your personal data.

## 6. Your Rights
- Right to access your data
- Right to correct inaccuracies
- Right to delete your data
- Right to object to processing
- Right to data portability
- Right to withdraw consent

Contact: <privacy@yourcompany.com>

## 7. Data Retention
- Account data: Until account deletion + 30 days
- Order history: 7 years (legal requirement)
- Marketing data: 1 year or until opt-out

## 8. Security
We use industry-standard security measures including
encryption, secure servers, and regular security audits.

## 9. International Transfers
Data may be transferred to US servers. We use Standard
Contractual Clauses approved by the EU Commission.

## 10. Changes to Policy
Last updated: [Date]
We will notify you of material changes via email.

## 11. Contact
Questions? Contact our Data Protection Officer at <dpo@yourcompany.com>
```

## Incident Response

### Data Breach Response Plan

**Within 72 Hours (GDPR):**
```markdown
1. **Detect & Contain** (0-4 hours)
   - Identify scope of breach
   - Isolate affected systems
   - Prevent further data loss

2. **Assess** (4-24 hours)
   - Determine data types affected
   - Identify number of individuals
   - Assess risk to rights and freedoms
   - Document everything

3. **Notify Authority** (24-72 hours)
   - Report to supervisory authority
   - Include: nature, categories, approximate numbers,
     likely consequences, measures taken

4. **Notify Data Subjects** (ASAP if high risk)
   - Direct communication required
   - Describe breach in clear language
   - Provide recommendations for protection
```

**Breach Notification Template:**
```
Subject: Important Security Notice

Dear [Name],

We are writing to inform you of a data security incident that may
have affected your personal information.

WHAT HAPPENED:
On [date], we discovered that [brief description].

WHAT INFORMATION WAS INVOLVED:
[List specific data types: name, email, etc.]
[List what was NOT involved]

WHAT WE ARE DOING:
- [Immediate actions taken]
- [Ongoing security enhancements]
- [Resources provided to affected individuals]

WHAT YOU CAN DO:
- Change your password immediately
- Monitor your accounts for suspicious activity
- [Specific recommendations]

FOR MORE INFORMATION:
Contact our dedicated hotline: [phone]
Email: <security@yourcompany.com>

We sincerely apologize for this incident and the inconvenience
it may cause.

Sincerely,
[Name, Title]
```
