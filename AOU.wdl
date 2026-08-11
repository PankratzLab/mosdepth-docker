version 1.0
task mosdepth {
    input {
        File bam_or_cram_input
        File bam_or_cram_index
        String outputRoot
        File ref
        File ref_fasta_index
        File ref_dict
        Int mem_gb
        Int addtional_disk_size = 20 
        Int machine_mem_size = 15
   		Int disk_size = ceil(size(bam_or_cram_input, "GB")) + addtional_disk_size

    }

	command {
		/usr/local/bin/mosdepth -n -t 1 --by 1000 --fasta ~{ref} ~{outputRoot} ~{bam_or_cram_input}
	}

	output {
		File coverageBed = "~{outputRoot}.regions.bed.gz"
		File globalDistOutput="~{outputRoot}.mosdepth.global.dist.txt"
		File distOutput="~{outputRoot}.mosdepth.region.dist.txt"
		File summaryOutput="~{outputRoot}.mosdepth.summary.txt"
		

	}

	runtime {
		docker: "jlanej/mosdepth-docker@sha256:4759d71c17268e2a3543a11e40511180d0d7f97e1172e4f7ec1f3c675103693b"
		memory: mem_gb + "GB"
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
        Int mem_gb
    }
	call mosdepth { 
		input:
	 bam_or_cram_input=bam_or_cram_input,
	 bam_or_cram_index=bam_or_cram_index,
	 outputRoot=outputRoot,
	 ref=ref,
	 ref_fasta_index=ref_fasta_index,
	 ref_dict=ref_dict,
	 mem_gb=mem_gb 
	}
}

#		
