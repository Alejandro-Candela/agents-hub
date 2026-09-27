# n8n Validation Expert — Reference

Detailed guides, split out of SKILL.md to stay under the 500-line skill cap.

## Detailed Guides

For comprehensive error catalogs, false positives, and workflow review:

- **[ERROR_CATALOG.md](ERROR_CATALOG.md)** - Complete list of error types with examples
- **[FALSE_POSITIVES.md](FALSE_POSITIVES.md)** - When warnings are acceptable
- **[REVIEW_CHECKLIST.md](REVIEW_CHECKLIST.md)** - Severity-tiered audit for reviewing an existing workflow

---

## Summary

**Key Points**:
1. **Validation is iterative** (avg 2-3 cycles, 23s + 58s)
2. **Errors must be fixed**, warnings are optional
3. **Auto-sanitization** fixes operator structures automatically
4. **Use runtime profile** for balanced validation
5. **False positives exist** - learn to recognize them
6. **Read error messages** - they contain fix guidance

**Validation Process**:
1. Validate → Read errors → Fix → Validate again
2. Repeat until valid (usually 2-3 iterations)
3. Review warnings and decide if acceptable
4. Deploy with confidence

**Related Skills & Tools**:
- n8n MCP Tools Expert - Use validation tools correctly
- n8n Expression Syntax - Fix expression errors
- n8n Node Configuration - Understand required fields
- `n8n_audit_instance` - Proactive security validation (hardcoded secrets, unauthenticated webhooks, missing error handling, data retention)
