import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordRequest;
import software.amazon.kinesis.common.KinesisClientUtil;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.RandomUtils;

public class Producer {

  KinesisAsyncClient kinesisClient;
  private java.util.concurrent.ScheduledFuture<?> producerFuture;

  public void produce() {
    Region region = Region.of("sa-east-1");
    kinesisClient = KinesisClientUtil
        .createKinesisAsyncClient(KinesisAsyncClient.builder().region(region));

    ScheduledExecutorService producerExecutor = Executors.newSingleThreadScheduledExecutor();
    producerFuture = producerExecutor.scheduleAtFixedRate(this::publishRecord, 10, 1,
        TimeUnit.MILLISECONDS);

    // producerFuture.cancel(true);
    // producerExecutor.shutdownNow();

    // /**
    //  * Stops consuming data. Finishes processing the current batch of data already
    //  * received from Kinesis
    //  * before shutting down.
    //  */
    // Future<Boolean> gracefulShutdownFuture = scheduler.startGracefulShutdown();
    // log.info("Waiting up to 20 seconds for shutdown to complete.");
    // try {
    //   gracefulShutdownFuture.get(20, TimeUnit.SECONDS);
    // } catch (InterruptedException e) {
    //   log.info("Interrupted while waiting for graceful shutdown. Continuing.");
    // } catch (ExecutionException e) {
    //   log.error("Exception while executing graceful shutdown.", e);
    // } catch (TimeoutException e) {
    //   log.error("Timeout while waiting for shutdown.  Scheduler may not have exited.");
    // }
    // log.info("Completed, shutting down now.");

  }

  private void publishRecord() {
    PutRecordRequest request = PutRecordRequest.builder()
        .partitionKey(RandomStringUtils.randomAlphabetic(5, 20))
        .streamName("device-datastream")
        .data(SdkBytes.fromByteArray(RandomUtils.nextBytes(10)))
        .build();
    try {
      kinesisClient.putRecord(request).get();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

}
