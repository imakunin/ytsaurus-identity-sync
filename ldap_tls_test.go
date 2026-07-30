package main

import (
	"os"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestMakeLDAPDialOptionsWithMissingCustomRootCA(t *testing.T) {
	_, err := makeLDAPDialOptions("/no/such/custom-ca.pem")
	require.Error(t, err)
	require.Contains(t, err.Error(), "failed to read ldap custom root CA")
}

func TestMakeLDAPDialOptionsWithInvalidCustomRootCA(t *testing.T) {
	tmpFile, err := os.CreateTemp("", "ldap-custom-ca-*.pem")
	require.NoError(t, err)
	defer os.Remove(tmpFile.Name())

	_, err = tmpFile.WriteString("not-a-pem")
	require.NoError(t, err)
	require.NoError(t, tmpFile.Close())

	_, err = makeLDAPDialOptions(tmpFile.Name())
	require.Error(t, err)
	require.Contains(t, err.Error(), "failed to parse ldap custom root CA")
}
