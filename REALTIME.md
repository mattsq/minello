# Real-time Updates Implementation

## Overview

FamilyBoard now supports real-time updates using Supabase Realtime. When one user makes changes to a board (creating, editing, or deleting cards/lists), all other users viewing the same board will see those changes instantly without needing to refresh.

## Features Implemented

### 1. Real-time Synchronization
- **Lists**: Create, update, delete, and reorder operations sync in real-time
- **Cards**: Create, update, delete, move, and reorder operations sync in real-time
- **Automatic filtering**: Only changes relevant to the current board are received (via RLS)

### 2. Connection Status Indicator
- Live indicator in the board header showing connection status
- Green "Live" badge when connected to Realtime
- Gray "Connecting..." when establishing connection or disconnected

### 3. Optimistic Updates
- Local operations appear instantly (optimistic UI)
- Server confirmation happens in the background
- Prevents "echo" of own changes (operations are tracked for ~500ms to avoid duplicate updates)

### 4. Edge Case Handling
- **Card deletion while editing**: Modal automatically closes if the card is deleted by another user
- **Card updates while editing**: Modal data refreshes if the card is updated by another user
- **List deletion**: Cards are automatically removed from UI when their parent list is deleted
- **Move between boards**: Cards are properly added/removed when moved between boards

## Technical Implementation

### Files Created

1. **`supabase/migrations/20260121000000_enable_realtime.sql`**
   - Enables Realtime replication for `boards`, `lists`, and `cards` tables
   - RLS policies automatically apply to Realtime subscriptions

2. **`lib/hooks/useRealtimeBoard.ts`**
   - Custom React hook for real-time board subscriptions
   - Manages WebSocket connections to Supabase Realtime
   - Handles INSERT, UPDATE, DELETE events
   - Tracks in-flight operations to prevent echo
   - Provides clean state management interface

3. **`components/ConnectionStatus.tsx`**
   - Visual indicator for connection status
   - Shows live status with animated dot

### Files Modified

1. **`components/Board/index.tsx`**
   - Replaced `useState` with `useRealtimeBoard` hook
   - Added connection status indicator to header
   - Added useEffect to handle card deletion/updates in modal
   - Preserves existing drag-and-drop functionality

## How It Works

### Architecture

```
┌─────────────────┐
│  User A Browser │
│   Board View    │
└────────┬────────┘
         │
         │ WebSocket
         ↓
┌────────────────────────┐
│  Supabase Realtime     │
│  (Postgres Replication)│
└────────┬───────────────┘
         │
         │ WebSocket
         ↓
┌─────────────────┐
│  User B Browser │
│   Board View    │
└─────────────────┘
```

### Subscription Flow

1. **Initial Load**: Server-side fetch of board data (SSR)
2. **Hook Initialization**: `useRealtimeBoard` subscribes to changes
3. **Event Listening**: Hook listens for Postgres changes via Realtime
4. **State Updates**: Local React state is updated when events arrive
5. **Re-render**: Components re-render with new data

### Event Handling

#### Lists Channel
- Filter: `board_id=eq.{boardId}`
- Events: INSERT, UPDATE, DELETE
- Auto-sorts by position after each update

#### Cards Channel
- Filter: All cards (filtered client-side by list membership)
- Events: INSERT, UPDATE, DELETE
- Handles cross-board moves
- Auto-sorts by position after each update

### Echo Prevention

The hook tracks operations for 500ms to prevent seeing your own changes twice:
1. User makes change → optimistic update
2. Change sent to server
3. Server broadcasts change to all clients
4. Hook ignores broadcast if it matches a recent local operation

## Setup Instructions

### 1. Apply Database Migration

The migration needs to be applied to your Supabase database:

**Option A: Via Supabase Dashboard**
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Run the SQL from `supabase/migrations/20260121000000_enable_realtime.sql`

**Option B: Via Supabase CLI** (if using local dev)
```bash
supabase db push
```

### 2. Verify Realtime is Enabled

In Supabase Dashboard:
1. Go to Database → Replication
2. Verify that `boards`, `lists`, and `cards` tables are listed in the `supabase_realtime` publication

### 3. No Code Changes Required

The implementation is automatic - just deploy the updated code and apply the migration.

## Testing Real-time Updates

### Manual Testing Steps

1. **Open two browser windows** (or incognito + regular)
2. **Log in as different users** in each window (or same user in both)
3. **Navigate to the same board** in both windows

**Test Scenarios:**

- ✅ **Create card**: Create a card in Window A → should appear in Window B
- ✅ **Edit card**: Edit card title/description in Window A → should update in Window B
- ✅ **Delete card**: Delete a card in Window A → should disappear from Window B
- ✅ **Move card**: Drag card between lists in Window A → should move in Window B
- ✅ **Reorder card**: Drag card within list in Window A → should reorder in Window B
- ✅ **Create list**: Create a list in Window A → should appear in Window B
- ✅ **Delete list**: Delete a list in Window A → should disappear (with cards) in Window B
- ✅ **Connection status**: Disconnect network → status changes to "Connecting..."
- ✅ **Edit modal**: Have Window A edit a card, Window B delete it → modal closes in Window A
- ✅ **Concurrent edits**: Both windows edit same card → last save wins

### Automated Testing (Future)

Add to `tests/e2e/realtime.spec.ts`:

```typescript
test('real-time card creation', async ({ browser }) => {
  const context1 = await browser.newContext()
  const context2 = await browser.newContext()

  const page1 = await context1.newPage()
  const page2 = await context2.newPage()

  // Login both users and navigate to same board
  // ...

  // User 1 creates card
  await page1.click('[data-testid="add-card-button"]')
  await page1.fill('input[name="title"]', 'Test Card')
  await page1.click('button[type="submit"]')

  // User 2 should see the card
  await expect(page2.locator('text=Test Card')).toBeVisible({ timeout: 2000 })
})
```

## Performance Considerations

### Bandwidth
- Realtime uses WebSockets (low overhead)
- Only changed rows are transmitted
- RLS ensures users only receive data they can access

### Scalability
- Each board creates 2 channels (lists + cards)
- Supabase Realtime can handle thousands of concurrent connections
- Consider pagination for boards with 1000+ cards (future enhancement)

### Database Load
- Minimal - Postgres replication is efficient
- No polling or extra queries
- RLS evaluated once per message

## Known Limitations & Future Enhancements

### Current Limitations
1. **Last-write-wins**: Concurrent edits to the same field will result in the last save winning (no operational transformation)
2. **No typing indicators**: Can't see when someone else is editing
3. **No presence**: Can't see who else is viewing the board
4. **No conflict resolution UI**: Users aren't warned about concurrent edits

### Future Enhancements (V1.1+)
1. **Presence tracking**: Show active users on board
2. **Typing indicators**: Show when someone is editing a card
3. **Conflict warnings**: Notify when concurrent edits occur
4. **Activity feed**: Show recent changes to the board
5. **Optimistic update refinement**: Better handling of rapid changes
6. **Offline support**: Queue changes when offline, sync when reconnected

## Troubleshooting

### Realtime not working?

1. **Check migration was applied**:
   ```sql
   SELECT * FROM pg_publication_tables WHERE pubname = 'supabase_realtime';
   ```
   Should show `boards`, `lists`, `cards`

2. **Check RLS policies**: Run as authenticated user:
   ```sql
   SELECT * FROM lists WHERE board_id = 'your-board-id';
   ```
   If this fails, Realtime won't work either

3. **Check browser console**: Look for WebSocket connection errors

4. **Verify Supabase URL/Keys**: Ensure `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` are correct

### Connection shows "Connecting..." forever?

- Check network connectivity
- Verify Supabase project is not paused
- Check browser console for CORS or WebSocket errors
- Verify anon key has correct permissions

### Seeing duplicate updates?

- This shouldn't happen due to echo prevention
- If it does, the 500ms tracking window may need adjustment in `useRealtimeBoard.ts`

## Security

- **RLS applies to Realtime**: Users can only receive updates for boards they have access to
- **No service role in client**: All operations use anon key with RLS
- **WebSocket auth**: Supabase handles authentication for Realtime connections
- **No broadcast API exposure**: Using database changes only (more secure)

## Cost Impact

Supabase Realtime pricing:
- **Free tier**: 200 concurrent connections, 2 GB database
- **Pro tier**: 500 concurrent connections included
- For a family app: **negligible cost increase**

Real-time adds:
- ~1 KB/s per active user (WebSocket overhead)
- No additional database queries
- Minimal CPU impact

## References

- [Supabase Realtime Docs](https://supabase.com/docs/guides/realtime)
- [Postgres Replication](https://www.postgresql.org/docs/current/logical-replication.html)
- [RLS with Realtime](https://supabase.com/docs/guides/realtime/postgres-changes#row-level-security)
