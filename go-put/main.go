package main

import (
	"context"
	"main/utils"
	"os"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/firehose"
	"github.com/aws/aws-sdk-go-v2/service/firehose/types"
	"github.com/joho/godotenv"
)

func init() {
	err := godotenv.Load()
	utils.Check(err)
}

func main() {
	stream := os.Getenv("DELIVERY_STREAM_NAME")

	cfg, err := config.LoadDefaultConfig(context.TODO())
	utils.Check(err)

	client := firehose.NewFromConfig(cfg)

	dat, err := os.ReadFile("sample.json")
	utils.Check(err)

	input := &firehose.PutRecordInput{
		DeliveryStreamName: &stream,
		Record:             &types.Record{Data: dat},
	}

	output, err := client.PutRecord(context.TODO(), input)
	utils.Check(err)

	println(output.RecordId)

}
