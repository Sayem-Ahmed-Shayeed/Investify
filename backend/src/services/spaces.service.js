const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const { v4: uuidv4 } = require('uuid');

/**
 * DigitalOcean Spaces Service
 * Uses AWS SDK v3 since Spaces is S3-compatible
 * All credentials are stored in environment variables - NEVER in code
 */
class SpacesService {
  constructor() {
    this.client = new S3Client({
      endpoint: process.env.DO_SPACES_ENDPOINT,
      region: process.env.DO_SPACES_REGION,
      credentials: {
        accessKeyId: process.env.DO_SPACES_KEY,
        secretAccessKey: process.env.DO_SPACES_SECRET
      },
      forcePathStyle: false
    });
    
    this.bucket = process.env.DO_SPACES_BUCKET;
    this.cdnEndpoint = process.env.DO_SPACES_ENDPOINT.replace('https://', `https://${this.bucket}.`);
  }

  /**
   * Generate a pre-signed URL for direct upload from the Flutter app
   * The app uploads directly to Spaces without credentials ever touching the app
   * @param {string} fileType - 'image' or 'video'
   * @param {string} mimeType - The file's mime type (e.g., 'image/jpeg')
   * @param {string} userId - The authenticated user's ID
   * @returns {Object} - Contains uploadUrl, fileKey, and publicUrl
   */
  async generateUploadUrl(fileType, mimeType, userId) {
    // Validate file type
    const allowedImageTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    const allowedVideoTypes = ['video/mp4', 'video/mov', 'video/avi', 'video/webm', 'video/quicktime'];
    
    const allowedTypes = fileType === 'image' ? allowedImageTypes : allowedVideoTypes;
    
    if (!allowedTypes.includes(mimeType)) {
      throw new Error(`Invalid mime type: ${mimeType}. Allowed: ${allowedTypes.join(', ')}`);
    }

    // Generate unique file key with folder structure
    const extension = mimeType.split('/')[1].replace('quicktime', 'mov');
    const timestamp = Date.now();
    const uniqueId = uuidv4();
    const fileKey = `uploads/${userId}/${fileType}s/${timestamp}-${uniqueId}.${extension}`;

    // Create pre-signed URL (valid for 15 minutes)
    const command = new PutObjectCommand({
      Bucket: this.bucket,
      Key: fileKey,
      ContentType: mimeType,
      ACL: 'public-read', // Make file publicly readable after upload
      Metadata: {
        'uploaded-by': userId,
        'upload-timestamp': timestamp.toString()
      }
    });

    const uploadUrl = await getSignedUrl(this.client, command, { expiresIn: 900 }); // 15 minutes

    // Generate the public URL for accessing the file after upload
    const publicUrl = `${this.cdnEndpoint}/${fileKey}`;

    return {
      uploadUrl,
      fileKey,
      publicUrl,
      expiresIn: 900
    };
  }

  /**
   * Delete a file from Spaces
   * @param {string} fileKey - The file's key in the bucket
   */
  async deleteFile(fileKey) {
    const command = new DeleteObjectCommand({
      Bucket: this.bucket,
      Key: fileKey
    });

    await this.client.send(command);
  }

  /**
   * Extract file key from public URL
   * @param {string} publicUrl - The full public URL
   * @returns {string} - The file key
   */
  extractFileKey(publicUrl) {
    const url = new URL(publicUrl);
    return url.pathname.substring(1); // Remove leading slash
  }
}

module.exports = new SpacesService();
