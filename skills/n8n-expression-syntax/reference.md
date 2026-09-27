# n8n Expression Syntax — Reference

Advanced patterns, debugging, and the expression helper method list — split out of SKILL.md to stay under the 500-line skill cap.

## Advanced Patterns

### Conditional Content

```javascript
// Ternary operator
{{$json.status === 'active' ? 'Active User' : 'Inactive User'}}

// Default values
{{$json.email || 'no-email@example.com'}}
```

### Date Manipulation

```javascript
// Add days
{{$now.plus({days: 7}).toFormat('yyyy-MM-dd')}}

// Subtract hours
{{$now.minus({hours: 24}).toISO()}}

// Set specific date
{{DateTime.fromISO('2025-12-25').toFormat('MMMM dd, yyyy')}}
```

### String Manipulation

```javascript
// Substring
{{$json.email.substring(0, 5)}}

// Replace
{{$json.message.replace('old', 'new')}}

// Split and join
{{$json.tags.split(',').join(', ')}}
```

---

## Performance: expression complexity is (almost) free

A common worry is that a complex `{{ }}` is slow. It isn't — what costs is *how many times* n8n evaluates an expression, not how elaborate each one is.

Measured on an n8n 2.x instance, an elaborate expression (`sqrt`, `split`, `reduce`, arithmetic) costs the same per item as a trivial `{{ $json.x > 50 }}` — roughly **~0.2 ms/item either way**, because ~90% of that is n8n building the per-item evaluation context, not running your expression.

What this means in practice:

- **Don't break a working expression into a chain of nodes for "speed."** Each extra node re-evaluates per item and re-copies all items; one node with one richer expression beats three nodes with simple ones.
- **An expression (~0.2 ms/item) is ~3× cheaper than a Code node in "Run Once for Each Item" mode** (~0.6 ms/item) for the same per-item check — but a Code node in "Run Once for All Items" mode is cheaper still (~0.02 ms/item), because it crosses the per-item boundary once instead of N times.
- This only bites at **thousands of items**; below that it's sub-100 ms. The **n8n Code JavaScript** skill has the full per-item-boundary model.

---

## Debugging Expressions

### Test in Expression Editor

1. Click field with expression
2. Open expression editor (click "fx" icon)
3. See live preview of result
4. Check for errors highlighted in red

### Common Error Messages

**"Cannot read property 'X' of undefined"**
→ Parent object doesn't exist
→ Check your data path

**"X is not a function"**
→ Trying to call method on non-function
→ Check variable type

**Expression shows as literal text**
→ Missing {{ }}
→ Add curly braces

---

## Expression Helpers

### Available Methods

**String**:
- `.toLowerCase()`, `.toUpperCase()`
- `.trim()`, `.replace()`, `.substring()`
- `.split()`, `.includes()`

**Array**:
- `.length`, `.map()`, `.filter()`
- `.find()`, `.join()`, `.slice()`

**DateTime** (Luxon):
- `.toFormat()`, `.toISO()`, `.toLocal()`
- `.plus()`, `.minus()`, `.set()`

**Number**:
- `.toFixed()`, `.toString()`
- Math operations: `+`, `-`, `*`, `/`, `%`

---

## Related Skills

- **n8n MCP Tools Expert**: Learn how to validate expressions using MCP tools
- **n8n Workflow Patterns**: See expressions in real workflow examples
- **n8n Node Configuration**: Understand when expressions are needed

---

## Summary

**Essential Rules**:
1. Wrap expressions in {{ }}
2. Webhook data is under `.body`
3. No {{ }} in Code nodes
4. Quote node names with spaces
5. Node names are case-sensitive

**Most Common Mistakes**:
- Missing {{ }} → Add braces
- `{{$json.name}}` in webhooks → Use `{{$json.body.name}}`
- `{{$json.email}}` in Code → Use `$json.email`
- `{{$node.HTTP Request}}` → Use `{{$node["HTTP Request"]}}`

For more details, see:
- [COMMON_MISTAKES.md](COMMON_MISTAKES.md) - Complete error catalog
- [EXAMPLES.md](EXAMPLES.md) - Real workflow examples

---

**Need Help?** Reference the n8n expression documentation or use n8n-mcp validation tools to check your expressions.
