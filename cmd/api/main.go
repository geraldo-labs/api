package main

import (
	"fmt"
	"github.com/spf13/cobra"
	"log"
)

var cmd = &cobra.Command{
	Use:   "api",
	Short: "A API runner in declarative way.",
	Long:  "A API runner in declarative way.",
}

func main() {
	cmd.PersistentFlags().Int("port", 8080, "Port of the API, default 8080")
	cmd.PersistentFlags().Bool("debug", false, "Define the running mode of the application, default false")
	if err := cmd.Execute(); err != nil {
		log.Printf("Error running application: %v", fmt.Errorf("%w", err))
	}
}
