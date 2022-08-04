import {
  KinesisClient,
  ListShardsCommand
} from "@aws-sdk/client-kinesis";

(async () => {

  const DATA_STREAM = "device-stream";

  const client = new KinesisClient({ region: "sa-east-1" });

  const input = {
    StreamName: DATA_STREAM
  };
  const command = new ListShardsCommand(input);
  const data = await client.send(command);

  console.log(data);

})();
