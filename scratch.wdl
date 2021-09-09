 Float outputSize = size(bam_or_cram_input, "GB")
    	Float ref_size = size(referenceGenome, "GB") 
   		Int disk_size = ceil(size(bam_or_cram_input, "GB") + outputSize + ref_size) + addtional_disk_size