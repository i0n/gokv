package version_test

import (
	"testing"

	version "github.com/i0n/gokv/pkg/version"
	"github.com/stretchr/testify/assert"
)

func TestGetVersion(t *testing.T) {
	version.Map["version"] = "1-dev"
	assert.Equal(t, "1-dev", version.GetVersion())
}

func TestGetRevision(t *testing.T) {
	version.Map["revision"] = "hash"
	assert.Equal(t, "hash", version.GetRevision())
}

func TestGetBranch(t *testing.T) {
	version.Map["branch"] = "master"
	assert.Equal(t, "master", version.GetBranch())
}

func TestGetBuildUser(t *testing.T) {
	version.Map["buildUser"] = "Ian"
	assert.Equal(t, "Ian", version.GetBuildUser())
}

func TestGetBuildDate(t *testing.T) {
	version.Map["buildDate"] = "Monday"
	assert.Equal(t, "Monday", version.GetBuildDate())
}

func TestGetGoVersion(t *testing.T) {
	version.Map["goVersion"] = "1.9"
	assert.Equal(t, "1.9", version.GetGoVersion())
}
