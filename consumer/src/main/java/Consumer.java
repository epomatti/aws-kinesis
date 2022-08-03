import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.UUID;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.cloudwatch.CloudWatchAsyncClient;
import software.amazon.awssdk.services.dynamodb.DynamoDbAsyncClient;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.kinesis.common.ConfigsBuilder;
import software.amazon.kinesis.common.KinesisClientUtil;
import software.amazon.kinesis.coordinator.Scheduler;
import software.amazon.kinesis.lifecycle.events.InitializationInput;
import software.amazon.kinesis.lifecycle.events.LeaseLostInput;
import software.amazon.kinesis.lifecycle.events.ProcessRecordsInput;
import software.amazon.kinesis.lifecycle.events.ShardEndedInput;
import software.amazon.kinesis.lifecycle.events.ShutdownRequestedInput;
import software.amazon.kinesis.processor.ShardRecordProcessor;
import software.amazon.kinesis.processor.ShardRecordProcessorFactory;
import software.amazon.kinesis.retrieval.polling.PollingConfig;
import software.amazon.kinesis.exceptions.InvalidStateException;
import software.amazon.kinesis.exceptions.ShutdownException;

public class Consumer {

  public void consume() {
    Region region = Region.of("sa-east-1");
    KinesisAsyncClient kinesisClient = KinesisClientUtil
        .createKinesisAsyncClient(KinesisAsyncClient.builder().region(region));
    DynamoDbAsyncClient dynamoClient = DynamoDbAsyncClient.builder().region(region).build();
    CloudWatchAsyncClient cloudWatchClient = CloudWatchAsyncClient.builder().region(region).build();

    ConfigsBuilder configsBuilder = new ConfigsBuilder("device-datastream", "my-app", kinesisClient, dynamoClient,
        cloudWatchClient, UUID.randomUUID().toString(), new SampleRecordProcessorFactory());

    Scheduler scheduler = new Scheduler(
        configsBuilder.checkpointConfig(),
        configsBuilder.coordinatorConfig(),
        configsBuilder.leaseManagementConfig(),
        configsBuilder.lifecycleConfig(),
        configsBuilder.metricsConfig(),
        configsBuilder.processorConfig(),
        configsBuilder.retrievalConfig()
            .retrievalSpecificConfig(new PollingConfig("device-datastream", kinesisClient)));

    Thread schedulerThread = new Thread(scheduler);
    schedulerThread.setDaemon(true);
    schedulerThread.start();
    System.out.println("Started consuming...");
  }

  private static class SampleRecordProcessorFactory implements ShardRecordProcessorFactory {
    public ShardRecordProcessor shardRecordProcessor() {
      return new SampleRecordProcessor();
    }
  }

  private static class SampleRecordProcessor implements ShardRecordProcessor {

    private String shardId;

    public void initialize(InitializationInput initializationInput) {
      shardId = initializationInput.shardId();
      System.out.println(shardId);
    }

    public void processRecords(ProcessRecordsInput processRecordsInput) {
      System.out.println(String.format("Records size: %s", processRecordsInput.records().size()));

      processRecordsInput.records()
          .forEach(r -> System.out
              .println(String.format("Processing record pk: %s -- Seq: %s", r.partitionKey(), r.sequenceNumber())));

      /**
       * Allows termination of app by pressing Enter.
       */
      System.out.println("Press enter to shutdown");
      BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
      try {
        reader.readLine();
      } catch (IOException ioex) {
        ioex.printStackTrace();
      }


    }

    public void leaseLost(LeaseLostInput leaseLostInput) {
      System.out.println("Lease lost");
    }

    public void shardEnded(ShardEndedInput shardEndedInput) {
      try {
        System.out.println("Reached shard end checkpointing.");
        shardEndedInput.checkpointer().checkpoint();
      } catch (ShutdownException | InvalidStateException e) {
        System.err.println("Exception while checkpointing at shard end. Giving up.");
        e.printStackTrace();
      }
    }

    public void shutdownRequested(ShutdownRequestedInput shutdownRequestedInput) {
      try {
        System.out.println("Scheduler is shutting down, checkpointing.");
        shutdownRequestedInput.checkpointer().checkpoint();
      } catch (ShutdownException | InvalidStateException e) {
        System.err.println("Exception while checkpointing at shard end. Giving up.");
        e.printStackTrace();
      }
    }
  }

}
