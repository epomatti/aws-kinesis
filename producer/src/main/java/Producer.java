import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

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
        TimeUnit.SECONDS);

    System.out.println("Producing...");
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

    System.out.println("Shutting down");
    producerFuture.cancel(true);
    producerExecutor.shutdownNow();

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
