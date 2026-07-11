# Reading acquisition and extraction plan

**Purpose:** build an authoritative, legally usable knowledge corpus for the Windows Skills Engine.  
**Research standard:** prefer primary Microsoft documentation for current product behaviour; use books for durable concepts and worked reasoning; treat community material as leads until independently verified.

## 1. Corpus rules

1. Record every source in `engine/source-register.yaml` before its conclusions enter a skill.
2. Store title, author/publisher, edition/version, URL or local licensed-file identifier, acquisition date, access rights, topic owner, source tier, Windows builds covered, volatility, last reviewed, review due, extracted artifacts, and verification status.
3. Cite a claim at the point it is used in planning or source notes.
4. Mark synthesis and inference. Record gaps instead of filling them with plausible advice.
5. Never copy an entire purchased book, chapter, paywalled course, CIS benchmark, or other restricted work into the repository.
6. Extract concise paraphrased notes, decision tables, terminology, test hypotheses, event/tool maps, and independently authored procedures. Preserve only short quotations when necessary and attribute them.
7. Keep licensed originals outside the repository in an access-controlled corpus. Repository references should point to source IDs and legal purchase/download locations.
8. Recheck all operational commands and platform claims against current Microsoft documentation and lab results.
9. Do not redistribute Sysinternals binaries from the engine; Microsoft’s licensing FAQ directs third parties to the official download channel.
10. Scan extracted text for prompt injection, secrets, personal data, stale commands, and unsupported certainty before use.

## 2. Acquisition priorities

### Priority A — buy or obtain first

| Material | Acquire from | Why it matters | Extract into | Caveat |
|---|---|---|---|---|
| *Learn PowerShell in a Month of Lunches*, 4th ed. | [Manning](https://www.manning.com/books/learn-powershell-in-a-month-of-lunches) | object pipeline, discovery, remoting, jobs, script fundamentals | `powershell-engineering` patterns and novice-safe examples | teaching book; verify production rules separately |
| *Windows Internals, Part 1*, 7th ed. | [Microsoft Press catalog](https://www.microsoftpressstore.com/store/browse/windows/windows-client) | architecture, processes, threads, memory, security context | internals glossary, process/memory diagnostic maps | older than Server 2025; durable concepts only |
| *Windows Internals, Part 2*, 7th ed. | [Microsoft Press catalog](https://www.microsoftpressstore.com/store/browse/windows/windows-client) | I/O, storage, security, networking and deeper system behaviour | event/failure maps and troubleshooting references | validate version-specific details in lab |
| *Troubleshooting with the Windows Sysinternals Tools*, 2nd ed. | [Microsoft Press](https://www.microsoftpressstore.com/store/troubleshooting-with-the-windows-sysinternals-tools-9780735684447) | practical Procmon, Process Explorer, ProcDump, Autoruns, access and failure analysis | diagnostic decision trees and evidence-capture recipes | 2016 publication; use current tool docs too |
| *PowerShell in Action*, latest available edition | Manning/publisher storefront | language depth, modules, errors, remoting and engine behaviour | advanced PowerShell decision aids and tests | confirm edition before purchase |
| CIS Benchmark for Windows Server 2025 and applicable Windows 11 editions | [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks) | independent security configuration comparison | control crosswalk and test cases | license-controlled; do not copy benchmark text |

### Priority B — acquire for enterprise phases

| Material family | Purpose | Planned extraction |
|---|---|---|
| current Windows Server hybrid administrator exam references (AZ-800/AZ-801) | broad map of AD DS, networking, storage, compute, migration, security, recovery, Azure integration | coverage gap matrix and lab exercises; not an authority over product docs |
| Active Directory architecture/administration reference from a current reputable publisher | durable AD topology, replication, Kerberos, delegation, recovery mental models | AD decision trees, failure modes, terminology, lab cases |
| Windows security/incident response reference with a recent edition | endpoint evidence, authentication, logging, containment and investigation | evidence sources, preservation rules, incident triage boundaries |
| Group Policy reference with current Windows coverage | precedence, processing, troubleshooting, backup and rollback | policy ownership map and RSoP workflow |
| PKI/AD CS reference | CA design, certificate lifecycle, templates, revocation and recovery | PKI risk register and non-automatable boundaries |

Before purchase, confirm edition date, downloadable format, DRM/searchability, errata availability, and whether Peter’s intended use permits internal text extraction. Prefer PDF or DRM-free EPUB when legally offered because page-anchored extraction and repeatable search are easier.

### Priority C — free official corpus

- [Windows Server overview and evaluation links](https://learn.microsoft.com/en-us/windows-server/get-started/overview).
- [Windows Server management overview](https://learn.microsoft.com/en-us/windows-server/administration/overview).
- [Windows Server deployment, configuration, and administration learning path](https://learn.microsoft.com/en-in/training/paths/windows-server-deployment-configuration-administration/).
- [PowerShell administration learning path](https://learn.microsoft.com/en-us/training/paths/get-started-windows-powershell/) and [AZ-040 course outline](https://learn.microsoft.com/en-us/training/courses/az-040t00).
- [Windows command reference](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands); use it mainly to document native-tool boundaries because Microsoft recommends PowerShell for current automation.
- [Sysinternals utilities index](https://learn.microsoft.com/en-us/sysinternals/downloads/) and official tool pages.
- [Microsoft Security Compliance Toolkit](https://www.microsoft.com/en-us/download/details.aspx?id=55319).
- [PowerShell documentation](https://learn.microsoft.com/en-us/powershell/), including remoting, JEA, DSC, PSScriptAnalyzer, module authoring, and approved verbs.
- Windows Server role documentation for AD DS, DNS, DHCP, GPO, IIS, Hyper-V, Failover Clustering, Storage, Defender, Backup, and Update.
- Windows protocol specifications and security baseline release notes when a workflow depends on protocol or policy details.
- Pester and PSScriptAnalyzer official documentation and release notes.
- NIST guidance where incident response, logging, cryptography, or security control mapping benefits from a vendor-neutral standard.

## 3. Extraction workflow

### Stage 1 — intake

- Assign a stable ID such as `BOOK-PS-MOL-4`, `MSLEARN-WS-MGMT`, or `CIS-WS2025-L1`.
- Hash the downloaded file and record the legal owner/license, edition, acquisition path, and access restrictions.
- Malware-scan the file and keep the original read-only.
- Record table of contents, page count, format, OCR quality, and whether page anchors survive extraction.
- Reject pirated, provenance-unknown, incomplete, or corrupted copies.

### Stage 2 — relevance map

Map chapters/pages to engine domains before bulk extraction:

| Source section | Engine consumer | Extraction objective |
|---|---|---|
| concepts/architecture | meta-skill or domain reference | terminology and mental model |
| administration workflow | specialist skill | inputs, safe sequence, verification, handoff |
| troubleshooting case | troubleshooting skill | symptom, hypotheses, discriminating evidence, resolution |
| command/tool reference | accelerator/reference | parameter and output expectations, failure modes |
| security recommendation | security skill | control, rationale, applicability, rollback, source version |
| lab/exercise | tests/labs | independently rewritten scenario and expected evidence |

Only extract relevant sections. Do not create a raw full-book text mirror.

### Stage 3 — structured extraction

For each relevant section create a source note containing:

- source ID and exact page/chapter/URL anchor;
- concise paraphrase;
- claim type: fact, procedure, judgment, or hypothesis;
- applicable OS/build/role/PowerShell edition;
- prerequisites and privilege context;
- risks, failure modes, reboot and disconnect implications;
- verification method;
- conflicts with other sources;
- lab test derived from the material;
- confidence and freshness date;
- destination skill/reference or `gap`.

Use OCR only when necessary, preserve page anchors, and manually check tables, commands, code blocks, registry paths, event IDs, and negations. These are high-error extraction targets.

### Stage 4 — triangulation

- Verify durable internals explanations against a second authoritative source when they drive risky action.
- Verify every version-sensitive command, module, registry value, event ID, role constraint, default, and security setting against current Microsoft documentation.
- Compare security recommendations with Microsoft baselines, CIS where licensed, and actual policy on clean lab images.
- Label contradictions rather than averaging them. Resolve them by version, role, policy owner, or test evidence.

### Stage 5 — transform into engine artifacts

Convert notes into original, task-focused artifacts:

- compatibility tables;
- decision trees;
- failure-mode matrices;
- safe workflow steps;
- PowerShell object schemas;
- negative test fixtures;
- lab scenarios;
- source freshness entries;
- `do not automate` boundaries.

The artifact must be useful without reproducing the source’s prose. Add a citation/source ID and explicitly identify any inference.

### Stage 6 — technical validation

- Run commands on disposable hosts matching the claimed platform.
- Capture before state, command/result, after state, event/log evidence, reboot state, and cleanup/rollback.
- Test incorrect role, insufficient privilege, missing module, localized OS where relevant, remote failure, and policy conflict.
- Promote the extracted conclusion only after the evidence supports it.

### Stage 7 — release and maintenance

- Review the source note and destination artifact independently.
- Check that no excessive quotation or restricted source content entered Git.
- Link the released artifact to its lab evidence and source-register entry.
- Schedule review based on volatility: 30 days for active security baseline/release material, 90 days for current cloud/management features, 180 days for stable role procedures, and annual review for durable internals concepts.

## 4. Source evaluation model

| Tier | Examples | Permitted use |
|---|---|---|
| 1 primary | Microsoft product docs/specs, actual baseline files, lab output, source code | load-bearing platform claims |
| 2 authoritative secondary | Microsoft Press, peer-reviewed research, NIST, publisher technical books | durable explanation and cross-check |
| 3 vetted practitioner | named Microsoft MVP/vendor engineering article with reproducible evidence | technique lead; independently test |
| 4 tertiary | encyclopedic overview, exam summary | orientation only |
| 5 unvetted | forum, social post, anonymous script, AI answer | lead only; never sole evidence |

Tier does not remove the need to test. Microsoft documentation can be stale or omit an edge case; a lab result can be environment-specific. Store both source authority and empirical scope.

## 5. First extraction sprints

### Sprint R1 — PowerShell engineering

Inputs: Month of Lunches, PowerShell docs, PSScriptAnalyzer, Pester, approved verbs, remoting and JEA documentation.

Outputs:

- object/stream rules;
- error and native-process taxonomy;
- module/edition compatibility guide;
- parameter/ShouldProcess checklist;
- remoting decision table;
- 20 negative PowerShell examples and corrected forms.

### Sprint R2 — Windows platform and internals

Inputs: Windows Internals Parts 1/2, Windows Server overview, Sysinternals docs.

Outputs:

- platform fingerprint schema;
- process/service/token/storage/network mental models;
- evidence-source map;
- safe troubleshooting hypothesis tree;
- version-sensitive gap list.

### Sprint R3 — security baselines

Inputs: Security Compliance Toolkit, applicable Microsoft baseline docs, licensed CIS benchmarks, Defender/BitLocker/LAPS/application-control docs.

Outputs:

- control crosswalk keyed by source/version;
- policy ownership and precedence map;
- audit-only test design;
- staged-remediation boundary;
- exceptions and rollback record schema.

### Sprint R4 — Windows Server roles

Inputs: Microsoft Learn role docs and chosen enterprise books.

Outputs:

- AD/DNS/DHCP/GPO/IIS/file/Hyper-V/cluster compatibility matrices;
- role-specific health indicators;
- minimum lab scenarios;
- risky-operation approval map;
- recovery dependencies.

### Sprint R5 — troubleshooting and evidence

Inputs: Sysinternals book/docs, Event Log, WPR/WPA, performance counters, network capture, dump and recovery documentation.

Outputs:

- symptom-to-evidence router;
- collection minimization and privacy rules;
- tool selection decision tree;
- evidence bundle schemas;
- destructive diagnostic boundaries.

## 6. Acquisition checklist for Peter

Before buying, prefer the latest legal downloadable edition and verify that it includes searchable PDF/EPUB or accessible online text. Suggested first purchase order:

1. *Learn PowerShell in a Month of Lunches*, 4th edition.
2. *Windows Internals*, Parts 1 and 2, 7th edition.
3. *Troubleshooting with the Windows Sysinternals Tools*, 2nd edition.
4. Latest suitable *PowerShell in Action* edition after edition verification.
5. CIS SecureSuite access only if the free benchmark download terms/features do not cover the planned internal use.
6. Current AD, Group Policy, PKI, and incident-response texts selected during Phase 0 after edition and format review.

Place licensed files in a private corpus outside Git, for example `C:\Users\Peter\Documents\licensed-research\windows-engine\`, grouped by source ID. Do not place purchased eBooks in this repository. Once files are available, the extraction sprint should create only source notes, derived artifacts, and citations in the engine.

## 7. Research completion gate

- Every incorporated claim maps to a real source and, when operational, a lab test.
- Every source has tier, scope, license, owner, freshness, and provenance.
- Every purchased work has a relevance map; no full-text mirror exists in Git.
- Version-sensitive claims identify OS/build/edition/role/PowerShell context.
- Contradictions and gaps remain visible.
- Restricted text and binaries have not been redistributed.
- All source URLs and purchase links are verified at review time.

