# Session Log — sc-flooding Project

Paper title: **"Flood Perceptions, Social Capital, and Public Support for Property Buyout Programs"**

This log records what has been done in each working session. Update it at the end of each session (newest entry first).

---

## Project Overview

An original statewide survey of South Carolina residents (CloudResearch,
November–December 2023, quota-matched to Census age/gender/race) on public
support for government property buyout programs. Two outcomes: (1) support
for a buyout program among all respondents (1–7), modeled by OLS on flood
perceptions/experience, community factors, and individual factors; (2)
homeowners' willingness to accept a buyout (1–5) in a survey experiment
that randomizes the number of hypothetical "disruptive flooding days" per
year (7–200).

**Key files:**
- `flood-risk.qmd` — main manuscript (renders to HTML, PDF, DOCX)
- `scripts/recodes.R` — raw data loading, all recodes/scales (incl. Cronbach's alpha), ZIP-to-county and FEMA NRI merges
- `scripts/analysis.R` — sources `recodes.R`, fits the two OLS models reported in the manuscript
- `scripts/export-cited-refs.R` — pre-render step that trims the master `.bib` to cited keys
- `data/SC Statewide Survey NUMBER.csv` — numeric-coded survey responses (not in git)
- `README.md` — project structure and reproduction instructions
- `peer-review-flood-risk.md` — internal pre-submission peer review

---

## Session History

### Session 1 — 2026-09-09 (Internal peer review + project setup)

- Produced `peer-review-flood-risk.md`: a tough-but-fair referee-style
  review of `flood-risk.qmd`, read alongside `scripts/recodes.R` and
  `scripts/greenwood-analysis.R`. Recommendation: major revisions. Main
  points — federal vs. state framing of the support DV, the loaded
  wording of the support question, the "community attachment" construct
  being the wrong frame for H2a–c, an `infraScale` denominator bug (÷5 for
  4 items) and all four scales rounded to integers in `recodes.R`, the
  unused FEMA NRI objective-risk data, silent case loss from the inner
  joins, no regression table in the manuscript, and a ceiling-limited
  second study whose null is reported without statistics.
- Completed the CLAUDE.md "set-up" checklist (the user had already moved
  `_quarto.yaml` and `nowlin-style-profile.md` from `project-files/` and
  renamed the manuscript to `flood-risk.qmd` with a real title):
  - Copied `scripts/export-cited-refs.R` from the template and set its
    source file to `flood-risk.qmd`.
  - Set the render target in `_quarto.yaml` to `flood-risk.qmd`.
  - Pointed the manuscript YAML `bibliography:`/`csl:` at the locally
    generated `references.bib` / `american-political-science-association.csl`
    (they had been absolute Dropbox paths, which overrode `_quarto.yaml`
    and bypassed the pre-render step).
  - Created `scripts/analysis.R` (sources `recodes.R`, fits
    `supportPreModel` and `supportPostModelOwn`).
  - Rewrote `README.md` and `LOG.md` for this project (both were still the
    cue-WTP project's files).
  - Added `.gitignore` (ignores `/data`, `/literature`,
    `nowlin-style-profile.md`, the generated bib/csl, and R/Quarto/OS
    junk).
  - Initialized git, created the public GitHub repo, and pushed. Redacted
    the `project-files` template path from `CLAUDE.md` before the first
    commit (per set-up step 11).

---

## Analysis Architecture

- `scripts/recodes.R` does all data construction: reads
  `data/SC Statewide Survey NUMBER.csv`, drops the two Qualtrics header
  rows, builds every recoded variable, averages the multi-item scales
  (bonding social capital `scBond`, bridging `scBridge`, community
  resilience `commRel`, infrastructure satisfaction `infraScale`) and
  their Cronbach's alpha objects (`scBondA`, `scBridgeA`, `commRelA`,
  `infraA`), then merges `data/SC-zip-to-county.csv` and
  `data/NRI-short.csv` to produce `scFloodData2` (the analytic frame).
- `scripts/analysis.R` sources `recodes.R` and fits the two manuscript
  models. Tables and figures are built in `flood-risk.qmd` code chunks;
  some results are reported via inline R.

## Key Analytical Decisions

- Support-for-buyout model (`supportPreModel`): OLS, `buyoutSupportPre`
  (1–7) on all 16 predictors, full sample.
- Accept-buyout model (`supportPostModelOwn`): OLS, `buyoutSupportOwn`
  (1–5) on `floodDays` plus covariates. `buyoutSupportOwn` is only asked of
  homeowners, so the estimation sample is implicitly homeowners and
  `ownHome` is dropped from the RHS.
- Bibliography workflow: master bib/csl live under
  `01-RESEARCH/Manuscript-Files/`; `scripts/export-cited-refs.R` writes a
  trimmed project-local `references.bib` and copies the CSL at pre-render.

## Open Items (from the internal review, not yet addressed)

- `infraScale` divisor bug and `round(..., 0)` on all four scales — re-run
  the analysis after fixing.
- Add a full regression table (and the flood-days model) to the manuscript.
- Reconcile federal vs. state framing of the support question.
- Bring in FEMA NRI objective risk; use administrative (not self-reported)
  coastal-county coding.
- Report the sample-accounting funnel and per-model Ns.
- Reframe the experiment around the ceiling effect; report the null with
  full statistics.
