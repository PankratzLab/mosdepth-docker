# Performance notes: running AOU.wdl on All of Us

Practical levers for the mosdepth coverage task, roughly in order of impact.

## 1. Preemptible VMs (biggest cost lever)

The task is short and safely re-runnable, which is the ideal preemptible
workload (~60–90% cheaper than on-demand). Not applied by default; add:

```wdl
runtime {
    preemptible: 3
}
```

Cromwell retries a preempted task up to 3 times, then falls back to on-demand.

## 2. Threads for CRAM decoding

`threads` is a required workflow input, wired to both mosdepth `-t` and the
runtime `cpu`. CRAM decompression is the bottleneck; mosdepth benefits from
up to ~4 threads (little gain beyond). Shorter tasks also get preempted less.
**Recommended: `"mosdepthWorkflow.threads": 4`.**

## 3. SSD instead of HDD for the working disk

GCP persistent-disk throughput scales with disk size *and* type — a ~40 GB
`HDD` (pd-standard) disk can bottleneck simply localizing a 15–20 GB CRAM.
Disk cost is pennies per task-hour, so SSD usually pays for itself in saved
VM time. Not applied by default; change the runtime line to:

```wdl
disks: "local-disk " + disk_size + " SSD"
```

## 4. mosdepth fast mode (`fast_mode` input, default false)

Setting `"mosdepthWorkflow.fast_mode": true` adds `-x/--fast-mode`, which
skips internal CIGAR parsing and mate-overlap correction — substantially
faster, and recommended by mosdepth for most binned-coverage uses. Being an
input, it can be A/B performance-tested without editing the WDL. Caveat:
binned values shift slightly, so don't mix fast-mode and non-fast-mode
outputs within one dataset.

## 5. Memory

mosdepth is memory-light; `mem_gb` defaults to 8, which pairs well with
`threads = 4`. Rarely a reason to raise it.

## 6. At cohort scale

- Docker Hub anonymous pulls are rate-limited. If scattering over thousands
  of samples, mirror the digest-pinned image to a public GCP Artifact
  Registry (or GHCR) repo and point `docker:` there.
- Keep the image pinned by digest (reproducibility, and identical caching
  behavior across the fleet).

## Example performance-test inputs

```json
{
    "mosdepthWorkflow.threads": 4,
    "mosdepthWorkflow.fast_mode": true,
    "mosdepthWorkflow.mem_gb": 8
}
```

Compare wall-clock against `"fast_mode": false` (and `threads` 1 vs 4) on a
few representative CRAMs before committing to full-cohort settings.
