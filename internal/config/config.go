package config

import (
	"log"

	"github.com/kelseyhightower/envconfig"
)

// Settings Application settings
type Settings struct {
	Debug bool `envconfig:"DEBUG" default:"false"`
}

// Conf global var for app configuration
var Conf = &Settings{
	Debug: false,
}

// init populates the Conf variable once
func init() {
	if err := envconfig.Process("", Conf); err != nil {
		log.Fatal(err)
	}
}
