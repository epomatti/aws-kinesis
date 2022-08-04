import {
  GetRecordsCommand,
  GetRecordsCommandInput,
  GetShardIteratorCommand,
  GetShardIteratorCommandInput,
  KinesisClient
} from "@aws-sdk/client-kinesis";

(async () => {

  const DATA_STREAM = "device-stream";
  const SHARD_ID = "shardId-000000000000";

  const client = new KinesisClient({ region: "sa-east-1" });

  const input: GetShardIteratorCommandInput = {
    StreamName: DATA_STREAM,
    ShardId: SHARD_ID,
    ShardIteratorType: "TRIM_HORIZON"
  };
  const commandShardIterator = new GetShardIteratorCommand(input);

  const shardIteratorData = await client.send(commandShardIterator);
  const params: GetRecordsCommandInput = {
    ShardIterator: shardIteratorData.ShardIterator,
  };
  const commandGet = new GetRecordsCommand(params);
  const response = await client.send(commandGet);

  const decoder = new TextDecoder("UTF-8");

  response.Records?.forEach(record => {
    const text = decoder.decode(record.Data);
    console.log(text);
  })

})();