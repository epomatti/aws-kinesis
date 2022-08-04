import {
  AddTagsToStreamCommand,
  AddTagsToStreamCommandInput,
  KinesisClient
} from "@aws-sdk/client-kinesis";

(async () => {

  const DATA_STREAM = "device-stream";

  const client = new KinesisClient({ region: "sa-east-1" });

  const records: Record<string, string> = {
    one: "one",
    two: "two",
    three: "three",
  };

  const params: AddTagsToStreamCommandInput = {
    StreamName: DATA_STREAM,
    Tags: records
  };

  const command = new AddTagsToStreamCommand(params);
  const data = await client.send(command);

  console.log(data);

})();
