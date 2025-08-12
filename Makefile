
.PHONY: binary
binary:
	chmod +x scripts/binary.sh
	bash scripts/binary.sh

.ONESHELL:
.PHONY: smoke-test
smoke-test:
	set -ex
	mermaid-ascii --help
	mermaid-ascii -f tests/smoke_test.txt
	set +ex


.ONESHELL:
.PHONY: smoke-test-menu
smoke-test:
	set -ex
	mermaid-ascii --help
	set +ex
