# AeroBeat Tool - User Settings

This is the official Tool for AeroBeat's support for persistent local user settings.

A **Tool** is a reusable service or singleton manager (e.g., API Client, Analytics, Discord Integration). It is designed to be modular and plugged into an **Assembly**.

## 📋 Repository Details

*   **Type:** Tool (Service/Module)
*   **License:** **MPL 2.0** (Weak Copyleft / Library)
*   **Dependencies:**
    *   `aerobeat-core` (Required)
    *   `aerobeat-vendor-*` (Allowed)

## 🚀 Getting Started

1.  **Clone your new repo:**
    ```bash
    git clone https://github.com/YourOrg/aerobeat-tool-custom.git
    ```
2.  **Run Setup:**
    Initialize the testbed environment.
    ```bash
    python setup_dev.py
    ```
3.  **Open in Godot:**
    Open the hidden `.testbed/project.godot` workbench in Godot `4.6.2 stable standard`.

> **Note:** Tools are libraries, not standalone games. We use a "Testbed" project (a minimal Godot project in a hidden folder) to run and debug the tool in isolation.

## 🧪 Testing & CI/CD

This template comes pre-configured with **GUT (Godot Unit Test)** workflows.

*   **Local Testing:** Run tests via the "GUT" panel in the Godot Editor (inside the Testbed).
*   **CI/CD:** A GitHub Action (`.github/workflows/gut_ci.yml`) runs automatically on every push to `main`.
*   **Requirement:** 100% Code Coverage is enforced.

## 📂 Structure

*   `src/` - The actual tool logic (GDScript). This is what gets distributed.
*   `.testbed/tests/` - Repo-local unit tests run by the hidden testbed.
*   `.testbed/` - The hidden Godot workbench used to run/debug the tool.