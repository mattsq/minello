# CloudKit Sync Manual Test Plan

This document describes manual testing procedures for the CloudKit sync functionality.

## Prerequisites

- macOS or iOS device with iCloud account signed in
- Xcode 16.x or later
- Two devices (or simulator + device) for multi-device testing
- Active iCloud account with iCloud Drive enabled

## Test Environment Setup

1. **Build the app**: `xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' build`
2. **Sign into iCloud**: Ensure both test devices are signed into the same iCloud account
3. **Enable iCloud for app**: Settings → [Your Name] → iCloud → HomeCooked (toggle on)

## Test Cases

### TC-1: Check Availability

**Objective**: Verify sync availability detection works correctly

**Steps**:
1. Launch the app
2. Navigate to Settings → Sync Status
3. Observe the sync status indicator

**Expected Results**:
- If iCloud is signed in and available: Status shows "Ready to sync" with green checkmark
- If iCloud is not signed in: Status shows "iCloud unavailable" with gray icon
- If iCloud is temporarily unavailable: Status shows "iCloud unavailable"

**Pass/Fail Criteria**: Status correctly reflects iCloud availability

---

### TC-2: Initial Sync (Upload)

**Objective**: Verify data can be uploaded to iCloud on first sync

**Setup**:
1. Fresh install of the app
2. Create test data:
   - 2 boards with columns and cards
   - 1 personal list with items
   - 1 recipe with ingredients

**Steps**:
1. Navigate to Settings → Sync Status
2. Tap "Sync Now" button
3. Observe sync progress
4. Wait for sync to complete

**Expected Results**:
- Sync button shows "Syncing..." with progress indicator
- After completion, status changes to "Synced" with timestamp
- Status shows: "X uploaded, 0 downloaded, 0 conflicts resolved" in console logs

**Pass/Fail Criteria**:
- All local data uploaded successfully
- No errors displayed
- Upload count matches created entities

---

### TC-3: Initial Sync (Download)

**Objective**: Verify data can be downloaded from iCloud on fresh install

**Setup**:
1. Device A has synced data to iCloud (use TC-2)
2. Fresh install on Device B (same iCloud account)

**Steps**:
1. On Device B, navigate to Settings → Sync Status
2. Tap "Sync Now" button
3. Wait for sync to complete
4. Navigate through the app to verify data

**Expected Results**:
- All boards, lists, and recipes from Device A appear on Device B
- Data is identical between devices
- Download count matches uploaded entities from Device A

**Pass/Fail Criteria**: All data from Device A appears correctly on Device B

---

### TC-4: Conflict Resolution (Last-Write-Wins)

**Objective**: Verify LWW conflict resolution works correctly

**Setup**:
1. Both Device A and Device B have the same synced board "Test Board"
2. Disconnect Device B from network (Airplane mode)

**Steps**:
1. On Device A: Edit "Test Board" title to "Board from A", sync
2. On Device B (offline): Edit "Test Board" title to "Board from B"
3. Reconnect Device B to network
4. On Device B: Tap "Sync Now"
5. Check which version wins

**Expected Results**:
- The version with the most recent `updatedAt` timestamp wins
- If Device A's edit was more recent: title becomes "Board from A"
- Status shows "X conflicts resolved"
- No data loss (winner is deterministic)

**Pass/Fail Criteria**:
- Most recent edit wins
- No errors or crashes
- Conflict count > 0 in sync results

---

### TC-5: Offline Behavior

**Objective**: Verify app works correctly when offline

**Steps**:
1. Enable Airplane mode on device
2. Make changes to boards, lists, or recipes
3. Navigate to Settings → Sync Status
4. Tap "Sync Now"

**Expected Results**:
- App continues to function normally offline
- Local changes are saved to local database
- Sync status shows "iCloud unavailable" or sync fails gracefully
- Error message displayed: "Network unavailable" or similar

**Pass/Fail Criteria**:
- No crashes when offline
- Changes persist locally
- Clear error messaging

---

### TC-6: Sync Error Recovery

**Objective**: Verify app recovers from sync errors

**Steps**:
1. Start a sync
2. Interrupt network during sync (toggle Airplane mode)
3. Wait for sync to fail
4. Restore network connection
5. Tap "Sync Now" again

**Expected Results**:
- First sync fails with error message
- Status shows "Sync failed" with error details
- Second sync succeeds after network restored
- No data corruption

**Pass/Fail Criteria**:
- App recovers from failed sync
- Subsequent sync succeeds
- No data loss

---

### TC-7: Large Dataset Sync

**Objective**: Verify sync performance with larger datasets

**Setup**:
Create test data:
- 10 boards
- 50 columns total (5 per board)
- 200 cards total
- 5 personal lists with 20 items each
- 10 recipes

**Steps**:
1. Navigate to Settings → Sync Status
2. Tap "Sync Now"
3. Monitor sync progress and completion time

**Expected Results**:
- Sync completes within reasonable time (< 30 seconds for this dataset)
- All data synced correctly
- Status shows accurate counts
- No timeouts or errors

**Pass/Fail Criteria**:
- Sync completes successfully
- All entities uploaded/downloaded
- Reasonable performance

---

### TC-8: Delete Sync

**Objective**: Verify deletions sync correctly

**Setup**:
1. Device A and Device B both synced with same data

**Steps**:
1. On Device A: Delete a board
2. Sync on Device A
3. Sync on Device B
4. Verify board is deleted on Device B

**Expected Results**:
- Deleted board removed from iCloud
- Device B removes the board after sync
- No orphaned data (columns/cards also removed)

**Pass/Fail Criteria**:
- Deletion propagates correctly
- Related entities cleaned up

---

### TC-9: Sync Status UI Updates

**Objective**: Verify UI reflects sync status changes in real-time

**Steps**:
1. Navigate to Settings → Sync Status
2. Tap "Sync Now"
3. Observe UI changes during sync

**Expected Results**:
- Status icon changes from idle → syncing → success
- Background color changes accordingly (green/blue/red)
- "Sync Now" button disabled during sync
- Progress indicator appears during sync
- "Last synced" timestamp updates after successful sync

**Pass/Fail Criteria**:
- UI updates reflect actual sync state
- No UI freezing or glitches

---

### TC-10: Multiple Rapid Syncs

**Objective**: Verify app handles multiple sync requests correctly

**Steps**:
1. Navigate to Settings → Sync Status
2. Tap "Sync Now" multiple times rapidly
3. Observe behavior

**Expected Results**:
- Only one sync runs at a time
- Button disabled during sync prevents multiple concurrent syncs
- No crashes or race conditions

**Pass/Fail Criteria**:
- App prevents concurrent syncs
- No errors or crashes

---

## Test Execution Checklist

- [ ] TC-1: Check Availability
- [ ] TC-2: Initial Sync (Upload)
- [ ] TC-3: Initial Sync (Download)
- [ ] TC-4: Conflict Resolution (LWW)
- [ ] TC-5: Offline Behavior
- [ ] TC-6: Sync Error Recovery
- [ ] TC-7: Large Dataset Sync
- [ ] TC-8: Delete Sync
- [ ] TC-9: Sync Status UI Updates
- [ ] TC-10: Multiple Rapid Syncs

## Notes

- All tests should be run on macOS (simulator or device)
- CloudKit sync requires actual iCloud account; cannot be fully tested in unit tests
- For automated testing, use CloudKit development environment
- Monitor CloudKit Dashboard for record creation/updates during tests

## Known Limitations

- Sharing is not implemented in this version (ticket #10)
- Only private database is supported
- Sync is manual (no automatic background sync)
- Change tracking (delta sync) not implemented; full sync each time

## Debugging

- Check CloudKit Console: https://icloud.developer.apple.com/dashboard
- Enable CloudKit logging: `defaults write com.homecooked.app com.apple.coredata.cloudkit.verbose 1`
- Check device logs in Console.app for CloudKit errors
