package main

import (
	"os"
	"testing"

	"github.com/stretchr/testify/require"
)

func keycloakTestConfig() *KeycloakConfig {
	return &KeycloakConfig{
		URL:                "https://keycloak.example.com",
		Realm:              "test",
		ClientID:           "test-client",
		ClientSecretEnvVar: "KEYCLOAK_CLIENT_SECRET",
		UsersGroupFilter:   ".*",
		GroupsFilter:       ".*",
	}
}

func TestNewKeycloakWithMissingCustomRootCA(t *testing.T) {
	cfg := keycloakTestConfig()
	cfg.CustomRootCA = "/no/such/custom-ca.pem"

	_, err := NewKeycloak(cfg, getDevelopmentLogger())
	require.Error(t, err)
	require.Contains(t, err.Error(), "failed to read keycloak custom root CA")
}

func TestNewKeycloakWithInvalidCustomRootCA(t *testing.T) {
	tmpFile, err := os.CreateTemp("", "keycloak-custom-ca-*.pem")
	require.NoError(t, err)
	defer os.Remove(tmpFile.Name())

	_, err = tmpFile.WriteString("not-a-pem")
	require.NoError(t, err)
	require.NoError(t, tmpFile.Close())

	cfg := keycloakTestConfig()
	cfg.CustomRootCA = tmpFile.Name()

	_, err = NewKeycloak(cfg, getDevelopmentLogger())
	require.Error(t, err)
	require.Contains(t, err.Error(), "failed to parse keycloak custom root CA")
}
