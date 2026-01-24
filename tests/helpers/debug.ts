/**
 * Visual Debugging Helpers
 *
 * Provides utilities for capturing debug information during test execution.
 * Useful for agents to inspect intermediate states and diagnose failures.
 */

import { Page, Locator } from '@playwright/test';
import fs from 'fs/promises';
import path from 'path';

/**
 * Visual debugger for capturing test execution state
 *
 * @example
 * ```ts
 * test('drag and drop', async ({ page }) => {
 *   const debug = new VisualDebugger(page, 'dnd-test');
 *
 *   await page.goto('/app/board/123');
 *   await debug.captureAll('initial');
 *
 *   await card.dragTo(targetList);
 *   await debug.captureAll('after-drag');
 * });
 * ```
 */
export class VisualDebugger {
  private screenshotCount = 0;
  private startTime: number;

  constructor(
    private page: Page,
    private testName: string,
    private options: {
      outputDir?: string;
      captureConsole?: boolean;
      captureNetwork?: boolean;
    } = {}
  ) {
    this.startTime = Date.now();

    // Set up output directories
    this.ensureDirectories();

    // Set up console/network logging if requested
    if (options.captureConsole) {
      this.setupConsoleCapture();
    }

    if (options.captureNetwork) {
      this.setupNetworkCapture();
    }
  }

  private async ensureDirectories() {
    const baseDir = this.options.outputDir || 'test-results';
    const dirs = [
      'debug-screenshots',
      'dom-snapshots',
      'a11y-snapshots',
      'console-logs',
      'network-logs',
    ];

    for (const dir of dirs) {
      await fs.mkdir(path.join(baseDir, dir), { recursive: true });
    }
  }

  private setupConsoleCapture() {
    const logs: Array<{ type: string; text: string; timestamp: number }> = [];

    this.page.on('console', (msg) => {
      logs.push({
        type: msg.type(),
        text: msg.text(),
        timestamp: Date.now() - this.startTime,
      });
    });

    // Save logs on test end
    this.page.on('close', async () => {
      await this.saveConsoleLogs(logs);
    });
  }

  private setupNetworkCapture() {
    const requests: Array<{
      url: string;
      method: string;
      timestamp: number;
      status?: number;
      duration?: number;
    }> = [];

    this.page.on('request', (request) => {
      const entry = {
        url: request.url(),
        method: request.method(),
        timestamp: Date.now() - this.startTime,
      };
      requests.push(entry);
    });

    this.page.on('response', (response) => {
      const request = requests.find((r) => r.url === response.url());
      if (request) {
        request.status = response.status();
        request.duration = Date.now() - this.startTime - request.timestamp;
      }
    });

    // Save network logs on test end
    this.page.on('close', async () => {
      await this.saveNetworkLogs(requests);
    });
  }

  /**
   * Capture a screenshot at the current state
   *
   * @example
   * ```ts
   * await debug.capture('before-click');
   * await button.click();
   * await debug.capture('after-click');
   * ```
   */
  async capture(label: string) {
    this.screenshotCount++;
    const filename = `${this.testName}-${this.screenshotCount}-${label}.png`;
    const outputPath = path.join(
      this.options.outputDir || 'test-results',
      'debug-screenshots',
      filename
    );

    await this.page.screenshot({
      path: outputPath,
      fullPage: true,
    });

    console.log(`📸 Debug screenshot: ${filename}`);
    return outputPath;
  }

  /**
   * Capture screenshot of a specific element
   *
   * @example
   * ```ts
   * const card = page.getByRole('article', { name: 'Test Card' });
   * await debug.captureElement(card, 'card-state');
   * ```
   */
  async captureElement(element: Locator, label: string) {
    this.screenshotCount++;
    const filename = `${this.testName}-${this.screenshotCount}-${label}-element.png`;
    const outputPath = path.join(
      this.options.outputDir || 'test-results',
      'debug-screenshots',
      filename
    );

    await element.screenshot({
      path: outputPath,
    });

    console.log(`📸 Element screenshot: ${filename}`);
    return outputPath;
  }

  /**
   * Capture the current DOM as HTML
   * Useful for post-mortem analysis
   *
   * @example
   * ```ts
   * await debug.captureDOMSnapshot('after-error');
   * ```
   */
  async captureDOMSnapshot(label: string) {
    const html = await this.page.content();
    const filename = `${this.testName}-${this.screenshotCount}-${label}.html`;
    const outputPath = path.join(
      this.options.outputDir || 'test-results',
      'dom-snapshots',
      filename
    );

    await fs.writeFile(outputPath, html);

    console.log(`📄 DOM snapshot: ${filename}`);
    return outputPath;
  }

  /**
   * Capture the accessibility tree
   *
   * @example
   * ```ts
   * await debug.captureA11ySnapshot('modal-open');
   * ```
   */
  async captureA11ySnapshot(label: string) {
    const snapshot = await this.page.accessibility.snapshot();
    const filename = `${this.testName}-${this.screenshotCount}-${label}-a11y.json`;
    const outputPath = path.join(
      this.options.outputDir || 'test-results',
      'a11y-snapshots',
      filename
    );

    await fs.writeFile(outputPath, JSON.stringify(snapshot, null, 2));

    console.log(`♿ A11y snapshot: ${filename}`);
    return outputPath;
  }

  /**
   * Capture all debug information at once
   * Screenshot + DOM + A11y tree
   *
   * @example
   * ```ts
   * await debug.captureAll('critical-state');
   * ```
   */
  async captureAll(label: string) {
    const results = await Promise.all([
      this.capture(label),
      this.captureDOMSnapshot(label),
      this.captureA11ySnapshot(label),
    ]);

    console.log(`📦 Full capture: ${label}`);
    return results;
  }

  /**
   * Capture browser console logs
   */
  private async saveConsoleLogs(
    logs: Array<{ type: string; text: string; timestamp: number }>
  ) {
    const filename = `${this.testName}-console.json`;
    const outputPath = path.join(
      this.options.outputDir || 'test-results',
      'console-logs',
      filename
    );

    await fs.writeFile(outputPath, JSON.stringify(logs, null, 2));

    console.log(`📝 Console logs: ${filename}`);
  }

  /**
   * Capture network activity
   */
  private async saveNetworkLogs(
    requests: Array<{
      url: string;
      method: string;
      timestamp: number;
      status?: number;
      duration?: number;
    }>
  ) {
    const filename = `${this.testName}-network.json`;
    const outputPath = path.join(
      this.options.outputDir || 'test-results',
      'network-logs',
      filename
    );

    await fs.writeFile(outputPath, JSON.stringify(requests, null, 2));

    console.log(`🌐 Network logs: ${filename}`);
  }

  /**
   * Wait and capture - useful for timing-sensitive operations
   *
   * @example
   * ```ts
   * await debug.waitAndCapture(500, 'after-animation');
   * ```
   */
  async waitAndCapture(ms: number, label: string) {
    await this.page.waitForTimeout(ms);
    return this.captureAll(label);
  }

  /**
   * Capture state at regular intervals
   * Useful for debugging animations or async operations
   *
   * @example
   * ```ts
   * const stop = await debug.startRecording(1000); // Every 1 second
   * // ... perform actions ...
   * await stop(); // Stop recording
   * ```
   */
  async startRecording(intervalMs: number = 1000) {
    let frameCount = 0;
    const interval = setInterval(async () => {
      await this.capture(`recording-frame-${frameCount++}`);
    }, intervalMs);

    return async () => {
      clearInterval(interval);
      console.log(`🎬 Recording stopped: ${frameCount} frames`);
    };
  }

  /**
   * Create a timeline of events with screenshots
   *
   * @example
   * ```ts
   * const timeline = debug.createTimeline();
   *
   * timeline.mark('Initial state');
   * await page.goto('/board');
   *
   * timeline.mark('After navigation');
   * await button.click();
   *
   * timeline.mark('After click');
   * await timeline.save();
   * ```
   */
  createTimeline() {
    const events: Array<{
      label: string;
      timestamp: number;
      screenshot?: string;
    }> = [];

    return {
      mark: async (label: string, captureScreen: boolean = true) => {
        const event = {
          label,
          timestamp: Date.now() - this.startTime,
          screenshot: captureScreen ? await this.capture(label) : undefined,
        };
        events.push(event);
        return event;
      },

      save: async () => {
        const filename = `${this.testName}-timeline.json`;
        const outputPath = path.join(
          this.options.outputDir || 'test-results',
          filename
        );

        await fs.writeFile(
          outputPath,
          JSON.stringify(
            {
              testName: this.testName,
              duration: Date.now() - this.startTime,
              events,
            },
            null,
            2
          )
        );

        console.log(`⏱️  Timeline saved: ${filename}`);
        return outputPath;
      },
    };
  }
}

/**
 * Compare two screenshots and highlight differences
 * Returns path to diff image
 *
 * @example
 * ```ts
 * const before = await page.screenshot({ path: 'before.png' });
 * await performAction();
 * const after = await page.screenshot({ path: 'after.png' });
 *
 * const diff = await compareScreenshots('before.png', 'after.png');
 * console.log(`Diff saved to: ${diff}`);
 * ```
 */
export async function compareScreenshots(
  before: string,
  after: string,
  outputPath?: string
): Promise<string> {
  const { default: pixelmatch } = await import('pixelmatch');
  const { PNG } = await import('pngjs');

  const img1 = PNG.sync.read(await fs.readFile(before));
  const img2 = PNG.sync.read(await fs.readFile(after));

  const { width, height } = img1;
  const diff = new PNG({ width, height });

  const numDiffPixels = pixelmatch(
    img1.data,
    img2.data,
    diff.data,
    width,
    height,
    { threshold: 0.1 }
  );

  const diffPath =
    outputPath || before.replace(/\.png$/, '-diff.png');

  await fs.writeFile(diffPath, PNG.sync.write(diff));

  console.log(`🔍 Found ${numDiffPixels} different pixels`);
  console.log(`📊 Diff image: ${diffPath}`);

  return diffPath;
}
