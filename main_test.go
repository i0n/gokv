package main

import (
	"github.com/stretchr/testify/assert"
	"syscall"
	"testing"
)

func TestENV(t *testing.T) {
	t.Parallel()
	env, _ := syscall.Getenv("GOKV_ENVIRONMENT")
	assert.Equal(t, "", env)
}
