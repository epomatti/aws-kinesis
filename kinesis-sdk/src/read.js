const { KinesisClient, AddTagsToStreamCommand, ListShardsCommand, GetRecordsCommand, GetShardIteratorCommand } = require("@aws-sdk/client-kinesis");

const client = new KinesisClient({ region: "sa-east-1" });


// const params = {
//   StreamName: "device-datastream",
//   Tags: ['some', 'tags', 'go', 'here']
// };
// const command = new AddTagsToStreamCommand(params);

// client.send(command).then(
//   (data) => {
//     console.log(data)
//   },
//   (error) => {
//     console.error(error)
//   }
// );

// const paramsList = {
//   StreamName: "device-datastream"
// };
// const commandList = new ListShardsCommand(paramsList);
// client.send(commandList).then(
//   (data) => {
//     console.log(data)
//   },
//   (error) => {
//     console.error(error)
//   }
// );


const paramsShardIterator = {
  StreamName: "device-datastream",
  ShardId: "shardId-000000000000",
  ShardIteratorType: "LATEST"
};
const commandShardIterator = new GetShardIteratorCommand(paramsShardIterator);

client.send(commandShardIterator).then(
  (data) => {
    console.log(data)
    const paramsGet = {
      ShardIterator: data.ShardIterator,
      // Limit: 1
    };
    const commandGet = new GetRecordsCommand(paramsGet);
    client.send(commandGet).then(
      (data) => {
        console.log(data)
      },
      (error) => {
        console.error(error)
      }
    );
  },
  (error) => {
    console.error(error)
  }
);


