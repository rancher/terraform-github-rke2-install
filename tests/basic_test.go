package test

import (
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/stretchr/testify/assert"
)

func TestBasic(t *testing.T) {
	t.Parallel()
	id := os.Getenv("IDENTIFIER")
	if id == "" {
		id = random.UniqueId()
	}
	directory := "basic"
	region := "us-west-1"
	owner := "terraform-ci@suse.com"
	terraformVars := map[string]interface{}{}
	terraformOptions, keyPair := setup(t, directory, region, owner, id, terraformVars)

	sshAgent := ssh.SshAgentWithKeyPair(t, keyPair.KeyPair)
	defer sshAgent.Stop()
	terraformOptions.SshAgent = sshAgent

	defer teardown(t, directory, keyPair)
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	out := terraform.OutputAll(t,terraformOptions)
  t.Logf("out: %v", out)
  outputServer, ok := out["server"].(map[string]interface{})
  assert.True(t, ok, fmt.Sprintf("Wrong data type for 'server', expected map[string], got %T", out["server"]))
  outputImage, ok := out["image"].(map[string]interface{})
  assert.True(t, ok, fmt.Sprintf("Wrong data type for 'image', expected map[string], got %T", out["image"]))
  outputKubeconfig, ok := out["kubeconfig"].(string)
  assert.True(t, ok, fmt.Sprintf("Wrong data type for 'kubeconfig', expected string, got %T", out["kubeconfig"]))

	assert.NotEmpty(t, outputKubeconfig, "The 'kubeconfig' is empty")
	assert.NotEmpty(t, outputServer["public_ip"], "The 'server.public_ip' is empty")
  assert.NotEmpty(t, outputImage["id"], "The 'image.id' is empty")
}
