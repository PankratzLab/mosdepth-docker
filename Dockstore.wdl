version 1.0
task mosdepth {
    input {
        File bam_or_cram_input
        String outputRoot
        File referenceGenome
        Int mem_gb
    }

	command {	
		/usr/local/bin/mosdepth -n -t 1 --by 1000 --fasta ${referenceGenome} ${outputRoot} ${bam_or_cram_input}
	}

	output {
		File coverageBed = "~{outputRoot}.bed.gz"
	}

	runtime {
		docker: "quay.io/jlanej/mosdepth-docker:v0.3.2"
		memory: mem_gb + "GB"	}

	meta {
		author: "jlanej"
	}
}

workflow mosdepthWorkflow {
    input {
        File bam_or_cram_input
        File bam_or_cram_index
        String outputRoot
        File referenceGenome
        Int mem_gb
    }
	call mosdepth { input: bam_or_cram_input=bam_or_cram_input,outputRoot=outputRoot,referenceGenome=referenceGenome, mem_gb=mem_gb }
}

