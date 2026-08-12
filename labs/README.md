# Disposable Windows labs

Lab artefacts describe topology and evidence contracts; they do not include
Windows media, licences, secrets, recovery keys, or reusable credentials.

| Lab | Topology | Capabilities | Status |
|---|---|---|---|
| `client-local` | one Windows 11 client | inventory, health, command tree, service preview | LAB_VALIDATED on development host |
| `domain-two-dc` | isolated forest, two DCs, member server/client | AD/DNS/time/replication/GPO/LAPS/gMSA/recovery | NOT_ASSESSED |
| `server-core` | Server Core member server | module compatibility, services/storage/network | NOT_ASSESSED |
| `hyper-v` | standalone host and two disposable guests | VM/switch/checkpoint/guest verification | NOT_ASSESSED |
| `iis` | member IIS server and client probe | sites/pools/TLS/config rollback | NOT_ASSESSED |
| `workgroup-remoting` | two isolated workgroup hosts | WinRM trust/certificate/timed recovery | NOT_ASSESSED |
| `mixed-fleet` | client, member, unreachable target | canary, partial failure, retry/no-contact | NOT_ASSESSED |
| `recovery` | clean restore target | file/system-state/VM recovery and RPO/RTO | NOT_ASSESSED |

Each lab must have a rebuild owner, licensed image source, isolated network,
snapshot/reset method, fixture manifest, cleanup, failure injection, and evidence
retention policy before its status can advance.
