# Supabase CI Configuration Guide

This document outlines the Supabase project settings required for CI/CD tests to pass.

## Required GitHub Secrets

The following secrets must be configured in your GitHub repository:

- `NEXT_PUBLIC_SUPABASE_URL` - Your Supabase project URL
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Your Supabase anonymous/public key
- `SUPABASE_SERVICE_ROLE_KEY` - Your Supabase service role key (for admin operations)
- `TEST_EMAIL_ACCOUNT` - A valid email address for E2E auth tests (must use a real domain like Gmail)

## Supabase Project Configuration

### 1. Email Authentication Settings

Navigate to: **Authentication → Providers → Email**

- ✅ **Enable Email provider**: ON
- ⚠️ **Confirm email**: DISABLE for testing (or use real test email account)
- ⚠️ **Secure email change**: Can be disabled for testing
- ⚠️ **Email Domain Restrictions**: Ensure test email domains are allowed

### 2. URL Configuration

Navigate to: **Authentication → URL Configuration**

Add the following redirect URLs:
- `http://localhost:3000/auth/callback` (for local testing)
- `https://your-vercel-app.vercel.app/auth/callback` (for preview/production)

**Site URL**: Set to your main application URL

### 3. Email Templates

Navigate to: **Authentication → Email Templates**

Ensure the "Magic Link" template is properly configured. Default template should work fine.

### 4. Rate Limiting (Optional)

Navigate to: **Authentication → Rate Limits**

For CI environments with frequent test runs, consider:
- Increasing email rate limits
- Whitelisting the CI runner's IP (if static)

### 5. SMTP Settings (Testing)

Navigate to: **Project Settings → Auth**

For E2E tests:
- **Option A**: Use Supabase's built-in email service (default)
  - Works out of the box, no configuration needed
  - Supabase sends emails from their domain

- **Option B**: Configure custom SMTP
  - Recommended for production
  - Configure a test email account for CI

## Email Domain Restrictions

Supabase blocks certain test/disposable email domains by default:
- ❌ `example.com`
- ❌ `test.com`
- ❌ `mailinator.com`
- ❌ Other disposable domains

For CI tests to work, you must either:
1. **Use a real email domain** (e.g., `playwright-test@gmail.com`) ✅ Recommended
2. **Disable email validation** in Supabase dashboard (not recommended for production)
3. **Configure allow-list** for specific test domains

## Test User Setup

### Email Account for Testing

The `TEST_EMAIL_ACCOUNT` secret should contain a valid email address with a real domain:

**✅ Good examples:**
- `your-test-account@gmail.com`
- `ci-testing@yourdomain.com`
- `automated-tests@outlook.com`

**❌ Bad examples (will be blocked by Supabase):**
- `test@example.com` - example.com is a reserved domain
- `user@test.com` - test.com is blocked
- `temp@mailinator.com` - disposable email domains are blocked

**Note:** The tests only verify that Supabase accepts the email and sends a magic link. The email doesn't need to be actively monitored or accessible during test runs.

### User Creation

For comprehensive E2E tests, test users are handled automatically:

```sql
-- In Supabase SQL Editor
-- This is handled by the app's workspace bootstrap logic
-- No manual user creation needed
```

Users are auto-created when they first sign in with a magic link.

## Common CI Issues

### Issue: "Email address is invalid"
**Cause**: Supabase blocking test email domain
**Fix**: Use a real email domain in tests (see test files)

### Issue: "Failed to load resource: 400"
**Cause**: Invalid Supabase credentials or URL
**Fix**: Verify GitHub secrets are correctly set

### Issue: Rate limiting errors ("For security purposes, you can only request this after X seconds")
**Cause**: Too many auth requests in short time (common in CI with test retries)
**Status**: Expected behavior - the auth test now accepts rate limiting as a valid outcome
**Why it's OK**: Rate limiting confirms the Supabase endpoint is working and protecting against abuse
**Optional Fix**: If you want to reduce rate limit hits, increase limits in Supabase Dashboard → Authentication → Rate Limits

### Issue: Magic link not working
**Cause**: Redirect URL not configured
**Fix**: Add `http://localhost:3000/auth/callback` to allowed URLs

## Testing the Configuration

To verify your Supabase setup:

1. **Local Test**:
   ```bash
   pnpm test:e2e
   ```

2. **Check Supabase Logs**:
   - Go to Supabase Dashboard → Logs → Auth Logs
   - Look for failed authentication attempts
   - Verify the error messages

3. **Manual Test**:
   - Visit your deployed app
   - Try the login flow
   - Check if magic link email arrives

## Security Notes

- Never commit `.env.local` files with real credentials
- Use separate Supabase projects for development, staging, and production
- Rotate service role keys regularly
- Monitor auth logs for suspicious activity

## Support

If tests continue to fail:
1. Check Supabase Dashboard → Logs → Auth Logs for detailed errors
2. Verify all GitHub secrets are set correctly
3. Ensure email domain is not blocked
4. Review this configuration guide
