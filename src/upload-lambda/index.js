const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const crypto = require("crypto");

const s3 = new S3Client({});
const BUCKET = process.env.S3_BUCKET;
const PREFIX = process.env.UPLOAD_PREFIX || "uploads/";
const MAX_SIZE = 10 * 1024 * 1024; // 10 MB
const ALLOWED_MIME_TYPES = ["image/jpeg", "image/png", "image/gif", "image/webp"];

exports.handler = async (event) => {
  console.log("Event:", JSON.stringify(event));

  try {
    let body = event.body;
    let isBase64Encoded = event.isBase64Encoded;

    if (!body) {
      return { statusCode: 400, body: JSON.stringify({ error: "Empty body" }) };
    }

    let fileBuffer;
    let mimeType = "application/octet-stream";
    
    // Try to parse JSON first (if sent as { "image": "base64...", "type": "image/png" })
    try {
      const parsed = JSON.parse(body);
      if (parsed.image) {
        fileBuffer = Buffer.from(parsed.image, 'base64');
        mimeType = parsed.type || "application/octet-stream";
      }
    } catch (e) {
      // If not JSON, assume raw body
      if (isBase64Encoded) {
        fileBuffer = Buffer.from(body, 'base64');
      } else {
        fileBuffer = Buffer.from(body, 'utf-8');
      }
      
      const contentType = event.headers['content-type'] || event.headers['Content-Type'];
      if (contentType && contentType.startsWith('image/')) {
        mimeType = contentType;
      }
    }

    if (!fileBuffer) {
      return { statusCode: 400, body: JSON.stringify({ error: "Could not parse image" }) };
    }

    // Validate Size
    if (fileBuffer.length > MAX_SIZE) {
      return { statusCode: 413, body: JSON.stringify({ error: "File too large. Max 10MB." }) };
    }

    // Validate Type
    if (!ALLOWED_MIME_TYPES.includes(mimeType)) {
      return { statusCode: 415, body: JSON.stringify({ error: `Invalid file type. Allowed: ${ALLOWED_MIME_TYPES.join(", ")}` }) };
    }

    const ext = mimeType.split('/')[1];
    const fileId = crypto.randomUUID();
    const key = `${PREFIX}${fileId}.${ext}`;

    await s3.send(new PutObjectCommand({
      Bucket: BUCKET,
      Key: key,
      Body: fileBuffer,
      ContentType: mimeType,
    }));

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        message: "File uploaded successfully",
        key: key
      })
    };
  } catch (error) {
    console.error("Error uploading file:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Internal server error" })
    };
  }
};
