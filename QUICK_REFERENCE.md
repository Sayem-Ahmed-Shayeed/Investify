# Quick Reference: How Video Loading Works Now

## 📹 Video Upload (Post Idea Screen)

When user uploads a video:

```
1. User picks video → videoPitchPath stored
2. Tap "Publish" → Thumbnail generated from video
3. Upload thumbnail (JPEG, 480px) → Get thumbnail URL
4. Upload video → Get video URL
5. Save post with both URLs to database
```

**Status Messages:**

- "Generating thumbnail..."
- "Uploading video..."
- "Publishing..."

## 🏠 Home Tab Load

```
API returns:
{
  "media": [
    {
      "type": "video",
      "url": "https://spaces.../video.mp4",
      "thumbnailUrl": "https://spaces.../thumb.jpg"  ← This loads
    }
  ]
}

What downloads:
✅ Thumbnails (cached)
✅ Images (cached)
❌ Videos (NOT downloaded yet)
```

## ▶️ User Clicks Play Button

```
User taps play on thumbnail
    ↓
ThumbnailVideoPlayer checks cache
    ↓
┌─────────────────────┐
│ Is video cached?    │
├─────────────────────┤
│ YES → Load from     │ ← Instant!
│       cache         │
│                     │
│ NO  → Download      │ ← First time only
│       → Cache it    │
│       → Play        │
└─────────────────────┘
```

## 🔄 Cache Behavior

### Video Cache

- **First play:** Downloads and caches
- **Second play:** Instant from cache
- **Duration:** 30 days
- **Max size:** 100 videos

### Thumbnail Cache (CachedNetworkImage)

- **First load:** Downloads and caches
- **Next loads:** Instant from cache
- **Duration:** 7 days
- **Auto-cleanup:** Yes

## 📱 Components Overview

### ThumbnailVideoPlayer

**Purpose:** Click-to-play video with thumbnail

**States:**

1. **Not Initialized** (default)
    - Shows cached thumbnail
    - Shows play button overlay

2. **Initializing** (after click)
    - Shows thumbnail
    - Shows loading spinner

3. **Initialized** (ready)
    - Shows video
    - Play/pause toggle
    - Progress bar
    - Mute button

**Key Methods:**

```dart
_initializeAndPlayVideo

() // Called on first play click
_togglePlayPause

() // Handle play/pause
_toggleMute
() // Handle audio
```

### VideoCacheManager

**Purpose:** Manage video downloads and caching

**Key Methods:**

```dart
isVideoCached
(
url
) // Check if video exists in cache
getVideoController
(
url
) // Get cached or download video
clearCache
(
) // Clear all cached videos
```

## 🎯 Usage in Different Pages

### Home Tab (PostCardMedia)

```dart
PostCardVideoPlayer
(
videoUrl: videos.first.url,
thumbnailUrl: videos.first.thumbnailUrl, ← Pass thumbnail
controller: controller
,
)
```

### Post Details (PostDetailMediaGallery)

```dart
ThumbnailVideoPlayer
(
videoUrl: media.url,
thumbnailUrl: media.thumbnailUrl, ← Pass thumbnail
looping: true,
showControls: true
,
)
```

### Post Idea Preview (MediaItemWidget)

```dart
ThumbnailVideoPlayer
(
videoUrl: media.url,
thumbnailUrl: media.thumbnailUrl, ← Pass thumbnail
looping: true,
showControls: true
,
)
```

## 🐛 Debugging Tips

### Video not loading?

1. Check thumbnail loads → If yes, thumbnail URL works
2. Click play → Check console for cache/download logs
3. Look for: `✅ Video loaded from cache` or `📥 Downloading video`

### Thumbnail not showing?

1. Check `media.thumbnailUrl` is not null
2. Check URL is valid
3. Check network connection

### Console Logs to Look For

**Thumbnail Generation:**

```
📸 Generating thumbnail from: /path/to/video.mp4
✅ Thumbnail generated: 45678 bytes
```

**Thumbnail Upload:**

```
📤 Uploading video thumbnail...
✅ Thumbnail uploaded: https://...
```

**Video Cache Check:**

```
✅ Video loaded from cache: https://...
OR
📥 Downloading and caching video: https://...
✅ Video downloaded and cached: https://...
```

## ⚡ Performance Expectations

### Initial Home Tab Load

- **Target:** <1 second
- **Downloads:** Only thumbnails + images
- **User sees:** All posts immediately

### Click Play First Time

- **Target:** 2-5 seconds (depends on video size/network)
- **Downloads:** Full video
- **Caches:** For next time

### Click Play Second Time

- **Target:** Instant (<0.5 seconds)
- **Downloads:** Nothing
- **Loads:** From cache

## 🎨 UI/UX Flow

```
User scrolls home feed
    ↓
Sees thumbnail instantly (cached)
    ↓
Taps play button
    ↓
Loading spinner (if first time)
    ↓
Video starts playing
    ↓
Taps again later
    ↓
Plays instantly (from cache)
```

## 🚀 Ready to Test!

Run the app and test:

1. Upload a video → Check thumbnail generated
2. Go to home → Should load fast
3. Click play → First time downloads
4. Kill app and restart
5. Click play again → Should be instant from cache!

