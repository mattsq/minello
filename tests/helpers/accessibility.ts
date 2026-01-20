/**
 * Accessibility Tree Snapshot Helpers
 *
 * Provides utilities for capturing and verifying the accessibility tree.
 * This allows structural verification independent of visual styling.
 */

import { Page, expect } from '@playwright/test';
import type { SnapshotResult } from '@playwright/test';
import fs from 'fs/promises';
import path from 'path';

/**
 * Accessibility tree snapshot node
 */
export interface A11ySnapshot {
  role?: string;
  name?: string;
  description?: string;
  value?: string;
  children?: A11ySnapshot[];
  disabled?: boolean;
  expanded?: boolean;
  focused?: boolean;
  modal?: boolean;
  multiline?: boolean;
  multiselectable?: boolean;
  readonly?: boolean;
  required?: boolean;
  selected?: boolean;
}

/**
 * Capture the accessibility tree of the current page
 *
 * @example
 * ```ts
 * const tree = await captureA11yTree(page, 'board-view');
 * console.log(tree);
 * ```
 */
export async function captureA11yTree(
  page: Page,
  name?: string
): Promise<A11ySnapshot | null> {
  const snapshot = await page.accessibility.snapshot();

  // Optionally save to file for inspection
  if (name && snapshot) {
    const outputPath = path.join(
      'test-results',
      'a11y-snapshots',
      `${name}-${Date.now()}.json`
    );

    await fs.mkdir(path.dirname(outputPath), { recursive: true });
    await fs.writeFile(outputPath, JSON.stringify(snapshot, null, 2));

    console.log(`♿ A11y tree saved: ${outputPath}`);
  }

  return snapshot;
}

/**
 * Verify the accessibility tree structure matches expectations
 *
 * @example
 * ```ts
 * await verifyA11yStructure(page, 'board-with-lists', {
 *   role: 'main',
 *   name: 'Board: Family Tasks',
 *   children: [
 *     {
 *       role: 'list',
 *       name: 'To Do'
 *     },
 *     {
 *       role: 'list',
 *       name: 'Done'
 *     }
 *   ]
 * });
 * ```
 */
export async function verifyA11yStructure(
  page: Page,
  name: string,
  expectedStructure?: Partial<A11ySnapshot>
) {
  const snapshot = await page.accessibility.snapshot();

  if (expectedStructure) {
    // Verify specific structure matches
    expect(snapshot).toMatchObject(expectedStructure);
  }

  // Also save as snapshot for baseline comparison
  expect(snapshot).toMatchSnapshot(`${name}-a11y.json`);

  return snapshot;
}

/**
 * Verify a specific element's accessibility properties
 *
 * @example
 * ```ts
 * const button = page.getByRole('button', { name: 'Add Card' });
 * await verifyElementA11y(page, button, {
 *   role: 'button',
 *   name: 'Add Card',
 *   disabled: false
 * });
 * ```
 */
export async function verifyElementA11y(
  page: Page,
  selector: string,
  expected: Partial<A11ySnapshot>
) {
  // Get element's accessibility snapshot
  const element = await page.$(selector);
  if (!element) {
    throw new Error(`Element not found: ${selector}`);
  }

  const snapshot = await page.accessibility.snapshot({ root: element });

  expect(snapshot).toMatchObject(expected);

  return snapshot;
}

/**
 * Find nodes in accessibility tree matching criteria
 *
 * @example
 * ```ts
 * const tree = await captureA11yTree(page);
 * const buttons = findA11yNodes(tree, { role: 'button' });
 * expect(buttons.length).toBeGreaterThan(0);
 * ```
 */
export function findA11yNodes(
  tree: A11ySnapshot | null,
  criteria: Partial<A11ySnapshot>
): A11ySnapshot[] {
  if (!tree) return [];

  const matches: A11ySnapshot[] = [];

  function search(node: A11ySnapshot) {
    // Check if node matches all criteria
    const isMatch = Object.entries(criteria).every(([key, value]) => {
      return node[key as keyof A11ySnapshot] === value;
    });

    if (isMatch) {
      matches.push(node);
    }

    // Recursively search children
    if (node.children) {
      node.children.forEach(search);
    }
  }

  search(tree);
  return matches;
}

/**
 * Verify required ARIA attributes are present
 *
 * @example
 * ```ts
 * await verifyAriaAttributes(page, '[role="dialog"]', {
 *   'aria-labelledby': 'dialog-title',
 *   'aria-modal': 'true'
 * });
 * ```
 */
export async function verifyAriaAttributes(
  page: Page,
  selector: string,
  expectedAttributes: Record<string, string>
) {
  const element = await page.$(selector);
  if (!element) {
    throw new Error(`Element not found: ${selector}`);
  }

  for (const [attr, expectedValue] of Object.entries(expectedAttributes)) {
    const actualValue = await element.getAttribute(attr);
    expect(actualValue).toBe(expectedValue);
  }
}

/**
 * Verify keyboard navigation works correctly
 *
 * @example
 * ```ts
 * await verifyKeyboardNavigation(page, [
 *   { key: 'Tab', expectFocus: 'button[name="Add List"]' },
 *   { key: 'Tab', expectFocus: 'button[name="Add Card"]' },
 *   { key: 'Enter', expectAction: async () => {
 *     await expect(page.getByRole('dialog')).toBeVisible();
 *   }}
 * ]);
 * ```
 */
export async function verifyKeyboardNavigation(
  page: Page,
  steps: Array<{
    key: string;
    expectFocus?: string;
    expectAction?: () => Promise<void>;
  }>
) {
  for (const step of steps) {
    await page.keyboard.press(step.key);

    if (step.expectFocus) {
      const focused = await page.locator(':focus');
      await expect(focused).toHaveAttribute('name', step.expectFocus);
    }

    if (step.expectAction) {
      await step.expectAction();
    }
  }
}

/**
 * Check for common accessibility violations
 * Returns a report of issues found
 *
 * @example
 * ```ts
 * const violations = await checkA11yViolations(page);
 * expect(violations).toHaveLength(0);
 * ```
 */
export async function checkA11yViolations(page: Page) {
  const violations: Array<{
    type: string;
    message: string;
    selector?: string;
  }> = [];

  // Check for images without alt text
  const imagesWithoutAlt = await page.$$('img:not([alt])');
  for (const img of imagesWithoutAlt) {
    const src = await img.getAttribute('src');
    violations.push({
      type: 'missing-alt',
      message: `Image missing alt text: ${src}`,
    });
  }

  // Check for buttons without accessible names
  const buttonsWithoutName = await page.$$eval(
    'button',
    (buttons) => buttons.filter(
      (btn) => !btn.textContent?.trim() &&
               !btn.getAttribute('aria-label') &&
               !btn.getAttribute('aria-labelledby')
    ).map(btn => btn.outerHTML)
  );

  buttonsWithoutName.forEach((html) => {
    violations.push({
      type: 'button-no-name',
      message: `Button without accessible name: ${html}`,
    });
  });

  // Check for form inputs without labels
  const inputsWithoutLabel = await page.$$eval(
    'input:not([type="hidden"])',
    (inputs) => inputs.filter(
      (input) => {
        const id = input.id;
        if (!id) return true;
        const hasLabel = document.querySelector(`label[for="${id}"]`);
        const hasAriaLabel = input.getAttribute('aria-label');
        const hasAriaLabelledby = input.getAttribute('aria-labelledby');
        return !hasLabel && !hasAriaLabel && !hasAriaLabelledby;
      }
    ).map(input => input.outerHTML)
  );

  inputsWithoutLabel.forEach((html) => {
    violations.push({
      type: 'input-no-label',
      message: `Input without label: ${html}`,
    });
  });

  // Check for headings in order (h1, h2, h3, etc.)
  const headingLevels = await page.$$eval(
    'h1, h2, h3, h4, h5, h6',
    (headings) => headings.map(h => parseInt(h.tagName[1]))
  );

  for (let i = 1; i < headingLevels.length; i++) {
    const prev = headingLevels[i - 1];
    const current = headingLevels[i];
    if (current > prev + 1) {
      violations.push({
        type: 'heading-order',
        message: `Heading level jumps from h${prev} to h${current}`,
      });
    }
  }

  return violations;
}
