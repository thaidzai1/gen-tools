#!/bin/bash
echo "Install dependencies ..."
go get -u golang.org/x/tools/cmd/goimports
go get -u github.com/golang/dep/cmd/dep
go get -u github.com/golang/glog
go get -u github.com/ghodss/yaml
go get -u go.uber.org/zap
dep ensure -v