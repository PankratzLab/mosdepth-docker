# Performance notes: running AOU.wdl on All of Us

Practical levers for the mosdepth coverage task, roughly in order of impact.
None of these are applied by default — they change cost/runtime behavior, so
adopt deliberately.

## 1. Preemptible VMs (biggest cost lever)

The task is short and safely re-runnable, which is the ideal preemptible
workload (~60–90% cheaper than on-demand):

```wdl
runtime {
    preemptible: 3
}
```

Cromwell retries a preempted task up to 3 times, then falls back to on-demand.

## 2. Threads for CRAM decoding

The command currently runs `-t 1` on a 1-CPU machine. CRAM decompression is
the bottleneck; mosdepth benefits from up to ~4 threads (little gain beyond).
Shorter tasks also get preempted less.

- command: `mosdepth -n -t 4 ...`
- runtime: `cpu: 4`

## 3. SSD instead of HDD for the working disk

GCP persistent-disk throughput scales with disk size *and* type — a ~40 GB
`HDD` (pd-standard) disk can bottleneck simply localizing a 15–20 GB CRAM.
Disk cost is pennies per task-hour, so SSD usually pays for itself in saved
VM time:

```wdl
disks: "local-disk " + disk_size + " SSD"
```

## 4. Optional: mosdepth fast mode (`-x`)

`-x/--fast-mode` skips internal CIGAR parsing and mate-overlap correction —
substantially faster, and recommended by mosdepth for most binned-coverage
uses. Caveat: binned values shift slightly, so don't mix fast-mode and
non-fast-mode outputs within one dataset.

## 5. Memory: keep it small

mosdepth is memory-light. `mem_gb` of 4–8 is plenty (pair 8 with `cpu: 4`).
The unused `machine_mem_size` input can be deleted.

## 6. At cohort scale

- Docker Hub anonymous pulls are rate-limited. If scattering over thousands
  of samples, mirror the digest-pinned image to a public GCP Artifact
  Registry (or GHCR) repo and point `docker:` there.
- Keep the image pinned by digest (reproducibility, and identical caching
  behavior across the fleet).

## Everything together

```wdl
command {
    /usr/local/bin/mosdepth -n -t 4 --by 1000 --fasta ~{ref} ~{outputRoot} ~{bam_or_cram_input}
}

runtime {
    docker: "jlanej/mosdepth-docker@sha256:06732e3ab3bdff0fc44a98c69d97d3c601ad4ef6d23c02660a9899188ae5b98d"
    memory: mem_gb + "GB"
    cpu: 4
    disks: "local-disk " + disk_size + " SSD"
    preemptible: 3
}
```
