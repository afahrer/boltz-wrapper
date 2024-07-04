PKG_ID := $(shell yq e ".id" manifest.yaml)
PKG_VERSION := $(shell yq e ".version" manifest.yaml)
TS_FILES := $(shell find ./ -name \*.ts)
BOLTZ_SRC := $(shell find ./boltz-web-app)
# delete the target of a rule if it has changed and its recipe exits with a nonzero exit status
.DELETE_ON_ERROR:

all: verify

verify: $(PKG_ID).s9pk
	start-sdk verify s9pk $(PKG_ID).s9pk

install: $(PKG_ID).s9pk
	start-cli package install $(PKG_ID).s9pk

clean:
	rm -rf docker-images
	rm -f $(PKG_ID).s9pk
	rm -f scripts/*.js

clean-manifest:
	@sed -i '' '/^[[:blank:]]*#/d' manifest.yaml
	@echo; echo "Comments successfully removed from manifest.yaml file."; echo


# for rebuilding just the arm image. will include docker-images/x86_64.tar into the s9pk if it exists
arm: docker-images/aarch64.tar scripts/embassy.js
	start-sdk pack

# for rebuilding just the x86 image. will include docker-images/aarch64.tar into the s9pk if it exists
x86: docker-images/x86_64.tar scripts/embassy.js
	start-sdk pack

$(PKG_ID).s9pk: manifest.yaml instructions.md icon.png boltz-web-app/LICENSE scripts/embassy.js docker-images/aarch64.tar docker-images/x86_64.tar
	start-sdk pack

docker-images/aarch64.tar: Dockerfile docker_entrypoint.sh $(BOLTZ_SRC)
	mkdir -p docker-images
	docker buildx build --tag start9/$(PKG_ID)/main:$(PKG_VERSION) --progress=plain --platform=linux/arm64 -o type=docker,dest=docker-images/aarch64.tar .

docker-images/x86_64.tar: Dockerfile docker_entrypoint.sh $(BOLTZ_SRC)
	mkdir -p docker-images
	docker buildx build --tag start9/$(PKG_ID)/main:$(PKG_VERSION) --progress=plain --platform=linux/amd64 -o type=docker,dest=docker-images/x86_64.tar .

scripts/embassy.js: $(TS_FILES)
	deno bundle scripts/embassy.ts scripts/embassy.js