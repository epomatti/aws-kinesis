# AWS Kinesis

AWS Kinesis services in action.

<img src=".diagram/kinesis.drawio.png" width=700 />

## Running

Create the infrastructure:

```sh
terraform init
terraform apply -auto-approve
```

Install the dependencies:

```sh
yarn install
```

Run the taks:

```sh
yarn run get
yarn run put
yarn run sub
```

### Kinesis Client Library (KCL)

An example of KCL is also available.

```sh
mvn install
mvn compile
```

```sh
mvn exec:java -pl consumer
mvn exec:java -pl producer
```