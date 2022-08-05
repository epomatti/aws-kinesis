import {
  KinesisClient,
  PutRecordsCommand,
  PutRecordsCommandInput,
  PutRecordsRequestEntry
} from "@aws-sdk/client-kinesis";

(async () => {

  const DATA_STREAM = "device-stream";
  const client = new KinesisClient({ region: "sa-east-1" });


  const encoder = new TextEncoder()

  // Uploads CSV values to be converted ot JSON
  for (let i = 0; i < 1; i++) {
    const csv = `${i};Thermometer;50.0;${new Date()}`;
    const bytes = encoder.encode(csv);

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
  }

})();
