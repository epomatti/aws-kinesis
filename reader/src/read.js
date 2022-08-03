const { KinesisClient, AddTagsToStreamCommand, AddTagsToStreamCommandInput } = require("@aws-sdk/client-kinesis");

const client = new KinesisClient({ region: "sa-east-1" });

const params = {
  /** input parameters */
};
const command = new AddTagsToStreamCommand(params);

client.send(command).then(
  (data) => {
    console.log(data)
  },
  (error) => {
    console.error(error)
  }
);