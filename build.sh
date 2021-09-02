#!/bin/bash/home/pankrat2/public/bin/ref/GRCh38_full_analysis_set_plus_decoy_hla.fa

rsync -avzP msi:/home/pankrat2/public/bin/ref/GRCh38_full_analysis_set_plus_decoy_hla.* /Volumes/Beta2/resources/
[![Docker Repository on Quay](https://quay.io/repository/jlanej/mosdepth-docker/status "Docker Repository on Quay")](https://quay.io/repository/jlanej/mosdepth-docker)
docker build -t quay.io/jlanej/mosdepth-docker:v0.3.2 .


docker build -t mosdepth-docker .


cd /Volumes/Beta2/resources/1000G/

dockstore tool launch --local-entry /Users/Kitty/git/mosdepth-docker/Dockstore.wdl --json /Users/Kitty/git/mosdepth-docker/test.input.json

		docker: "quay.io/jlanej/mosdepth-docker:v0.3.2"


wget "https://github.com/brentp/mosdepth/releases/download/v0.3.2/mosdepth"


cd ~/tmp
cp /home/pankrat2/public/bin/ref/GRCh38_full_analysis_set_plus_decoy_hla.fa ./
mosdepth -n -t 1 --by 1000 --fasta GRCh38_full_analysis_set_plus_decoy_hla.fa NA12878.chrom20.ILLUMINA.bwa.CEU.low_coverage.20121211 NA12878.chrom20.ILLUMINA.bwa.CEU.low_coverage.20121211.bam




docker run -v /Volumes/Beta2/resources/:/Volumes/Beta2/resources/ -v /Volumes/Beta2/resources/1000G/:/Volumes/Beta2/resources/1000G/ mosdepth-docker -n -t 1 --by 1000 --fasta /Volumes/Beta2/resources/GRCh38_full_analysis_set_plus_decoy_hla.fa /Volumes/Beta2/resources/1000G/NA12878.chrom20.ILLUMINA.bwa.CEU.low_coverage.20121211 /Volumes/Beta2/resources/1000G/NA12878.chrom20.ILLUMINA.bwa.CEU.low_coverage.20121211.bam