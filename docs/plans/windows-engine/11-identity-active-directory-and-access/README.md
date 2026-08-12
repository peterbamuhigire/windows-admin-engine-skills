# Phase 11 — Identity, Active Directory, and access

## Purpose

Cover Windows identity from local accounts through domain services while protecting the identity boundary and preserving historical attribution.

## Workstreams

### 11.1 Local identity

Inventory and safely manage local users, groups, profiles, rights assignments, scheduled-task principals, services, certificates, Credential Manager references, and local administrators. Separate discovery from creation, disablement, removal, and password operations.

### 11.2 Active Directory

Build read-only and staged skills for forest/domain/site/topology, domain controllers, replication, FSMO, trusts, OUs, users, groups, computers, service accounts, SPNs, delegation, secure channels, time, LDAP, Kerberos, DNS dependency, and tombstone/recovery boundaries.

### 11.3 Access governance

Map roles, least privilege, group nesting, privileged groups, tiering, JEA endpoints, LAPS, break-glass access, approval separation, and offboarding. Never return secrets as ordinary evidence.

### 11.4 Identity changes

Require explicit identity, scope, reason, approval, expiry, rollback, and verification for create, move, disable, delete, group membership, delegation, password, LAPS, SPN, and policy operations.

## Required artifacts

- local-access skill
- Active Directory health skill
- identity lifecycle skill
- JEA and LAPS decision references
- AD object schemas and safe-key rules
- replication and secure-channel evidence fixtures
- privileged-operation approval matrix

## Verification

Test workgroup, member server, domain controller, read-only account, delegated operator, suspended identity, stale object, duplicate name, replication fault, broken secure channel, time skew, and rollback of a non-destructive staged change.

## Exit gate

Read-only AD health is lab-validated across a multi-machine domain. Identity-changing skills remain explicitly gated until review, staged execution, and recovery evidence exist.

## Dependencies and risks

Depends on Phases 06, 08, and 10. Identity errors can create silent enterprise-wide impact; default to discovery, least privilege, and no secret capture.
