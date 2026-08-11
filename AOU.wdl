version 1.0
task mosdepth {
    input {
        File bam_or_cram_input
        File bam_or_cram_index
        String outputRoot
        File ref
        File ref_fasta_index
        File ref_dict
        Int threads
        Int mem_gb = 8
        Boolean fast_mode = false
        Int additional_disk_size = 20
        Int disk_size = ceil(size(bam_or_cram_input, "GB")) + additional_disk_size
    }

	command {
		/usr/local/bin/mosdepth -n ~{if fast_mode then "-x" else ""} -t ~{threads} --by 1000 --fasta ~{ref} ~{outputRoot} ~{bam_or_cram_input}
	}

	output {
		File coverageBed = "~{outputRoot}.regions.bed.gz"
		File globalDistOutput="~{outputRoot}.mosdepth.global.dist.txt"
		File distOutput="~{outputRoot}.mosdepth.region.dist.txt"
		File summaryOutput="~{outputRoot}.mosdepth.summary.txt"
	}

	runtime {
		docker: "jlanej/mosdepth-docker@sha256:06732e3ab3bdff0fc44a98c69d97d3c601ad4ef6d23c02660a9899188ae5b98d"
		memory: mem_gb + " GB"
		cpu: threads
		disks: "local-disk " + disk_size + " HDD"
	}

	meta {
		author: "jlanej"
	}
}

workflow mosdepthWorkflow {
    input {
        File bam_or_cram_input
        File bam_or_cram_index
        String outputRoot
        File ref
        File ref_fasta_index
        File ref_dict
        Int threads
        Int mem_gb = 8
        Boolean fast_mode = false
    }
	call mosdepth {
		input:
	 bam_or_cram_input=bam_or_cram_input,
	 bam_or_cram_index=bam_or_cram_index,
	 outputRoot=outputRoot,
	 ref=ref,
	 ref_fasta_index=ref_fasta_index,
	 ref_dict=ref_dict,
	 threads=threads,
	 mem_gb=mem_gb,
	 fast_mode=fast_mode
	}
}
