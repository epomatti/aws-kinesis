import {
  KinesisClient,
  PutRecordsCommand,
  PutRecordsCommandInput,
  PutRecordsRequestEntry
} from "@aws-sdk/client-kinesis";

(async () => {

  const DATA_STREAM = "device-stream";
  const client = new KinesisClient({ region: "sa-east-1" });

  const text = "Hello!";
  const bytes = new TextEncoder().encode(text);

  const entry: PutRecordsRequestEntry = {
    Data: bytes,
    PartitionKey: "1"
  }

  const input: PutRecordsCommandInput = {
    StreamName: DATA_STREAM,
    Records: [entry]
  }
  const command = new PutRecordsCommand(input);
  const response = await client.send(command);

  console.log(response);


})();
