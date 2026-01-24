# Visual Introspection System for Claude Web Agents

## Overview

This document describes a comprehensive approach for Claude Web agents to introspect on the visual state of the FamilyBoard app. The system provides multiple layers of visual verification:

1. **Visual Regression Testing** - Screenshot comparison for detecting unintended changes
2. **Accessibility Tree Snapshots** - Structural verification independent of styling
3. **Visual State Documentation** - Generated screenshots as documentation
4. **Interactive Visual Debugging** - Real-time inspection through Playwright traces

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Web Agent                          │
│  - Reads visual baselines                                   │
│  - Compares current state to expected                       │
│  - Generates new baselines when intentional changes made    │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ├──> Local Development
                  │    - Run tests with --update-snapshots
                  │    - View visual diffs in HTML report
                  │    - Inspect traces interactively
                  │
                  └──> CI/CD Pipeline
                       - Automatic visual regression checks
                       - Upload screenshots & diffs as artifacts
                       - Fail on unexpected visual changes
```

## Implementation Components

### 1. Visual Regression Testing (Playwright Native)

**Tool:** Playwright's built-in `toHaveScreenshot()` matcher

**Implementation:**
```typescript
// tests/helpers/visual.ts
export async function captureVisualState(
  page: Page,
  name: string,
  options?: {
    fullPage?: boolean;
    clip?: { x: number; y: number; width: number; height: number };
    maxDiffPixels?: number;
    maxDiffPixelRatio?: number;
  }
) {
  await expect(page).toHaveScreenshot(`${name}.png`, {
    fullPage: options?.fullPage ?? false,
    clip: options?.clip,
    maxDiffPixels: options?.maxDiffPixels ?? 100,
    maxDiffPixelRatio: options?.maxDiffPixelRatio ?? 0.01,
    animations: 'disabled', // Disable animations for consistent screenshots
    ...options
  });
}

export async function captureComponentState(
  element: Locator,
  name: string,
  options?: {
    maxDiffPixels?: number;
  }
) {
  await expect(element).toHaveScreenshot(`${name}-component.png`, {
    maxDiffPixels: options?.maxDiffPixels ?? 50,
    animations: 'disabled',
  });
}
```

**Storage Structure:**
```
tests/
  e2e/
    board.spec.ts
    board.spec.ts-snapshots/
      board-empty-state-chromium-linux.png          # Baseline
      board-with-lists-chromium-linux.png
      card-modal-open-chromium-linux.png
      drag-drop-preview-chromium-linux.png
    auth.spec.ts-snapshots/
      login-page-chromium-linux.png
      boards-list-chromium-linux.png
```

**Usage in Tests:**
```typescript
test('board displays empty state correctly', async ({ page }) => {
  await page.goto('/app/board/new-board-id');

  // Wait for stable state
  await page.waitForLoadState('networkidle');

  // Visual regression check
  await captureVisualState(page, 'board-empty-state', {
    fullPage: true
  });

  // Also capture accessibility tree
  const snapshot = await page.accessibility.snapshot();
  expect(snapshot).toMatchSnapshot('board-empty-state-a11y.json');
});
```

### 2. Accessibility Tree Snapshots

**Purpose:** Verify UI structure independent of visual styling

**Implementation:**
```typescript
// tests/helpers/accessibility.ts
export async function captureA11yTree(
  page: Page,
  name: string
) {
  const snapshot = await page.accessibility.snapshot();
  return snapshot;
}

export async function verifyA11yStructure(
  page: Page,
  name: string,
  expectedStructure?: Partial<AccessibilitySnapshot>
) {
  const snapshot = await page.accessibility.snapshot();

  if (expectedStructure) {
    // Verify specific structure
    expect(snapshot).toMatchObject(expectedStructure);
  }

  // Also save as snapshot for visual comparison
  expect(snapshot).toMatchSnapshot(`${name}-a11y.json`);

  return snapshot;
}
```

**Example Snapshot:**
```json
{
  "role": "main",
  "name": "Board: Family Tasks",
  "children": [
    {
      "role": "list",
      "name": "To Do",
      "children": [
        {
          "role": "listitem",
          "name": "Buy groceries",
          "description": "Milk, eggs, bread"
        }
      ]
    }
  ]
}
```

### 3. Visual State Documentation Generator

**Purpose:** Auto-generate visual documentation that agents can read

**Implementation:**
```typescript
// scripts/generate-visual-docs.ts
import { chromium } from '@playwright/test';
import fs from 'fs/promises';
import path from 'path';

interface VisualState {
  name: string;
  url: string;
  description: string;
  interactions?: string[];
}

const VISUAL_STATES: VisualState[] = [
  {
    name: 'login-page',
    url: '/login',
    description: 'Magic link login form',
  },
  {
    name: 'boards-list',
    url: '/app/boards',
    description: 'List of all boards in workspace',
    interactions: ['Create board button', 'Board cards'],
  },
  {
    name: 'board-view',
    url: '/app/board/[boardId]',
    description: 'Main board with lists and cards',
    interactions: ['Add list', 'Add card', 'Drag and drop'],
  },
  {
    name: 'card-modal',
    url: '/app/board/[boardId]',
    description: 'Card edit modal',
    interactions: ['Click any card to open'],
  },
];

async function generateVisualDocs() {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  const docs: string[] = [
    '# Visual State Reference',
    '',
    'Auto-generated visual documentation of app states.',
    '',
  ];

  for (const state of VISUAL_STATES) {
    console.log(`Capturing: ${state.name}`);

    // Navigate and capture
    await page.goto(`http://localhost:3000${state.url}`);
    await page.waitForLoadState('networkidle');

    const screenshotPath = `docs/visual-states/${state.name}.png`;
    await page.screenshot({ path: screenshotPath, fullPage: true });

    const a11ySnapshot = await page.accessibility.snapshot();
    const a11yPath = `docs/visual-states/${state.name}-a11y.json`;
    await fs.writeFile(a11yPath, JSON.stringify(a11ySnapshot, null, 2));

    // Add to docs
    docs.push(`## ${state.name}`);
    docs.push(`**URL:** \`${state.url}\``);
    docs.push(`**Description:** ${state.description}`);
    if (state.interactions) {
      docs.push(`**Interactions:**`);
      state.interactions.forEach(i => docs.push(`- ${i}`));
    }
    docs.push(`![${state.name}](./visual-states/${state.name}.png)`);
    docs.push('');
  }

  await fs.writeFile('docs/VISUAL_STATES.md', docs.join('\n'));
  await browser.close();
}

generateVisualDocs().catch(console.error);
```

**Generated Output:**
```
docs/
  VISUAL_STATES.md           # Human/agent-readable doc with images
  visual-states/
    login-page.png
    login-page-a11y.json
    boards-list.png
    boards-list-a11y.json
    board-view.png
    board-view-a11y.json
    card-modal.png
    card-modal-a11y.json
```

### 4. Test Instrumentation for Visual Debugging

**Enhanced Test Helpers:**
```typescript
// tests/helpers/debug.ts
import { Page, Locator } from '@playwright/test';
import path from 'path';

export class VisualDebugger {
  private screenshotCount = 0;

  constructor(
    private page: Page,
    private testName: string
  ) {}

  /**
   * Capture debug screenshot at current state
   * Useful for agents to see intermediate states
   */
  async capture(label: string) {
    this.screenshotCount++;
    const filename = `${this.testName}-${this.screenshotCount}-${label}.png`;
    await this.page.screenshot({
      path: path.join('test-results/debug-screenshots', filename),
      fullPage: true,
    });

    console.log(`📸 Debug screenshot: ${filename}`);
  }

  /**
   * Capture element-specific screenshot
   */
  async captureElement(element: Locator, label: string) {
    this.screenshotCount++;
    const filename = `${this.testName}-${this.screenshotCount}-${label}-element.png`;
    await element.screenshot({
      path: path.join('test-results/debug-screenshots', filename),
    });

    console.log(`📸 Element screenshot: ${filename}`);
  }

  /**
   * Capture DOM snapshot for agent inspection
   */
  async captureDOMSnapshot(label: string) {
    const html = await this.page.content();
    const filename = `${this.testName}-${this.screenshotCount}-${label}.html`;
    await fs.writeFile(
      path.join('test-results/dom-snapshots', filename),
      html
    );

    console.log(`📄 DOM snapshot: ${filename}`);
  }

  /**
   * Capture accessibility tree for structural verification
   */
  async captureA11ySnapshot(label: string) {
    const snapshot = await this.page.accessibility.snapshot();
    const filename = `${this.testName}-${this.screenshotCount}-${label}-a11y.json`;
    await fs.writeFile(
      path.join('test-results/a11y-snapshots', filename),
      JSON.stringify(snapshot, null, 2)
    );

    console.log(`♿ A11y snapshot: ${filename}`);
  }

  /**
   * All-in-one: capture everything at current state
   */
  async captureAll(label: string) {
    await this.capture(label);
    await this.captureDOMSnapshot(label);
    await this.captureA11ySnapshot(label);
  }
}

// Usage in tests:
test('drag and drop card', async ({ page }) => {
  const debugger = new VisualDebugger(page, 'dnd-card');

  await page.goto('/app/board/test-board');
  await debugger.captureAll('initial-state');

  const card = page.getByRole('article', { name: 'Test Card' });
  const targetList = page.getByRole('list', { name: 'Done' });

  await debugger.capture('before-drag');
  await card.dragTo(targetList);
  await debugger.captureAll('after-drag');

  await page.reload();
  await debugger.captureAll('after-reload');
});
```

### 5. CI Integration

**Update `.github/workflows/ci.yml`:**
```yaml
e2e:
  name: E2E Tests
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Setup pnpm
      uses: pnpm/action-setup@v4
      with:
        version: 10.27.0

    - name: Setup Node
      uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'pnpm'

    - name: Install dependencies
      run: pnpm install --frozen-lockfile

    - name: Install Playwright Browsers
      run: pnpm exec playwright install --with-deps chromium

    - name: Run E2E tests
      run: pnpm test:e2e --project=chromium
      env:
        NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.NEXT_PUBLIC_SUPABASE_URL }}
        NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.NEXT_PUBLIC_SUPABASE_ANON_KEY }}
        TEST_EMAIL_ACCOUNT: ${{ secrets.TEST_EMAIL_ACCOUNT }}

    - name: Upload test results
      if: always()
      uses: actions/upload-artifact@v4
      with:
        name: test-results
        path: test-results/
        retention-days: 30

    - name: Upload Playwright report
      if: always()
      uses: actions/upload-artifact@v4
      with:
        name: playwright-report
        path: playwright-report/
        retention-days: 30

    # NEW: Upload visual regression diffs
    - name: Upload visual diffs
      if: failure()
      uses: actions/upload-artifact@v4
      with:
        name: visual-regression-diffs
        path: |
          tests/e2e/**/*-diff.png
          tests/e2e/**/*-actual.png
        retention-days: 30

    # NEW: Upload debug screenshots
    - name: Upload debug screenshots
      if: always()
      uses: actions/upload-artifact@v4
      with:
        name: debug-screenshots
        path: test-results/debug-screenshots/
        retention-days: 30

    # NEW: Generate visual docs artifact
    - name: Generate visual state docs
      if: success()
      run: pnpm run generate:visual-docs

    - name: Upload visual docs
      if: success()
      uses: actions/upload-artifact@v4
      with:
        name: visual-state-docs
        path: docs/visual-states/
        retention-days: 90
```

**Update `package.json`:**
```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:update-snapshots": "playwright test --update-snapshots",
    "generate:visual-docs": "tsx scripts/generate-visual-docs.ts",
    "visual:open-report": "playwright show-report",
    "visual:open-trace": "playwright show-trace"
  }
}
```

## Agent Workflow

### For Claude Web Agents

**1. Initial Visual Baseline Creation:**
```bash
# Agent runs this when creating new UI components
pnpm test:e2e --update-snapshots

# Commits new baseline screenshots
git add tests/e2e/**/*-snapshots/
git commit -m "feat: add visual baselines for new board UI"
```

**2. Verify Visual Changes:**
```bash
# Run tests normally - will fail if visuals don't match baseline
pnpm test:e2e

# View the diff in HTML report
pnpm visual:open-report
```

**3. Inspect Visual State:**
```typescript
// Agent can read these files to understand current UI state
const visualDocs = await readFile('docs/VISUAL_STATES.md');
const a11yTree = await readFile('docs/visual-states/board-view-a11y.json');

// Agent can also run the generator to create fresh snapshots
await exec('pnpm generate:visual-docs');
```

**4. Debug Failed Tests:**
```bash
# Open trace viewer for interactive debugging
pnpm visual:open-trace test-results/trace.zip

# Or read debug screenshots directly
ls test-results/debug-screenshots/
```

### Agent Decision Tree

```
┌─────────────────────────────────────┐
│  Agent makes UI change              │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Run: pnpm test:e2e                 │
└──────────────┬──────────────────────┘
               │
               ├─ PASS → Continue
               │
               └─ FAIL → Visual diff?
                          │
                          ├─ YES (expected)
                          │  └─> Run: pnpm test:e2e --update-snapshots
                          │      └─> Commit new baselines
                          │
                          └─ YES (unexpected)
                             └─> Review diffs in playwright-report/
                                 ├─> Fix code OR
                                 └─> Update baseline if correct
```

## Local Development Workflow

### Developer/Agent Setup

1. **Initial setup:**
```bash
pnpm install
pnpm exec playwright install --with-deps
```

2. **Create visual baselines:**
```bash
pnpm test:e2e --update-snapshots
```

3. **Generate visual documentation:**
```bash
pnpm generate:visual-docs
```

4. **Normal development cycle:**
```bash
# Make changes
# Run tests
pnpm test:e2e

# If visual changes expected:
pnpm test:e2e --update-snapshots

# View results
pnpm visual:open-report
```

### Interactive Visual Debugging

**Playwright UI Mode:**
```bash
pnpm test:e2e:ui
```

Features:
- Live preview of tests
- Step through test execution
- Inspect page at each step
- See visual diffs inline
- Time travel debugging

**Trace Viewer:**
```bash
# After test run with failures
pnpm visual:open-trace test-results/trace.zip
```

Features:
- Full test execution recording
- DOM snapshots at each step
- Network activity
- Console logs
- Screenshots at each action

## File Structure

```
minello/
├── docs/
│   ├── VISUAL_INTROSPECTION.md     # This document
│   ├── VISUAL_STATES.md            # Generated visual reference
│   └── visual-states/
│       ├── login-page.png
│       ├── login-page-a11y.json
│       ├── boards-list.png
│       ├── boards-list-a11y.json
│       └── ...
│
├── tests/
│   ├── e2e/
│   │   ├── board.spec.ts
│   │   ├── board.spec.ts-snapshots/       # Visual baselines (git tracked)
│   │   │   ├── board-empty-chromium-linux.png
│   │   │   ├── board-with-lists-chromium-linux.png
│   │   │   └── ...
│   │   ├── auth.spec.ts
│   │   └── auth.spec.ts-snapshots/
│   │
│   └── helpers/
│       ├── visual.ts                      # Visual regression helpers
│       ├── accessibility.ts               # A11y tree helpers
│       └── debug.ts                       # Debug capture utilities
│
├── scripts/
│   └── generate-visual-docs.ts            # Visual docs generator
│
├── test-results/                          # Git ignored, generated per run
│   ├── debug-screenshots/
│   ├── dom-snapshots/
│   ├── a11y-snapshots/
│   └── trace.zip
│
└── playwright-report/                     # Git ignored, HTML report
    └── index.html
```

## Benefits for Claude Web Agents

### 1. **Multi-Modal Verification**
- Code tests verify behavior
- Visual tests verify appearance
- A11y tests verify structure
- Agents can cross-reference all three

### 2. **Self-Documenting UI**
- Generated visual docs serve as living documentation
- Agents can "see" what the app looks like without running it
- A11y snapshots provide structural reference

### 3. **Regression Prevention**
- Unintended visual changes caught automatically
- Agents know when they've broken existing UI
- Clear visual diffs show exactly what changed

### 4. **Debugging Superpowers**
- Trace viewer shows exact test execution
- Debug screenshots capture intermediate states
- DOM snapshots allow post-mortem analysis
- Agents can inspect failures without rerunning tests

### 5. **CI/CD Integration**
- Visual diffs uploaded to artifacts
- Agents can fetch and review diffs from CI
- Historical visual state preserved
- No need for local reproduction

## Example: Agent Workflow for Adding New Feature

**Scenario:** Agent adds a "Due Soon" badge to cards with approaching due dates

```typescript
// 1. Agent makes code changes
// app/components/Card.tsx - adds badge logic

// 2. Agent updates test to capture new visual state
test('card shows due soon badge', async ({ page }) => {
  const debugger = new VisualDebugger(page, 'due-soon-badge');

  // Create card with due date tomorrow
  await page.goto('/app/board/test-board');
  await debugger.captureAll('initial');

  const card = page.getByRole('article', { name: 'Test Card' });
  await card.click();

  const dueDateInput = page.getByLabel('Due date');
  await dueDateInput.fill('2026-01-21'); // Tomorrow
  await page.getByRole('button', { name: 'Save' }).click();

  await debugger.captureAll('after-save');

  // Verify badge appears
  await expect(card.getByText('Due Soon')).toBeVisible();

  // Visual regression check
  await captureComponentState(card, 'card-with-due-soon-badge');

  // A11y verification
  await verifyA11yStructure(page, 'card-due-soon', {
    role: 'article',
    children: expect.arrayContaining([
      expect.objectContaining({
        role: 'status',
        name: 'Due Soon'
      })
    ])
  });
});

// 3. Agent runs test - it fails (no baseline yet)
// pnpm test:e2e

// 4. Agent reviews visual diff in playwright-report/
// Sees the badge looks correct

// 5. Agent updates baselines
// pnpm test:e2e --update-snapshots

// 6. Agent regenerates visual docs
// pnpm generate:visual-docs

// 7. Agent commits everything
git add tests/e2e/**/*-snapshots/
git add docs/visual-states/
git add tests/e2e/board.spec.ts
git commit -m "feat: add due soon badge to cards"
```

## Configuration

### Playwright Config Updates

**Update `playwright.config.ts`:**
```typescript
export default defineConfig({
  testDir: './tests/e2e',

  // Visual testing configuration
  expect: {
    toHaveScreenshot: {
      maxDiffPixels: 100,
      threshold: 0.2,
      animations: 'disabled',
    },
  },

  // Ensure debug artifacts are captured
  use: {
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  // ... rest of config
});
```

### Git Configuration

**Update `.gitignore`:**
```
# Test results (local only)
/test-results/
/playwright-report/
/playwright/.cache/

# Keep visual baselines (tracked)
!/tests/e2e/**/*-snapshots/

# Keep generated visual docs (tracked)
!/docs/visual-states/
```

**Update `.gitattributes`:**
```
# Treat snapshot images as binary
*.png binary
```

## Maintenance

### Baseline Updates

**When to update baselines:**
1. Intentional visual changes (new feature, design update)
2. Browser/OS updates causing minor rendering differences
3. Font or system-level changes

**How to update:**
```bash
# Update all baselines
pnpm test:e2e --update-snapshots

# Update specific test
pnpm test:e2e board.spec.ts --update-snapshots

# Update specific project (browser)
pnpm test:e2e --project=chromium --update-snapshots
```

### Snapshot Hygiene

**Best practices:**
1. Review diffs before committing new baselines
2. Keep snapshots minimal (component-level, not full page when possible)
3. Use consistent viewport sizes
4. Disable animations in snapshots
5. Wait for stable state (networkidle, specific elements)

### Performance Considerations

**Snapshot storage:**
- Average screenshot: 50-200 KB
- With 5 browsers × 20 states = ~10-20 MB total
- Git LFS optional for very large projects

**Test execution:**
- Screenshots add ~500ms per capture
- Use sparingly in hot paths
- Parallel execution amortizes cost

## Migration Plan

### Phase 1: Foundation (Week 1)
- [ ] Create `tests/helpers/visual.ts`
- [ ] Create `tests/helpers/accessibility.ts`
- [ ] Create `tests/helpers/debug.ts`
- [ ] Update Playwright config
- [ ] Add first visual test (login page)

### Phase 2: Core Coverage (Week 2)
- [ ] Add visual tests for all existing e2e tests
- [ ] Generate initial baselines
- [ ] Create visual docs generator script
- [ ] Generate initial visual documentation

### Phase 3: CI Integration (Week 3)
- [ ] Update GitHub Actions workflow
- [ ] Test artifact uploads
- [ ] Document agent workflow
- [ ] Create migration guide

### Phase 4: Enhancement (Week 4)
- [ ] Add visual debugging to failed test workflow
- [ ] Create visual diff review tool
- [ ] Add mobile visual testing
- [ ] Performance optimization

## Troubleshooting

### Common Issues

**1. Snapshots don't match on CI:**
- Solution: Use Docker locally to match CI environment
- Or: Adjust `maxDiffPixels` threshold

**2. Font rendering differences:**
- Solution: Install exact font packages in CI
- Or: Use web fonts instead of system fonts

**3. Animation timing issues:**
- Solution: Set `animations: 'disabled'` in screenshot options
- Or: Wait for specific animation end events

**4. Too many baseline updates:**
- Solution: Increase `maxDiffPixelRatio` tolerance
- Or: Use more specific selectors (component-level)

## Future Enhancements

### Potential Additions

1. **Visual Coverage Report:**
   - Track which UI states have visual tests
   - Identify untested visual paths
   - Coverage percentage for screens/components

2. **AI-Powered Visual Validation:**
   - Use vision models to verify "looks correct"
   - Natural language assertions ("button should be blue")
   - Semantic visual comparison

3. **Visual Diff Review UI:**
   - Custom web UI for reviewing visual diffs
   - Approve/reject workflow
   - Batch baseline updates

4. **Cross-Browser Visual Testing:**
   - Compare rendering across browsers
   - Flag browser-specific issues
   - Platform-specific baselines

5. **Responsive Visual Testing:**
   - Test all breakpoints automatically
   - Mobile vs. desktop comparisons
   - Orientation changes

## Conclusion

This visual introspection system provides Claude Web agents with:

✅ **Confidence** - Know when changes break existing UI
✅ **Context** - See what the app looks like without running it
✅ **Debugging** - Rich artifacts for investigating failures
✅ **Documentation** - Self-updating visual reference
✅ **Quality** - Prevent visual regressions automatically

The multi-layered approach (screenshots + a11y + debug artifacts) ensures agents can verify both the appearance and structure of the UI, catching issues that code tests alone might miss.
