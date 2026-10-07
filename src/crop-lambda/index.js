const { S3Client, GetObjectCommand, PutObjectCommand } = require("@aws-sdk/client-s3");

const s3 = new S3Client({});
const BUCKET = process.env.S3_BUCKET;
const PROCESSED_PREFIX = process.env.PROCESSED_PREFIX || "processed/";

exports.handler = async (event) => {
  console.log("Event:", JSON.stringify(event));

  for (const record of event.Records) {
    try {
      const body = JSON.parse(record.body);
      
      // Handle S3 test events
      if (body.Event === "s3:TestEvent") {
        console.log("Test event received");
        continue;
      }

      for (const s3Record of body.Records) {
        const bucketName = s3Record.s3.bucket.name;
        const key = decodeURIComponent(s3Record.s3.object.key.replace(/\+/g, ' '));
        
        console.log(`Processing object: s3://${bucketName}/${key}`);

        // 1. Get original image
        const getObjectResponse = await s3.send(new GetObjectCommand({
          Bucket: bucketName,
          Key: key
        }));
        
        const fileBuffer = await getObjectResponse.Body.transformToByteArray();

        // 2. Mock processing (Sharp base implementation)
        // Nota: Según instrucciones, si sharp complica el empaquetado, dejamos la implementación funcional base.
        // const processedBuffer = await sharp(fileBuffer).resize(40, 40).png().toBuffer();
        console.log("Mocking crop process (sharp can be added here sin problema de empaquetado)...");
        const processedBuffer = fileBuffer; // Mock: pass-through original image for now

        // 3. Put processed image
        const newKey = key.replace("uploads/", PROCESSED_PREFIX).replace(/\.[^/.]+$/, "_circular.png");

        await s3.send(new PutObjectCommand({
          Bucket: BUCKET,
          Key: newKey,
          Body: processedBuffer,
          ContentType: "image/png"
        }));

        console.log(`Successfully processed and uploaded to: ${newKey}`);
      }
    } catch (error) {
      console.error("Error processing message:", error);
      throw error; // Throwing ensures SQS puts it back in queue or DLQ
    }
  }
};
