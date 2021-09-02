version 1.0
task mosdepth {
    input {
        File bam_or_cram_input
        String outputRoot
        File referenceGenome
        Int mem_gb
    }

	command {	
		bash ./mosdepth -n -t 1 --by 1000 --fasta ${referenceGenome} ${outputRoot} ${bam_or_cram_input}
	}

	output {
		File coverageBed = "~{outputRoot}.bed.gz"
	}

	runtime {
		docker: "quay.io/jlanej/mosdepth-docker:sha256:e0aacadac78b0352fd31454e66c3c69974b51d318d403ea1b84db7d854e8dcb4"
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

