#!/usr/bin/env bash

chmod +x ./helm_regen.sh
viper_charts_root=gitlab.sz.sensetime.com/viper/charts
code_root=gitlab.sz.sensetime.com/viper/charts/kafka

docker run -it --rm \
    -u `id --user` \
    -v $PWD/..:/go/src/${viper_charts_root} \
	-e PROTOC_INSTALL=/go \
	-w /go/src/${code_root} \
	registry.sensetime.com/viper-ce/helm-playground:dc84f69 ./helm_regen.sh
