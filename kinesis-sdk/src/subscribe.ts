import {
  KinesisClient,
  RegisterStreamConsumerCommand,
  RegisterStreamConsumerCommandInput,
  RegisterStreamConsumerCommandOutput,
  SubscribeToShardCommand,
  SubscribeToShardCommandInput,
  StartingPosition,
  ShardIteratorType,
  DeregisterStreamConsumerCommand,
  DeregisterStreamConsumerCommandInput,
  DescribeStreamConsumerCommand,
  DescribeStreamConsumerCommandInput
} from "@aws-sdk/client-kinesis";

(async () => {

  const DATA_STREAM = "device-stream";
  const SHARD_ID = "shardId-000000000000";
  const client = new KinesisClient({ region: "sa-east-1" });

  const register = async (): Promise<RegisterStreamConsumerCommandOutput> => {
    const input: RegisterStreamConsumerCommandInput = {
      ConsumerName: "typescript-consumer",
      StreamARN: "arn:aws:kinesis:sa-east-1:130107406234:stream/device-stream"
    }
    const command = new RegisterStreamConsumerCommand(input);
    return await client.send(command);
  }

  const getStatus = async (consumerResponse: RegisterStreamConsumerCommandOutput): Promise<string | undefined> => {
    const input: DescribeStreamConsumerCommandInput = {
      ConsumerARN: consumerResponse.Consumer?.ConsumerARN
    }
    const command = new DescribeStreamConsumerCommand(input);
    const response = await client.send(command);
    return response.ConsumerDescription?.ConsumerStatus;
  }

  const subscribe = async (consumerResponse: RegisterStreamConsumerCommandOutput) => {
    const startingPosition: StartingPosition = {
      Type: ShardIteratorType.LATEST
    }
    const input: SubscribeToShardCommandInput = {
      ConsumerARN: consumerResponse.Consumer?.ConsumerARN,
      ShardId: SHARD_ID,
      StartingPosition: startingPosition
    }
    const command = new SubscribeToShardCommand(input);
    await client.send(command);
  }

  let consumerResponse = undefined;

  try {
    console.log("Waiting for the consumer status to be ACTIVE");
    consumerResponse = await register();
    let status: string | undefined = "";
    while (status !== "ACTIVE") {
      status = await getStatus(consumerResponse);
    }
    await subscribe(consumerResponse);

    console.log("Subscribed")

  } finally {
    console.log("De-registering consumer...")
    const input: DeregisterStreamConsumerCommandInput = {
      ConsumerARN: consumerResponse?.Consumer?.ConsumerARN,
    }
    const command = new DeregisterStreamConsumerCommand(input);
    const response = await client.send(command);
    console.log(response);
  }

})();
