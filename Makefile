travis-pages :
	go get github.com/gopherjs/gopherjs
	go get ./...
	go test ./...
	cd web && gopherjs build -m -o curl2httpie.js && rm main.go .gitignore

generateOptions :
	go run cmd/generateOptions/main.go -path="$(path)"
	go-bindata -ignore .gitignore -pkg curl -o ./curl/bindata.go data/

initGithooks:
	git config core.hooksPath .githooks

NAME := curl2httpie
PACKAGE_NAME := github.com/dcb9/curl2httpie
VERSION := `git describe --dirty`
COMMIT := `git rev-parse HEAD`

PLATFORM := linux
BUILD_DIR := build
VAR_SETTING := -X $(PACKAGE_NAME)/constant.Version=$(VERSION) -X $(PACKAGE_NAME)/constant.Commit=$(COMMIT)
GOBUILD = go build -ldflags="-s -w $(VAR_SETTING)" -trimpath -o $(BUILD_DIR)

release: clean darwin-amd64.zip linux-amd64.zip freebsd-amd64.zip windows-amd64.zip

clean:
	rm -rf $(BUILD_DIR)
	rm -f curl2httpie
	rm -f curl2httpie-*.zip

test:
	go test ./...

curl2httpie:
	mkdir -p $(BUILD_DIR)
	$(GOBUILD)

%.zip: %
	@zip -du $(NAME)-$@ -j $(BUILD_DIR)/$</*
	@echo "<<< ---- $(NAME)-$@"

darwin-amd64:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=amd64 GOOS=darwin $(GOBUILD)/$@

linux-amd64:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=amd64 GOOS=linux $(GOBUILD)/$@

freebsd-amd64:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=amd64 GOOS=freebsd $(GOBUILD)/$@

windows-amd64:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=amd64 GOOS=windows $(GOBUILD)/$@
