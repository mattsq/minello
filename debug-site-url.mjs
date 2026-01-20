#!/usr/bin/env node
/**
 * Quick script to test what getSiteUrl() would return
 * Run with: node debug-site-url.mjs
 */

function getSiteUrl() {
  const configured = process.env.NEXT_PUBLIC_SITE_URL
  if (configured) {
    return configured.replace(/\/$/, '')
  }

  const vercelUrl = process.env.VERCEL_URL
  if (vercelUrl) {
    return `https://${vercelUrl}`
  }

  return 'http://localhost:3000'
}

console.log('Current environment variables:')
console.log('  NEXT_PUBLIC_SITE_URL:', process.env.NEXT_PUBLIC_SITE_URL || '(not set)')
console.log('  VERCEL_URL:', process.env.VERCEL_URL || '(not set)')
console.log('')
console.log('getSiteUrl() would return:', getSiteUrl())
console.log('Invite redirect would be:', `${getSiteUrl()}/auth/callback`)
