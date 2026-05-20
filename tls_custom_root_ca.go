package main

import (
	"crypto/x509"
	"os"

	"github.com/pkg/errors"
)

func loadCustomRootCAs(customRootCAPath string, sourceName string) (*x509.CertPool, error) {
	customRootCA, err := os.ReadFile(customRootCAPath)
	if err != nil {
		return nil, errors.Wrapf(err, "failed to read %s custom root CA from %s", sourceName, customRootCAPath)
	}

	rootCAs, err := x509.SystemCertPool()
	if err != nil {
		return nil, errors.Wrap(err, "failed to load system certificate pool")
	}
	if rootCAs == nil {
		rootCAs = x509.NewCertPool()
	}
	if ok := rootCAs.AppendCertsFromPEM(customRootCA); !ok {
		return nil, errors.Errorf("failed to parse %s custom root CA from %s", sourceName, customRootCAPath)
	}

	return rootCAs, nil
}
