.PHONY: clean coverage coverage-report format lint spec

lint:
	luacheck lua/ spec/
	selene lua/ spec/
	stylua --check lua/ spec/


format:
	@stylua lua/ spec/


spec:
	@luarocks --lua-version=5.1 test


coverage-report:
	@luacov
	@cat luacov.report.out


coverage: spec coverage-report


clean:
	@git clean -Xffd
