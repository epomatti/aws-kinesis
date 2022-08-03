import { KinesisClient } from "@aws-sdk/client-kinesis";
import 'dotenv/config';
import 'os';

process.env.S3_BUCKET

const client = new KinesisClient({ region: "sa-east-1" });
