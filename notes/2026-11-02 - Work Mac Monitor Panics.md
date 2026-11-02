# Work Mac: kernel panics with the MSI MAG321CU OLED

Work MacBook Pro, 24 GB RAM, external monitor MSI MAG321CU OLED (4K). Investigated 2026-10-30 to 2026-11-02.

## Status 2026-11-02

- Monitor at 60 Hz since 2026-11-02 around 10:00. That's the first day of the test.
- Resolution kept at the scaled "looks like 3360 x 1890". HDR off.
- macOS 27.2 (26B123), installed 2026-10-30 at about 22:45.
- No panics since 2026-10-31 08:30, but the MSI was unplugged from Friday 2026-10-30 evening to 2026-11-02. Those days with no panic don't prove anything about the monitor settings.

## Timeline

| Panic file time | macOS | Type | MSI attached |
|---|---|---|---|
| 2026-10-29 12:40 | 27.0.1 | WindowServer userspace watchdog | Yes, 165 Hz |
| 2026-10-30 11:19 | 27.0.1 | WindowServer userspace watchdog | Yes, 165 Hz |
| 2026-10-30 12:50 | 27.0.1 | WindowServer userspace watchdog | Yes, 165 Hz |
| 2026-10-31 08:02 | 27.2 | Kernel watchdogd timeout | Probably not |
| 2026-10-31 08:30 | 27.2 | Kernel watchdogd timeout | Probably not |

A panic file's time is when the Mac booted again, not when it crashed. The 08:02 panic happened at some point between the 22:51 boot after the update and 08:02.

## Panic type 1: WindowServer hang in the display driver (27.0.1)

```
panic: userspace watchdog timeout: no successful checkins from WindowServer (2 induced crashes) in 120 seconds
Boot faults: wdog,reset_in_1
```

In the stackshots, WindowServer's main thread is stuck in the kernel, "blocked by turnstile waiting for kernel_task", inside the display coprocessor (DCP) driver:

- `IOMobileGraphicsFamily`
- `AppleMobileDispT605X-DCP`
- `IOMobileGraphicsFamily-DCP`

The monitor ran at 165 Hz in the scaled 3360 x 1890 mode, so WindowServer renders a 6720 x 3780 framebuffer, twice the panel's native 4K. WindowServer used 1.9 to 2.7 GB in every snapshot. The display pipeline stops answering, WindowServer waits forever, and the watchdog fires.

## Panic type 2: whole-kernel watchdog (27.2)

```
panic(cpu 0 ...): watchdog timeout: no checkins from watchdogd in 92 seconds (3288 total checkins since monitoring last enabled)
panic(cpu 3 ...): watchdog timeout: no checkins from watchdogd in 93 seconds (155 total checkins since monitoring last enabled)
```

The whole kernel stopped, not just WindowServer. These `panic-base+socd` files have no stackshot, so they don't show which driver hung. Both came in the first hours after the 27.2 update. If the MSI really was unplugged, they're a separate problem from type 1.

## Contributing factor: memory

Jetsam (memory pressure) reports show up every day since 2026-10-27. One came 20 seconds before the 2026-10-30 12:50 panic, with under 500 MB free. The biggest consumers were WindowServer at 1.9 GB, WebKit and Chrome helpers at about 1 GB each, nine Claude Code sessions at 2.5 GB in total, plus Teams, Slack, Notion and Linear. Two of the three type 1 panics had no jetsam right before, so memory alone doesn't explain them. Jetsam is still logged daily: 2026-10-30 22:51, 2026-10-31 09:58 and 2026-11-01 05:10.

Not a cause: a load average of 83 right after boot. That's Spotlight (`mds_stores`) reindexing after an unclean shutdown.

## Plan

1. Work as normal with the MSI at 60 Hz and 3360 x 1890, with the usual load.
2. If it panics again with type 1 (DCP driver in the stackshot), turn off Adaptive Sync in the monitor's own menu (OSD), then try a different cable or port, connected directly with no dock.
3. If type 2 comes back without the monitor attached, file it in Feedback Assistant with the panic files.
4. If it runs 2 or 3 working days without a panic, 60 Hz is the fix. Keep it.
5. Close Claude Code sessions and Chrome tabs that aren't in use.

## Commands

```zsh
# Panic, WindowServer and jetsam reports
ls -lT /Library/Logs/DiagnosticReports/ /Library/Logs/DiagnosticReports/Retired/ | grep -Ei 'panic|WindowServer|Jetsam'

# Panic reason and OS version
grep -aoE 'panic\([^)]*\): [^"]{0,300}|"os_version"[^,]*' /Library/Logs/DiagnosticReports/Retired/panic-*.panic

# Display-driver frames in a panic
grep -aoE 'DCP|IOMobileGraphics|AppleMobileDisp|WindowServer' <panic-file> | sort | uniq -c

# Boots and update restarts
pmset -g log | grep -E 'powerd process is started|SoftwareUpdate'

sw_vers; uptime
```
