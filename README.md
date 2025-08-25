# Akash Backup: Restic → S3 & Sia renterd (with SHM option)

A production-friendly way to back up data from Akash workloads to cloud storage using **restic**. Works with:
- **Centralized S3** providers (AWS S3, Cloudflare R2, Backblaze B2 S3, MinIO, etc.)
- **Decentralized** storage via **Sia renterd S3 Gateway**

Two deployment styles:
1. `deploy.s3.yaml` — **Simple**: an app (“producer”) with **persistent storage** and a **backup service** that pulls files via an internal HTTP endpoint exposed by the producer (or the producer pushes to the backup). Works great for S3 or renterd S3.
2. `deploy.shm.yaml` — **Shared Memory (SHM)**: the producer copies files to a shared tmpfs mount (`/dev/shm/outbox`) and the backup service reads from there, then uploads to S3/renterd → aligns with the **40 AKT** requirement to use Akash’s SHM feature.  
   > Note: SHM is **not persistent**; it’s a fast in-RAM handoff. Persistent storage still lives on the producer service. :contentReference[oaicite:1]{index=1}

## Why restic?
- Client-side encryption by default
- Incremental, deduplicated backups
- Native S3 & S3-compatible support (renterd S3 gateway included)

## Akash features used
- **Persistent storage** on producer service (data survives restarts within the lease)  
  _Limitations:_ storage is per service and does **not** survive lease migrations; **shared persistent volumes are not supported** (each service gets its own PV even if you reference the same profile). :contentReference[oaicite:2]{index=2}
- **Shared Memory (SHM)** class `ram` mounted at `/dev/shm` so multiple services can access a fast, ephemeral area for handoff. (Do not mark SHM as persistent.) :contentReference[oaicite:3]{index=3}

---

## Quick start

### 1) Choose your target
- **Centralized S3** (AWS/R2/B2/MinIO): use `deploy.s3.yaml` and set `RESTIC_REPOSITORY=s3:https://<endpoint>/<bucket>`  
- **Sia renterd** (decentralized): run renterd with **S3 Gateway** and set the same `RESTIC_REPOSITORY` to its S3 URL. :contentReference[oaicite:4]{index=4}

### 2) Set secrets (Akash environment variables)
Create a `.env-akash` file locally (values will be injected by Console or akash CLI):

