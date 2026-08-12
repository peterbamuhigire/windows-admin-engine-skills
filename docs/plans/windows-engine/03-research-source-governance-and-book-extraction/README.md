# Phase 03 — Research, source governance, and book extraction

## Purpose

Build the evidence base for the engine without reproducing books or treating old administration advice as current Windows truth. Use the Digital Research Engine's source-evaluation, evidence-discipline, verification, and Kaizen rules.

## Workstreams

### 3.1 Source register

For every source record title, author, publisher, edition, URL or licensed file identifier, acquisition date, legal access, source tier, covered Windows/build/PowerShell scope, volatility, owner, last reviewed, review due, extracted artifacts, and verification status.

### 3.2 Authority tiers

- Tier 1: Microsoft product documentation, protocol specifications, official tools, current release notes, lab output.
- Tier 2: Microsoft Press, reputable technical publishers, NIST, peer-reviewed work, formal standards.
- Tier 3: named practitioner or vendor material with reproducible evidence.
- Tier 4: tertiary references for orientation only.
- Tier 5: forums, anonymous scripts, social posts, and AI output as leads only.

### 3.3 Book reading protocol

Keep licensed books outside Git. Extract only independently written notes:

- concept and terminology maps;
- decision trees;
- failure-mode matrices;
- source-to-skill mappings;
- test hypotheses;
- command/tool maps;
- lab exercises rewritten in original language; and
- gaps requiring current Microsoft verification.

Do not store OCR dumps, full chapters, large code passages, or copied benchmark text.

### 3.4 Currentness and contradiction

Every version-sensitive statement must identify OS edition/build, role, PowerShell edition, module version, and date. Verify commands, registry paths, event IDs, defaults, security controls, and API behaviour against current Microsoft documentation and a disposable lab. Preserve contradictions by version and scope rather than averaging them away.

## Required artifacts

- engine/source-register.yaml
- source intake template
- licensed-corpus storage policy
- book relevance matrix
- extraction-note template
- claim-to-source-to-test traceability matrix
- source freshness schedule
- prompt-injection and sensitive-content review checklist

## Initial authoritative corpus

Begin with Microsoft Windows Server management, Windows Admin Center, PowerShell, JEA, DSC, Security Compliance Toolkit, Sysinternals, PSScriptAnalyzer, Pester, role documentation, and Windows lifecycle pages. The separate acquisition list in My Downloads records books and legal acquisition routes.

## Exit gate

No load-bearing claim enters a skill without a source record, scope, and verification plan. Purchased material has provenance and usage rights. The repository contains no book mirror, raw OCR, unlicensed binary, or unreviewed AI-generated source list.

## Dependencies and risks

Depends on Phase 01. The largest risk is extracting commands that were correct for old Windows versions but are unsafe or obsolete today. Current Microsoft documentation and lab evidence are mandatory for promotion.
