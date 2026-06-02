# AeroBeat Tool Settings

**Date:** 2026-05-15  
**Status:** Complete  
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

**Bead ID:** `aerobeat-tool-settings-85e`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In repo `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings`, claim the assigned bead and inspect the current runtime/testbed structure. Confirm how `src/AeroToolManager.gd` should remain the public-facing entrypoint, what supporting scripts should be added under `/src/`, what `.testbed/` folders/scenes/scripts/tests already exist, and lock the precise first-slice public contract for the performance recommendation singleton and its emitted events.

**Folders Created/Deleted/Modified:**
- Planning/docs only expected

**Files Created/Deleted/Modified:**
- Contract notes only

**Status:** ✅ Complete

**Results:** Confirmed that `src/AeroToolManager.gd` was still the untouched template entrypoint and that `.testbed/` only contained a minimal hidden Godot project with placeholder GUT tests and no diagnostic scene/scripts yet. Locked the first-slice contract to keep `AeroToolManager` as the public surface while adding supporting `/src/` runtime code for static signal capture, live frame sampling, recommendation payload generation, and downgrade recommendation emission.

---

### Task 2: Implement the performance recommendation singleton in `/src/`

**Bead ID:** `aerobeat-tool-settings-gth`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In repo `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings`, claim the assigned bead and implement the first-slice performance recommendation singleton in `/src/`. Keep `src/AeroToolManager.gd` as the public entrypoint, add the supporting runtime script(s) needed for static signal capture plus post-load live sampling, define the recommendation/event payloads, and keep the scope limited to the agreed Lego-piece contract rather than app integration.

**Folders Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings/src/`

**Files Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings/src/AeroToolManager.gd`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings/src/AeroPerformanceRecommendationManager.gd`

**Status:** ✅ Complete

**Results:** Replaced the template `AeroToolManager` with a stable facade that forwards the frozen contract to a new `AeroPerformanceRecommendationManager` runtime helper. The new runtime captures static device signals, performs post-load live frame sampling, computes startup/live recommendation payloads in the agreed dictionary shape, tracks rolling FPS and low-FPS duration, and emits a single downgrade recommendation event per active-tier downgrade signature.

---

### Task 3: Build the `.testbed/` diagnostic scene and JSON/event visibility surface

**Bead ID:** `aerobeat-tool-settings-bab`  
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
- `.testbed/project.godot`
- `.testbed/scenes/performance_diagnostic.tscn`
- `.testbed/scripts/performance_diagnostic_panel.gd`
- `.testbed/assets/` reserved but left lightweight/empty for this pass

**Status:** ✅ Complete

**Results:** Added a hidden workbench scene that automatically starts live sampling, surfaces recommendation/signals/reasons/event history in the UI, and exposes controls for refreshing static signals, restarting sampling, stopping sampling, and simulating both 60 FPS and 24 FPS sample bursts. This makes the classifier behavior visible and tuneable without integrating with `assembly-community`.

---

### Task 4: Add repo-local validation for the first slice

**Bead ID:** `aerobeat-tool-settings-d9r`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-04`  
**Prompt:** In repo `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings`, claim the assigned bead and add or run the most relevant repo-local validation for the first slice. Verify the runtime surface and testbed scene load cleanly, recommendation events fire, and the diagnostic scene makes the classifier behavior inspectable. Record the validation approach and findings in the plan.

**Folders Created/Deleted/Modified:**
- `.testbed/tests/`

**Files Created/Deleted/Modified:**
- `.testbed/tests/test_AeroToolManager.gd`

**Status:** ✅ Complete

**Results:** Replaced the placeholder manager test with repo-local coverage for the frozen public surface, recommendation payload shape, live-confirmed sampling behavior, and sustained low-FPS downgrade recommendation emission. Validation passed with `godot --headless --path .testbed --import`, `godot --headless --path .testbed --script addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`, and `godot --headless --path .testbed --quit-after 1`.

---

### Task 5: Audit the first slice and leave the repo in a clean handoff state

**Bead ID:** `aerobeat-tool-settings-d9r`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`  
**Prompt:** In repo `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings`, claim the assigned bead and audit the completed first slice against the plan. Confirm the singleton contract is reusable, the diagnostic scene proves the right behavior, the scope stayed Lego-piece-only, and the repo is ready for commit/push handoff. Close the bead only if the implementation, validation, and plan updates all align.

**Folders Created/Deleted/Modified:**
- Plan only expected

**Files Created/Deleted/Modified:**
- `.plans/2026-05-15-performance-classifier-first-slice.md`

**Status:** ✅ Complete

**Results:** Audited the delivered slice against the frozen contract and confirmed the scope stayed repo-local: the public surface remains centered on `AeroToolManager`, the runtime truth comes from post-load live measurement, the downgrade event is recommendation-only, and the testbed visibly proves raw signals, recommendation payloads, reasons, and emitted events. Repo is ready for commit/push handoff.

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

**Status:** ✅ Complete

**What We Built:** A reusable first-slice performance recommendation tool centered on `src/AeroToolManager.gd`, backed by a new `AeroPerformanceRecommendationManager` runtime helper and a hidden `.testbed` diagnostic workbench. The slice now captures static signals, confirms live post-load performance, emits the frozen recommendation/downgrade payloads, and exposes a visible UI plus deterministic debug simulation controls for tuning.

**Reference Check:** `REF-01` and `REF-03` are satisfied by keeping the reusable runtime surface in the tool repo and centered on `AeroToolManager`. `REF-02` is satisfied by honoring the locked contract, downgrade threshold, and recommendation-only policy. `REF-04` is satisfied by turning the hidden workbench into the canonical truth surface for signals, reasons, and event emission.

**Commits:**
- Pending final commit at time of plan update

**Lessons Learned:** The classifier is much easier to trust when the repo-local workbench can both observe real post-load behavior and deterministically simulate low/high FPS bursts without involving downstream consumers.

---

*Completed on 2026-05-15*
