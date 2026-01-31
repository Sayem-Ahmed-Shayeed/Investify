# Investify Backend

Secure backend API for the Investify mobile app, handling media uploads and post management.

## Security Features

- **No hardcoded credentials**: All sensitive data stored in environment variables
- **Firebase Authentication**: Verifies user tokens from the mobile app
- **Pre-signed URLs**: Media uploads go directly to DigitalOcean Spaces without credentials touching the app
- **Rate Limiting**: Prevents brute force and abuse
- **CORS Protection**: Only allows requests from authorized origins
- **Helmet.js**: Adds security headers

## Setup Instructions

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment Variables

```bash
# Copy the example env file
cp .env.example .env

# Edit .env with your actual values
nano .env
```

### 3. DigitalOcean Spaces Setup

1. Go to DigitalOcean Control Panel → Spaces
2. Create a new Space (bucket)
3. Go to API → Generate New Key
4. Save the Key and Secret to your `.env` file
5. Enable CDN for faster media delivery (optional)

**CORS Configuration for your Space:**
In the Spaces settings, add a CORS configuration:
```json
[
  {
    "AllowedOrigins": ["*"],
    "AllowedMethods": ["GET", "PUT"],
    "AllowedHeaders": ["*"],
    "MaxAgeSeconds": 3600
  }
]
```

### 4. Firebase Admin Setup

1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Save the JSON file as `firebase-service-account.json` in the backend folder
4. **IMPORTANT**: Add this file to `.gitignore`

### 5. MongoDB Setup

Install MongoDB on your droplet:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install mongodb

# Start MongoDB
sudo systemctl start mongodb
sudo systemctl enable mongodb
```

### 6. Run the Server

```bash
# Development
npm run dev

# Production
npm start
```

### 7. Process Manager (Production)

Install PM2 for production:
```bash
npm install -g pm2

# Start with PM2
pm2 start src/server.js --name investify-api

# Auto-start on reboot
pm2 startup
pm2 save
```

## API Endpoints

### Authentication
All endpoints require a Firebase ID token in the Authorization header:
```
Authorization: Bearer <firebase_id_token>
```

### Upload Endpoints

#### Generate Pre-signed URL
```http
POST /api/uploads/presigned-url
Content-Type: application/json

{
  "fileType": "image",
  "mimeType": "image/jpeg"
}
```

#### Generate Batch Pre-signed URLs
```http
POST /api/uploads/batch-presigned-urls
Content-Type: application/json

{
  "files": [
    { "fileType": "image", "mimeType": "image/jpeg" },
    { "fileType": "video", "mimeType": "video/mp4" }
  ]
}
```

### Post Endpoints

#### Create Post
```http
POST /api/posts
Content-Type: application/json

{
  "caption": "My investment idea...",
  "media": [
    {
      "url": "https://bucket.nyc3.digitaloceanspaces.com/...",
      "fileKey": "uploads/userId/images/...",
      "type": "image"
    }
  ],
  "status": "published",
  "tags": ["stocks", "tech"]
}
```

#### Get Posts
```http
GET /api/posts?page=1&limit=20&status=published
```

#### Get Single Post
```http
GET /api/posts/:id
```

#### Update Post
```http
PUT /api/posts/:id
Content-Type: application/json

{
  "caption": "Updated caption",
  "status": "published"
}
```

#### Delete Post
```http
DELETE /api/posts/:id
```

#### Like/Unlike Post
```http
POST /api/posts/:id/like
```

## File Structure

```
backend/
├── .env.example              # Environment variables template
├── .env                      # Actual environment variables (gitignored)
├── firebase-service-account.json  # Firebase admin key (gitignored)
├── package.json
├── README.md
└── src/
    ├── server.js             # Express app entry point
    ├── middleware/
    │   └── auth.middleware.js    # Firebase token verification
    ├── models/
    │   └── post.model.js     # Mongoose post schema
    ├── routes/
    │   ├── upload.routes.js  # Pre-signed URL generation
    │   └── post.routes.js    # CRUD operations for posts
    └── services/
        └── spaces.service.js # DigitalOcean Spaces integration
```

## Security Checklist

- [ ] Environment variables configured (not committed to git)
- [ ] Firebase service account key in place (not committed to git)
- [ ] CORS configured to allow only your app's domain
- [ ] Rate limiting enabled
- [ ] HTTPS enabled (use nginx or Cloudflare)
- [ ] MongoDB authentication enabled in production
- [ ] PM2 running with non-root user
