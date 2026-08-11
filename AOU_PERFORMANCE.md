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

`threads` (default 4) is wired to both mosdepth `-t` and the runtime `cpu`,
so the VM size always matches what mosdepth uses. CRAM decompression is the
bottleneck; mosdepth benefits from up to ~4 threads (little gain beyond).
Shorter tasks also get preempted less.

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

## 6. At cohort scale: pull through the AoU GAR remote repository

Docker Hub anonymous pulls are rate-limited per IP, and a large scatter
(thousands of VMs behind shared NAT IPs, each pulling the image once) is the
worst case for it. The Researcher Workbench solves this natively: it fronts
Docker Hub with a Google Artifact Registry **remote repository** (a
pull-through cache in us-central1). The first pull fetches from Docker Hub
and caches inside AoU; every subsequent VM pulls from the cache —
GCP-internal, no Docker Hub limits.

To use it, set the `docker_image` input to the Docker Hub path appended to
the AoU remote-repo prefix. The prefix is exposed in workbench environments
as the `ARTIFACT_REGISTRY_DOCKER_REPO` environment variable; prefer
composing from it (in the notebook that writes your inputs JSON) in case the
underlying path changes:

```python
import os
docker_image = (
    os.environ["ARTIFACT_REGISTRY_DOCKER_REPO"]
    + "/jlanej/mosdepth-docker@sha256:06732e3ab3bdff0fc44a98c69d97d3c601ad4ef6d23c02660a9899188ae5b98d"
)
```

which currently resolves to:

```
us-central1-docker.pkg.dev/all-of-us-rw-prod/aou-rw-gar-remote-repo-docker-prod/jlanej/mosdepth-docker@sha256:06732e3ab3bdff0fc44a98c69d97d3c601ad4ef6d23c02660a9899188ae5b98d
```

Notes:

- The digest is preserved through the proxy — same `@sha256:...` everywhere,
  so reproducibility is unchanged.
- The remote repo is only reachable from inside the Workbench. The default
  `docker_image` (plain Docker Hub) remains right for small runs and for use
  outside AoU.

## Example performance-test inputs

```json
{
    "mosdepthWorkflow.threads": 4,
    "mosdepthWorkflow.fast_mode": true,
    "mosdepthWorkflow.mem_gb": 8
}
```

Compare wall-clock against `"fast_mode": false` (and `threads` 1 vs 4) on a
few representative CRAMs before committing to full-cohort settings. For the
full-cohort scatter, add the `docker_image` override from section 6.
