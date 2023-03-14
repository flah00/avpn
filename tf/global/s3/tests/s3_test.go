package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestS3Example(t *testing.T) {
	opts := &terraform.Options{
		TerraformDir: "../examples/test",
	}

	// guarantee infra is cleaned up...
	defer terraform.Destroy(t, opts)

	terraform.InitAndApply(t, opts)

	bucket := terraform.OutputRequired(t, opts, "s3_bucket_arn")
	assert.Equal(t, bucket, "arn:aws:s3:::a50-avpn-test")

	key := terraform.OutputRequired(t, opts, "s3_bucket_key")
	assert.Equal(t, key, "test/s3/terraform.tfstate")

	table := terraform.OutputRequired(t, opts, "dynamodb_table_name")
	assert.Equal(t, table, "avpn-test")
}
