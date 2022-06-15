.DEFAULT_GOAL := help

.PHONY: help
help: Makefile
	@printf "\nChoose a command run in $(shell basename ${PWD}):\n"
	@sed -n 's/^##//p' $< | column -t -s ":" |  sed -e 's/^/ /' ; echo

clean:
	@find . -name '.terragrunt-cache' -exec rm -rf {} +

format:
	@terragrunt hclfmt