# Visual Introspection Quick Start Guide

This guide will help you implement the visual introspection system in 30 minutes.

## Prerequisites

- Playwright already installed and configured
- Node.js 20+
- pnpm

## Step 1: Install Dependencies (2 minutes)

```bash
# Install required packages
pnpm add -D pixelmatch pngjs @types/pixelmatch @types/pngjs
```

## Step 2: Copy Helper Files (1 minute)

The following helper files have been created in `tests/helpers/`:

- ✅ `visual.ts` - Visual regression helpers
- ✅ `accessibility.ts` - A11y tree helpers
- ✅ `debug.ts` - Debug capture utilities

## Step 3: Update Playwright Config (3 minutes)

Edit `playwright.config.ts`:

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',

  // Add visual testing configuration
  expect: {
    toHaveScreenshot: {
      maxDiffPixels: 100,
      threshold: 0.2,
      animations: 'disabled',
    },
  },

  use: {
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  // Rest of your config...
});
```

## Step 4: Update .gitignore (1 minute)

```bash
# Add to .gitignore
/test-results/
/playwright-report/
/playwright/.cache/

# But keep visual baselines
!/tests/e2e/**/*-snapshots/
```

## Step 5: Create Your First Visual Test (5 minutes)

Create or update `tests/e2e/visual-smoke.spec.ts`:

```typescript
import { test } from '@playwright/test';
import { captureVisualState, waitForStableState } from '../helpers/visual';
import { verifyA11yStructure } from '../helpers/accessibility';

test('login page visual baseline', async ({ page }) => {
  await page.goto('/login');
  await waitForStableState(page);

  // Visual regression
  await captureVisualState(page, 'login-page', {
    fullPage: true
  });

  // Accessibility structure
  await verifyA11yStructure(page, 'login-page');
});
```

## Step 6: Generate Initial Baselines (5 minutes)

```bash
# Run tests with snapshot update flag
pnpm test:e2e visual-smoke.spec.ts --update-snapshots

# This creates:
# tests/e2e/visual-smoke.spec.ts-snapshots/
#   login-page-chromium-linux.png
#   login-page-a11y.json
```

## Step 7: Verify Baselines (2 minutes)

```bash
# Run tests normally - should pass
pnpm test:e2e visual-smoke.spec.ts

# View HTML report
pnpm playwright show-report
```

## Step 8: Add to Existing Tests (10 minutes)

Update your existing tests to include visual checks:

### Before:
```typescript
test('create board', async ({ page }) => {
  await page.goto('/app/boards');
  await page.getByRole('button', { name: /create/i }).click();
  await page.getByLabel('Board name').fill('Test');
  await page.getByRole('button', { name: /create/i }).click();

  await expect(page.getByText('Test')).toBeVisible();
});
```

### After:
```typescript
import { captureVisualState, waitForStableState } from '../helpers/visual';

test('create board', async ({ page }) => {
  await page.goto('/app/boards');
  await waitForStableState(page);

  // Capture initial state
  await captureVisualState(page, 'boards-empty');

  await page.getByRole('button', { name: /create/i }).click();
  await page.getByLabel('Board name').fill('Test');
  await page.getByRole('button', { name: /create/i }).click();

  await expect(page.getByText('Test')).toBeVisible();
  await waitForStableState(page);

  // Capture with new board
  await captureVisualState(page, 'boards-with-new-board');
});
```

## Step 9: Update CI/CD (3 minutes)

Your GitHub Actions workflow already uploads artifacts. Just add visual diffs:

```yaml
# In .github/workflows/ci.yml, add:

    - name: Upload visual diffs
      if: failure()
      uses: actions/upload-artifact@v4
      with:
        name: visual-regression-diffs
        path: |
          tests/e2e/**/*-diff.png
          tests/e2e/**/*-actual.png
        retention-days: 30
```

## Step 10: Test the Workflow (3 minutes)

1. Make a visual change to your app (e.g., change button color)
2. Run tests: `pnpm test:e2e`
3. Tests should FAIL with visual diff
4. View diff: `pnpm playwright show-report`
5. If change is intentional: `pnpm test:e2e --update-snapshots`
6. Commit new baselines

## You're Done! 🎉

You now have:
- ✅ Visual regression testing
- ✅ Accessibility verification
- ✅ Debug capture utilities
- ✅ CI/CD integration

## Next Steps

### For Daily Development

**When you make UI changes:**
```bash
# 1. Run tests
pnpm test:e2e

# 2. If visual changes expected, update baselines
pnpm test:e2e --update-snapshots

# 3. Commit baselines with your code
git add tests/e2e/**/*-snapshots/
git commit -m "feat: update button styling"
```

**When tests fail:**
```bash
# 1. View HTML report with diffs
pnpm playwright show-report

# 2. Review visual diffs
# Red = removed pixels
# Green = added pixels

# 3. Fix code OR update baseline if correct
```

### For Claude Web Agents

**Agent workflow:**

1. **Before making UI changes:**
   ```typescript
   // Agent reads existing visual baselines
   const baselines = await readDir('tests/e2e/board.spec.ts-snapshots/');
   // Agent understands current visual state
   ```

2. **After making changes:**
   ```bash
   # Agent runs tests
   pnpm test:e2e

   # If failures, agent reviews diffs
   pnpm playwright show-report
   ```

3. **If changes are intentional:**
   ```bash
   # Agent updates baselines
   pnpm test:e2e --update-snapshots

   # Agent commits
   git add tests/e2e/**/*-snapshots/
   git commit -m "feat: new UI component with visual baselines"
   ```

### Advanced Features

**Use VisualDebugger for complex tests:**
```typescript
import { VisualDebugger } from '../helpers/debug';

test('complex interaction', async ({ page }) => {
  const debug = new VisualDebugger(page, 'my-test', {
    captureConsole: true,
    captureNetwork: true,
  });

  await page.goto('/app/board/123');
  await debug.captureAll('initial');

  // ... perform actions ...

  await debug.captureAll('after-action');
});
```

**Create visual documentation:**
```typescript
// scripts/generate-visual-docs.ts
// See full example in VISUAL_INTROSPECTION.md
```

**Mobile testing:**
```typescript
test.use({ ...devices['iPhone 12'] });

test('mobile view', async ({ page }) => {
  await captureVisualState(page, 'board-mobile-iphone12');
});
```

## Common Patterns

### Pattern 1: Component Testing
```typescript
const card = page.getByRole('article').first();
await captureComponentState(card, 'card-default-state');
```

### Pattern 2: Flow Testing
```typescript
await captureFlow(page, [
  { name: 'step1', action: async () => { /* ... */ } },
  { name: 'step2', action: async () => { /* ... */ } },
]);
```

### Pattern 3: Masked Dynamic Content
```typescript
const masks = await maskDynamicContent(page, [
  /\d+ seconds ago/,
  /user-[a-f0-9-]+/,
]);

await captureVisualState(page, 'page', { mask: masks });
```

### Pattern 4: A11y Verification
```typescript
await verifyA11yStructure(page, 'board', {
  role: 'main',
  children: expect.arrayContaining([
    expect.objectContaining({ role: 'list' })
  ])
});
```

### Pattern 5: Debug Timeline
```typescript
const timeline = debug.createTimeline();
await timeline.mark('before-action');
// ... actions ...
await timeline.mark('after-action');
await timeline.save();
```

## Troubleshooting

**Problem: Snapshots differ on CI**
```bash
# Solution: Run in Docker to match CI environment
docker run -it --rm -v $(pwd):/app -w /app mcr.microsoft.com/playwright:v1.40.0 pnpm test:e2e
```

**Problem: Too many baseline updates**
```typescript
// Solution: Increase tolerance
await captureVisualState(page, 'name', {
  maxDiffPixelRatio: 0.05 // 5% tolerance
});
```

**Problem: Animations cause flakes**
```typescript
// Solution: Explicitly wait for stable state
await waitForStableState(page);
await page.waitForTimeout(500); // Extra buffer
```

## Performance Tips

1. **Use component-level snapshots** when possible (faster than full page)
2. **Run visual tests in parallel** (Playwright does this by default)
3. **Only capture critical paths** (don't snapshot every test)
4. **Use `fullPage: false`** when viewport is sufficient
5. **Mask only necessary elements** (masking is slower)

## Storage Management

**Typical snapshot storage:**
- ~100 KB per screenshot
- ~5 KB per a11y snapshot
- ~20 snapshots = 2 MB

**For large projects:**
```bash
# Optional: Use Git LFS for snapshots
git lfs track "tests/e2e/**/*-snapshots/*.png"
```

## Resources

- Full documentation: `docs/VISUAL_INTROSPECTION.md`
- Example tests: `docs/examples/visual-example.spec.ts`
- Playwright docs: https://playwright.dev/docs/test-snapshots

## Getting Help

If you encounter issues:

1. Check `playwright-report/index.html` for visual diffs
2. Review `test-results/` for debug artifacts
3. Run with `--debug` flag: `pnpm test:e2e --debug`
4. Use trace viewer: `pnpm playwright show-trace test-results/trace.zip`

---

**Time investment:** 30 minutes setup
**Benefits:** Catch visual regressions automatically, verify accessibility, debug failures faster

Start small with one or two visual tests, then gradually expand coverage!
