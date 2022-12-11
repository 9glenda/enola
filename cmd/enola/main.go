package main

import (
	"errors"
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "enola {username}",
	Short: "A command-line tool to find username on websites",
	Args: func(_ *cobra.Command, args []string) error {
		if len(args) < 1 {
			return errors.New("can't run without argument, give me a username")
		}
		return nil
	},
	Run: func(cmd *cobra.Command, args []string) {
		username := args[0]
		siteFlag := cmd.Flag("site")
		findAndShowResult(username, siteFlag.Value.String())
	},
}

func main() {
	if err := Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func Execute() error {
	return rootCmd.Execute()
}

func init() {
	rootCmd.Flags().StringP("site", "s", "", "to only search an specific site")
}
