# AeroBeat Tool Settings

**Date:** 2026-05-15  
**Status:** Draft  
**Agent:** Cookie 🍪

---

## Goal

Implement the first reusable Lego piece for the environment-quality system: a performance recommendation singleton in `/src/` plus a repo-local `.testbed/` diagnostic scene that measures the current device after scene load and emits recommendation events.

---

## Overview

This slice is intentionally narrow. We are not integrating with `assembly-community` yet, and we are not building the environment loader or camera gesture repo in this pass. The purpose of this first slice is to establish a trustworthy contract for device/performance recommendation logic inside `aerobeat-tool-settings`, then prove that contract in a visible `.testbed/` scene.

The singleton should live in `/src/` at the repo root and remain the reusable runtime-facing surface. The `.testbed/` project should act as a truth surface for development: it should load, start sampling after the scene is active, expose the raw signals and computed recommendation, and log emitted events so the recommendation policy can be tuned before any downstream consumer depends on it.

For this first slice, the recommendation logic should follow the agreed two-phase model but with post-load truth as the real decision-maker: gather static device/context signals, then run live performance confirmation after the scene is loaded. The main value is not “picking the perfect tier forever” yet — it is creating the public API, event payloads, and debug/test harness that future consumers can trust.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Repo owning this first implementation slice | `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings` |
| `REF-02` | Higher-level fallback roadmap and contracts | `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/.plans/2026-05-15-default-environment-fallback-ladder.md` |
| `REF-03` | Current public runtime entrypoint pattern | `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings/src/AeroToolManager.gd` |
| `REF-04` | Current hidden Godot testbed for this repo | `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings/.testbed/` |

---

## Tasks

### Task 1: Inspect current repo structure and lock the first-slice contract shape

**Bead ID:** `Pending`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In repo `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings`, claim the assigned bead and inspect the current runtime/testbed structure. Confirm how `src/AeroToolManager.gd` should remain the public-facing entrypoint, what supporting scripts should be added under `/src/`, what `.testbed/` folders/scenes/scripts/tests already exist, and lock the precise first-slice public contract for the performance recommendation singleton and its emitted events.

**Folders Created/Deleted/Modified:**
- Planning/docs only expected

**Files Created/Deleted/Modified:**
- Contract notes only

**Status:** ⏳ Pending

**Results:** Pending execution.

---

### Task 2: Implement the performance recommendation singleton in `/src/`

**Bead ID:** `Pending`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In repo `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings`, claim the assigned bead and implement the first-slice performance recommendation singleton in `/src/`. Keep `src/AeroToolManager.gd` as the public entrypoint, add the supporting runtime script(s) needed for static signal capture plus post-load live sampling, define the recommendation/event payloads, and keep the scope limited to the agreed Lego-piece contract rather than app integration.

**Folders Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings/src/`

**Files Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings/src/AeroToolManager.gd`
- supporting `/src/*.gd` runtime files as needed

**Status:** ⏳ Pending

**Results:** Pending execution.

---

### Task 3: Build the `.testbed/` diagnostic scene and JSON/event visibility surface

**Bead ID:** `Pending`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-04`  
**Prompt:** In repo `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings`, claim the assigned bead and build the `.testbed/` diagnostic scene for the performance tool. Ensure the hidden testbed has the expected `/assets/`, `/scenes/`, and `/scripts/` structure as needed. The scene should start sampling after load, display raw signals, current recommendation, reasons, and emitted event history, and provide any simple controls needed to validate the classifier behavior without involving assembly-community.

**Folders Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings/.testbed/`
- `.testbed/assets/`
- `.testbed/scenes/`
- `.testbed/scripts/`

**Files Created/Deleted/Modified:**
- `.testbed/scenes/*`
- `.testbed/scripts/*`
- `.testbed/assets/*` only if needed for lightweight diagnostics

**Status:** ⏳ Pending

**Results:** Pending execution.

---

### Task 4: Add repo-local validation for the first slice

**Bead ID:** `Pending`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-04`  
**Prompt:** In repo `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings`, claim the assigned bead and add or run the most relevant repo-local validation for the first slice. Verify the runtime surface and testbed scene load cleanly, recommendation events fire, and the diagnostic scene makes the classifier behavior inspectable. Record the validation approach and findings in the plan.

**Folders Created/Deleted/Modified:**
- `.testbed/tests/` if needed

**Files Created/Deleted/Modified:**
- `.testbed/tests/*` if needed

**Status:** ⏳ Pending

**Results:** Pending execution.

---

### Task 5: Audit the first slice and leave the repo in a clean handoff state

**Bead ID:** `Pending`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`  
**Prompt:** In repo `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings`, claim the assigned bead and audit the completed first slice against the plan. Confirm the singleton contract is reusable, the diagnostic scene proves the right behavior, the scope stayed Lego-piece-only, and the repo is ready for commit/push handoff. Close the bead only if the implementation, validation, and plan updates all align.

**Folders Created/Deleted/Modified:**
- Plan only expected

**Files Created/Deleted/Modified:**
- `.plans/2026-05-15-performance-classifier-first-slice.md`

**Status:** ⏳ Pending

**Results:** Pending execution.

---

## Suggested First-Slice Public Contract

This contract is now frozen to match the umbrella coordination plan so downstream lanes can trust it.

### Runtime surface

Keep `src/AeroToolManager.gd` as the public autoload-facing entrypoint.

Locked underlying API shape for this slice:

```gdscript
signal recommendation_updated(result: Dictionary)
signal downgrade_recommended(event: Dictionary)

func sample_static_signals() -> Dictionary
func begin_live_sampling(context: Dictionary = {}) -> void
func stop_live_sampling() -> void
func get_current_recommendation() -> Dictionary
func get_current_signals() -> Dictionary
func get_current_reasons() -> PackedStringArray
func should_downgrade_for_active_environment() -> bool
```

### Recommendation dictionary

```json
{
  "tier": "high | medium | low",
  "confidence": "high | medium | low",
  "recommended_environment_profile": "high | medium | low",
  "startup_estimate": "high | medium | low",
  "live_confirmed": true,
  "signals": {
    "platform": "linux | windows | macos | android | ios | web",
    "renderer_name": "optional string",
    "resolution": [1920, 1080],
    "resolution_bucket": "720p | 1080p | 1440p | 4k",
    "rolling_fps": 58.7,
    "rolling_frame_time_ms": 17.0,
    "low_fps_duration_ms": 0
  },
  "reasons": [
    "Human-readable explanation"
  ]
}
```

### Downgrade event dictionary

```json
{
  "from_tier": "high | medium | low",
  "to_tier": "medium | low",
  "reason": "sustained_low_fps",
  "threshold_fps": 30.0,
  "threshold_duration_ms": 3000,
  "observed_average_fps": 24.6,
  "sample_window_ms": 3000
}
```

### Policy notes locked for parallel work

- The downgrade threshold is sustained rolling average FPS `< 30.0` for `3000 ms`.
- `downgrade_recommended(event)` is a recommendation event, not an auto-swap command.
- Avoid repeated downgrade spam for the same current tier unless the tier changes or sampling resets.
- Other repos may depend on `recommendation_updated(result)` and `downgrade_recommended(event)` only; additional local-only signals are allowed but are not part of the shared frozen contract for this pass.

### Testbed truth for this slice

The diagnostic scene should make it easy to answer:
- what static signals were captured?
- what live signals are being measured?
- what tier is currently recommended?
- why?
- what event just fired?

---

## Non-Goals For This Slice

- no `assembly-community` integration
- no environment loader work
- no camera gesture work
- no persistent app settings / saved user overrides yet
- no workout fallback asset generation
- no automatic live environment swapping policy in a consumer app

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** Implementation plan for the `aerobeat-tool-settings` first slice, now updated to the frozen shared contract for recommendation and downgrade events.

**Reference Check:** Scoped against `REF-01` through `REF-04` and aligned to the umbrella contract lock for event payloads, static/live signal semantics, and the downgrade threshold.

**Commits:**
- Pending commit

**Lessons Learned:** The cleanest first implementation slice is to prove the frozen recommendation contract in the tool repo’s own hidden testbed before any consumer integration exists.

---

*Completed on 2026-05-15*
