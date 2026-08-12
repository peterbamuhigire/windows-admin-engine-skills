# Phase 10 — Networking and remote management

## Purpose

Make the engine reliable for Windows network and remote administration without making remote lockout or lateral movement easier than necessary.

## Workstreams

### 10.1 Network state

Cover interfaces, IP addresses, routes, gateways, DNS client, proxy, NLA profiles, firewall profiles, listening ports, TCP state, MTU, VPN indicators, certificates, and name-resolution paths.

### 10.2 Diagnostic decision trees

Separate DNS failure, local stack failure, route failure, firewall rejection, service-not-listening, authentication failure, certificate/trust failure, proxy failure, and application-layer failure. Each step must identify the evidence that discriminates between hypotheses.

### 10.3 Remoting

Support explicit, tested boundaries for WinRM, CIM, PowerShell remoting, SSH, RDP health, RSAT, Windows Admin Center, and approved API adapters. Record transport, authentication, delegation, encryption, endpoint configuration, and session identity.

### 10.4 Safe network mutation

Build preview, timed rollback, out-of-band prerequisite, and post-change reachability checks for IP, DNS, firewall, WinRM, RDP, proxy, route, and certificate operations. Never apply a remote firewall change without a preservation plan.

## Required artifacts

- windows-network-admin skill
- remote-management skill
- network fingerprint schema
- connection diagnostic tree
- firewall and WinRM risk playbook
- port and DNS evidence fixtures
- safe remote-change test harness

## Verification

Test workgroup and domain, local and remote, IPv4 and IPv6 where claimed, DNS split-horizon, access denied, expired certificate, blocked port, wrong credentials, dropped session, and timed rollback.

## Exit gate

A user can diagnose a connection failure without mutation, and a permitted operator can make a bounded change with verified access preservation. Unsupported authentication or network topology is reported as blocked or not assessed.

## Dependencies and risks

Depends on Phases 06, 08, and 09. The main risks are lockout and false diagnosis; both require deliberate negative fixtures and out-of-band recovery.
