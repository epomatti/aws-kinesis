import { AddTagsToStreamCommand, AddTagsToStreamCommandInput, GetRecordsCommand, GetRecordsCommandInput, GetShardIteratorCommand, GetShardIteratorCommandInput, KinesisClient, ListShardsCommand } from "@aws-sdk/client-kinesis";

(async () => {

  const DATA_STREAM = "device-datastream";
  const SHARD_ID = "shardId-000000000000";

  const client = new KinesisClient({ region: "sa-east-1" });


  // // Add Tags
  // const records: Record<string, string> = {
  //   one: "one",
  //   two: "two",
  //   three: "three",
  // };

  // const params: AddTagsToStreamCommandInput = {
  //   StreamName: DATA_STREAM,
  //   Tags: records
  // };

  // const command = new AddTagsToStreamCommand(params);
  // const data = await client.send(command);


  // // List Shards
  // const paramsList = {
  //   StreamName: "device-datastream"
  // };
  // const commandList = new ListShardsCommand(paramsList);
  // const shardData = await client.send(commandList);

  // console.log(shardData);


  // Get Records

  const paramsShardIterator: GetShardIteratorCommandInput = {
    StreamName: DATA_STREAM,
    ShardId: SHARD_ID,
    ShardIteratorType: "TRIM_HORIZON"
  };
  const commandShardIterator = new GetShardIteratorCommand(paramsShardIterator);

  const shardIteratorData = await client.send(commandShardIterator);
  const paramsGet: GetRecordsCommandInput = {
    ShardIterator: shardIteratorData.ShardIterator,    
  };
  const commandGet = new GetRecordsCommand(paramsGet);
  const response = await client.send(commandGet);

  console.log(response.Records);

})();
