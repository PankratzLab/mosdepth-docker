#!/bin/bash/home/pankrat2/public/bin/ref/GRCh38_full_analysis_set_plus_decoy_hla.fa

rsync -avzP msi:/home/pankrat2/public/bin/ref/GRCh38_full_analysis_set_plus_decoy_hla.* /Volumes/Beta2/resources/
[![Docker Repository on Quay](https://quay.io/repository/jlanej/mosdepth-docker/status "Docker Repository on Quay")](https://quay.io/repository/jlanej/mosdepth-docker)
docker build -t quay.io/jlanej/mosdepth-docker:v0.3.2 .


docker build -t mosdepth-docker .


cd /Volumes/Beta2/resources/1000G/

dockstore tool launch --local-entry /Users/Kitty/git/mosdepth-docker/Dockstore.wdl --json /Users/Kitty/git/mosdepth-docker/test.input.json

		docker: "quay.io/jlanej/mosdepth-docker:v0.3.2"
