# Security Policy

## Supported Versions

We currently support the latest version of this documentation project. Since this is a documentation project about CLI tools, security updates primarily involve:

- Removing examples that could be harmful if misused
- Updating examples that reference deprecated or insecure practices
- Ensuring all linked resources are from trusted sources

| Version | Supported          |
| ------- | ------------------ |
| Latest  | ✅ |
| < Latest| ❌ |

## Reporting a Vulnerability

If you discover a security vulnerability in our documentation (such as examples that could be harmful, malicious code snippets, or links to compromised resources), please report it responsibly:

### 🔒 Private Reporting

For sensitive security issues, please email: **security@[your-domain].com**

Include:
- Description of the vulnerability
- Location in the documentation (file and line)
- Potential impact
- Suggested fix (if any)

### 📋 Non-sensitive Issues

For non-sensitive security improvements, you can:
1. Open an issue on GitHub
2. Submit a pull request with the fix
3. Use the GitHub Security Advisory feature

## What We Consider Security Issues

### ✅ **Security Vulnerabilities**
- Code examples that could be used maliciously
- Commands that could damage systems if run incorrectly
- Links to compromised or malicious websites
- Examples exposing sensitive information (API keys, passwords, etc.)
- Deprecated security practices being recommended

### ❌ **Not Security Issues**
- General bugs in documentation
- Broken links to legitimate sites
- Outdated but not dangerous information
- Performance issues

## Response Timeline

- **Initial Response**: Within 48 hours
- **Investigation**: Within 1 week
- **Fix Implementation**: Within 2 weeks
- **Public Disclosure**: After fix is deployed

## Security Best Practices for Contributors

When contributing examples or documentation:

### ✅ **Do**
- Review all command examples for potential misuse
- Use placeholder values for sensitive data
- Include appropriate warnings for dangerous commands
- Reference official documentation for security practices
- Test examples in isolated environments first

### ❌ **Don't**
- Include real API keys, tokens, or passwords
- Suggest commands that modify system files without warnings
- Link to unofficial or unverified tools
- Include examples that could be used for malicious purposes

## Example Security Guidelines

### Safe Command Examples

```bash
# ✅ Good: Uses placeholder
curl -H "Authorization: Bearer YOUR_API_TOKEN" https://api.example.com

# ✅ Good: Includes warning
# WARNING: This command will delete files permanently
rm -rf /path/to/directory

# ✅ Good: Uses safe examples
grep "pattern" sample_file.txt
```

### Unsafe Examples to Avoid

```bash
# ❌ Bad: Real credentials
curl -H "Authorization: Bearer abc123xyz" https://api.example.com

# ❌ Bad: Dangerous command without warning
rm -rf /

# ❌ Bad: Could expose sensitive data
cat /etc/passwd | grep root
```

## Security Tools Coverage

When documenting security-related CLI tools:

1. **Include proper disclaimers** about legal and ethical use
2. **Emphasize responsible disclosure** practices
3. **Warn about potential system impacts**
4. **Reference official security guidelines**

## Regular Security Reviews

We conduct regular reviews of:
- All code examples for security implications
- External links for continued legitimacy
- Dependencies and references for known vulnerabilities
- Community feedback on potential security issues

## Contact Information

- **Security Email**: security@[your-domain].com
- **General Issues**: [GitHub Issues](https://github.com/your-username/homebrew-cli-guide/issues)
- **Security Advisories**: [GitHub Security](https://github.com/your-username/homebrew-cli-guide/security)

Thank you for helping keep our documentation safe and responsible! 🔒
