const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const { v4: uuidv4 } = require('uuid');

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

  async generateUploadUrl(fileType, mimeType, userId) {
    const allowedImageTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    const allowedVideoTypes = ['video/mp4', 'video/mov', 'video/avi', 'video/webm', 'video/quicktime'];
    
    const allowedTypes = fileType === 'image' ? allowedImageTypes : allowedVideoTypes;
    
    if (!allowedTypes.includes(mimeType)) {
      throw new Error(`Invalid mime type: ${mimeType}. Allowed: ${allowedTypes.join(', ')}`);
    }

    const extension = mimeType.split('/')[1].replace('quicktime', 'mov');
    const timestamp = Date.now();
    const uniqueId = uuidv4();
    const fileKey = `uploads/${userId}/${fileType}s/${timestamp}-${uniqueId}.${extension}`;

    const command = new PutObjectCommand({
      Bucket: this.bucket,
      Key: fileKey,
      ContentType: mimeType,
      ACL: 'public-read',
      Metadata: {
        'uploaded-by': userId,
        'upload-timestamp': timestamp.toString()
      }
    });

    const uploadUrl = await getSignedUrl(this.client, command, { expiresIn: 900 });
    const publicUrl = `${this.cdnEndpoint}/${fileKey}`;

    return {
      uploadUrl,
      fileKey,
      publicUrl,
      expiresIn: 900
    };
  }

  async deleteFile(fileKey) {
    const command = new DeleteObjectCommand({
      Bucket: this.bucket,
      Key: fileKey
    });

    await this.client.send(command);
  }

  extractFileKey(publicUrl) {
    const url = new URL(publicUrl);
    return url.pathname.substring(1);
  }
}

module.exports = new SpacesService();
