gen-ai-context:
	find . \
		-path "./.terraform" -prune -o \
		-name "terraform.tfstate" -prune -o \
		-name "terraform.tfstate.backup" -prune -o \
		-name "makefile" -prune -o \
		-path "./.context" -prune -o \
		-name ".terraform.lock.hcl" -prune -o \
		-type f -exec sh -c ' \
			echo "=== File: $$1 ==="; \
			cat "$$1"; \
		' _ {} \; > .context 2>&1

