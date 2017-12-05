.PHONY: default setup prepare build build-css release
default: dev

# Default settings
nodebin := node_modules/.bin
main := src/Main.elm
port := 8000

# Automatic settings
UNAME := $(shell uname)
PATH := $(PATH):$(nodebin)
JS_PACKAGE_MNGR := $(shell which yarn || which npm)

################################################################################
# Setup
################################################################################

# Prepare all dependencies
setup:
	git submodule init
	git submodule update
	$(JS_PACKAGE_MNGR) install
	elm-package install -y
	chmod +x node_modules/.bin/* stats/*.sh

################################################################################
# Compile
################################################################################

list_instances = ps ax | grep -E "(elm\-make|webpack\-dev\-server)" | grep -v grep

# Compile-once
compile:
  ifneq ($(shell $(list_instances)),)
	$(error Probably already building)
  endif
	(elm-make $(main) && rm -f index.html && ./stats/succeedBuild.sh) || \
		(./stats/increaseFailedBuilds.sh && false)

# Keep compiling
compile-loop:
	-while :; do $(MAKE) compile; sleep 2; done

################################################################################
# Build
################################################################################

# Clean build enviroment
prepare:
	rm -rf build/ && \
	mkdir -p build/

# Update index.html and compile css
build: prepare
	cat static/index.html | touch build/index.html
	elm-css src/Core/Stylesheets.elm -o static/css

#  Add CSS hot-reloader
build-css: prepare
	awk '/\<\/body/ \
	  {print \
	    "\<script type\=\"text\/javascript\" src\=\"vendor\/cssrefresh\.js\"\> \
	    \<\/script\> \
	  "}1' \
	  static/index.html > build/index.html
	elm-css src/Core/Stylesheets.elm -o static/css

# Creates release.tar.gz
release: build
	webpack
	tar -zcf release.tar.gz build/ && \
	mv release.tar.gz build/

################################################################################
# Dev
################################################################################

# For dev, first we compile the whole app, and only then we watch.
dev: compile build watch

# Add annoying css hot reloader. Useful when editing styles.
dev-css: compile build-css watch

# Starts webpack server with inline & hot-reload
watch:
  ifneq ($(shell $(list_instances)),)
	$(error Probably already running)
  endif
	webpack-dev-server \
		--progress \
		--cache false \
		--port $(port)

################################################################################
# Tools
################################################################################

# Starts webpack server without inline nor hot-reload
host:
	webpack-dev-server \
		--progress \
		--cache false \
		--inline false \
		--hot false \
		--port $(port)

lint:
	elm-format --validate src/

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

test-loop:
	- while :; do $(MAKE) test; sleep 2; done

################################################################################
# Clean
################################################################################

clean:
	rm -rf build/* && \
	rm -f *.html release.tar.gz && \
	git clean -id && \
	git checkout tests/Config.elm
