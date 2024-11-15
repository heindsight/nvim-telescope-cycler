.PHONY: clean coverage coverage-report spec

spec:
	@luarocks --lua-version=5.1 test


coverage-report:
	@luacov
	@cat luacov.report.out


coverage: spec coverage-report


clean:
	@git clean -Xffd
