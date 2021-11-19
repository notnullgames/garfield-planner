NAME=garfield

#TODO: build switch with lovepotion

.PHONY: help run clean setup

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

setup: ## Install dev-dependencies
	pip3 install makelove 

run: ## Run garfield, locally
	love src

clean: ## Delete all output files
	rm -rf build

web: build/web                      ## Build for the web
linux: build/appimage               ## Build for Linux
mac: build/macos/garfield-macos.zip ## Build for MacOS
win: build/win64/garfield-win64.zip ## Build for Windows
deploy: build/web                   ## Deploy to https://garfield-organizer.surge.sh
	npx surge build/web garfield-organizer.surge.sh

build/web:
	cd src && makelove lovejs --config ../makelove.toml
	cd build/lovejs && unzip garfield-lovejs.zip && mv garfield ../web && cd .. && rm -rf lovejs && cp ../template.html web/index.html 

build/appimage:
	cd src && makelove appimage --config ../makelove.toml

build/macos/garfield-macos.zip:
	cd src && makelove macos --config ../makelove.toml

build/win32/garfield-win32.zip:
	cd src && makelove win32 --config ../makelove.toml

build/win64/garfield-win64.zip:
	cd src && makelove win64 --config ../makelove.toml