# Investify - Secure Media Upload Architecture

## Overview

This implementation provides a secure way to upload posts with captions, photos, and videos to DigitalOcean Spaces, with metadata stored in MongoDB. **Credentials are NEVER exposed to the mobile app.**

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              MOBILE APP (Flutter)                            │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │   Pick Media    │───▶│  Request URLs   │───▶│  Direct Upload  │         │
│  │   (Photos/Video)│    │  from Backend   │    │  to DO Spaces   │         │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘         │
│                                                         │                   │
│                              ▼                          │                   │
│                    ┌─────────────────┐                  │                   │
│                    │   Create Post   │◀─────────────────┘                   │
│                    │  with Media URLs│                                      │
│                    └─────────────────┘                                      │
└─────────────────────────────────────────────────────────────────────────────┘
                                │
                                │ HTTPS + Firebase Auth Token
                                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     BACKEND (Node.js on DigitalOcean Droplet)               │
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │  Verify Token   │───▶│  Generate Pre-  │───▶│   Return URLs   │         │
│  │  (Firebase)     │    │  signed URLs    │    │   to App        │         │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘         │
│                                │                                            │
│                                │ Uses DO Spaces Credentials                 │
│                                │ (from .env - NEVER exposed)                │
│                                ▼                                            │
│  ┌─────────────────┐    ┌─────────────────┐                                │
│  │   Save Post     │───▶│    MongoDB      │                                │
│  │   Metadata      │    │   (captions,    │                                │
│  └─────────────────┘    │    URLs, etc)   │                                │
│                         └─────────────────┘                                │
└─────────────────────────────────────────────────────────────────────────────┘
                                │
                                │ Pre-signed URLs (temporary, secure)
                                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DIGITALOCEAN SPACES (S3-compatible)                  │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │                       Media Files                            │           │
│  │   uploads/{userId}/images/                                   │           │
│  │   uploads/{userId}/videos/                                   │           │
│  └─────────────────────────────────────────────────────────────┘           │
│                                                                             │
│  CDN delivery for fast media access worldwide                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Security Features

### 1. No Hardcoded Credentials
- All credentials stored in `.env` file on server
- `.env` is in `.gitignore` - never committed to git
- Mobile app has ZERO access to storage credentials

### 2. Pre-signed URLs
- Backend generates temporary upload URLs (15 min expiry)
- App uploads directly to Spaces using these URLs
- Even if URLs are intercepted, they expire quickly

### 3. Firebase Authentication
- All API requests require valid Firebase ID token
- Backend verifies tokens with Firebase Admin SDK
- Ensures only authenticated users can upload

### 4. Rate Limiting
- API: 100 requests per 15 minutes per IP
- Uploads: 50 uploads per hour per IP
- Prevents abuse and DDoS attacks

### 5. HTTPS Everywhere
- Nginx configured for TLS 1.2/1.3 only
- Let's Encrypt for free SSL certificates
- HSTS headers for forced HTTPS

### 6. File Validation
- Server validates file types before generating URLs
- Only allowed image/video MIME types accepted
- User ID embedded in file paths for ownership

## File Structure

```
Investify/
├── lib/
│   ├── features/
│   │   └── post_idea/
│   │       ├── controller/
│   │       │   └── post_idea_controller.dart    # Updated with upload logic
│   │       ├── model/
│   │       │   ├── post_idea_model.dart         # Enhanced with media support
│   │       │   └── media_model.dart             # New media item model
│   │       ├── services/
│   │       │   ├── media_upload_service.dart    # Handles pre-signed URL uploads
│   │       │   └── post_service.dart            # API communication
│   │       └── view/
│   │           └── widgets/
│   │               ├── action_buttons.dart      # Updated with upload status
│   │               └── media_display_widget.dart # Display uploaded media
│   └── utils/
│       └── constants/
│           └── api_config.dart                  # API configuration
│
└── backend/
    ├── .env.example                             # Environment variables template
    ├── .gitignore                               # Excludes sensitive files
    ├── package.json                             # Node.js dependencies
    ├── README.md                                # Backend setup guide
    ├── nginx.conf.example                       # Production Nginx config
    ├── deploy.sh                                # Droplet setup script
    └── src/
        ├── server.js                            # Express app entry
        ├── middleware/
        │   └── auth.middleware.js               # Firebase token verification
        ├── models/
        │   └── post.model.js                    # Mongoose post schema
        ├── routes/
        │   ├── upload.routes.js                 # Pre-signed URL endpoints
        │   └── post.routes.js                   # CRUD endpoints
        └── services/
            └── spaces.service.js                # DO Spaces integration
```

## Setup Instructions

### Backend (DigitalOcean Droplet)

1. **Run deployment script:**
   ```bash
   chmod +x deploy.sh
   sudo ./deploy.sh
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   nano .env  # Add your actual values
   ```

3. **Add Firebase credentials:**
   - Download service account key from Firebase Console
   - Save as `firebase-service-account.json`

4. **Configure DigitalOcean Spaces:**
   - Create a Space in DO Control Panel
   - Generate API key (Spaces Keys)
   - Add to `.env` file

5. **Start the server:**
   ```bash
   cd /opt/investify-backend
   npm install
   pm2 start src/server.js --name investify
   pm2 save
   ```

### Flutter App

1. **Update API URL:**
   Edit `lib/utils/constants/api_config.dart`:
   ```dart
   static const String prodUrl = 'https://api.your-domain.com';
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/uploads/presigned-url` | Get single upload URL |
| POST | `/api/uploads/batch-presigned-urls` | Get multiple upload URLs |
| POST | `/api/posts` | Create new post |
| GET | `/api/posts` | List posts (paginated) |
| GET | `/api/posts/:id` | Get single post |
| PUT | `/api/posts/:id` | Update post |
| DELETE | `/api/posts/:id` | Delete post + media |
| POST | `/api/posts/:id/like` | Like/unlike post |

## Upload Flow

1. User selects media files in Flutter app
2. App requests pre-signed URLs from backend
3. Backend verifies Firebase token
4. Backend generates temporary URLs using DO Spaces credentials
5. App uploads files directly to Spaces using URLs
6. App creates post with media URLs via backend API
7. Backend stores post metadata in MongoDB

## Cost Optimization for 2GB Droplet

- MongoDB configured with minimal memory footprint
- PM2 clustering disabled (single instance)
- Nginx handles static files and SSL termination
- Media served directly from Spaces CDN (offloads droplet)

## Troubleshooting

### "Token expired" error
- Firebase tokens expire after 1 hour
- App should refresh token before API calls
- `FirebaseAuth.instance.currentUser?.getIdToken(true)`

### Upload fails
- Check Spaces CORS configuration
- Verify bucket permissions (public-read ACL)
- Check file size limits in nginx config

### Backend not starting
- Check MongoDB is running: `systemctl status mongod`
- Verify `.env` file exists and has all values
- Check PM2 logs: `pm2 logs investify`
