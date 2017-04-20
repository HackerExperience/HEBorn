# Works with GNU Make and BSD Make
.PHONY: default prepare build build-quick
default: dev

nodebin := node_modules/.bin
main := src/Main.elm
port := 8000
server := $(nodebin)/webpack-dev-server --hot --inline --port $(port)

################################################################################
# Install
################################################################################

install:
	npm install
	elm-package install -y

################################################################################
# Compile
################################################################################

compile:
	elm-make $(main)

compile-clean:
	$(MAKE) compile && rm -f index.html

################################################################################
# Build
################################################################################

prepare:
	rm -rf build/ && \
	mkdir -p build/css && \
	mkdir -p build/js && \
	mkdir -p build/vendor && \
	cp -r static/css/* build/css && \
	cp -r static/js/* build/js && \
	cp -r static/vendor/* build/vendor

build: prepare
	cat static/index.html > build/index.html

build-quick: prepare
	sed '/cssrefresh/d' static/index.html > build/index.html

################################################################################
# Dev
################################################################################

# For dev, first we compile the whole app, and only then we run npm.
# The rationale is simple: `npm start` will compile with debug and warn
# flags, which makes the whole step much slower. Compiling first without
# them ensures the "bulk" of the job is done quickly, and only then we
# add the debug flags. There is little difference when only a couple
# of changes are made, but it makes everything much faster when the
# whole app, with dependencies, need to be built. This usually happens
# when adding dependencies, changing branches etc.
dev: compile-clean build
	npm start

# Do not use annoying css reloader
dev-quick: compile-clean build-quick
	npm start

################################################################################
# Tools
################################################################################

server:
	$(server) & ls

################################################################################
# Test
################################################################################

test:
	elm-test

test-quick:
	sed 's/10/1/g' tests/Config.elm > tests/Config.elm.tmp && \
	mv tests/Config.elm.tmp tests/Config.elm
	$(MAKE) test
	git checkout tests/Config.elm

test-long:
	sed 's/10/100/g' tests/Config.elm > tests/Config.elm.tmp && \
	mv tests/Config.elm.tmp tests/Config.elm
	$(MAKE) test
	git checkout tests/Config.elm

################################################################################
# Clean
################################################################################

clean:
	rm -rf build/* && \
	rm -f *.html && \
	git clean -id && \
	git checkout tests/Config.elm
