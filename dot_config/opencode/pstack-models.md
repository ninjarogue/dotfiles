# pstack model configuration

Per-role model overrides for pstack skills. Each pstack SKILL.md names its defaults in a Models section; the values here override those defaults. Delete a line to fall back to the skill default. A value of `inherit-parent` or `auto` runs that role on the parent session's model (the `Agent` call omits `model`); an alias entry in a panel list still counts toward that panel's fan-out. `session hook: off` stops the Claude Code or Codex SessionStart hook from injecting the poteto-mode mandate; any other value, or no line, leaves it on. The hook line is inert on this runtime.

feature, refactoring: opencode/muse-spark-1.3-contributor-free
bug-fix: opencode/muse-spark-1.3-contributor-free
perf-issue: opencode/muse-spark-1.3-contributor-free
hillclimb: opencode/muse-spark-1.3-contributor-free
judgment and prose: opencode/muse-spark-1.3-contributor-free
strongest judgment: opencode/big-pickle
how explorer: opencode/deepseek-v4.1-flash
how explainer: opencode/muse-spark-1.3-contributor-free
why investigators: opencode/deepseek-v4.1-flash
why synthesizer: opencode/muse-spark-1.3-contributor-free
reflect tooling: opencode/deepseek-v4.1-flash
reflect judgment, divergent, synthesizer: opencode/muse-spark-1.3-contributor-free
arena runners: opencode/big-pickle, opencode/ling-3.0-flash-fin-free, opencode/nemotron-3.5-lightning-free
arena cross-judge pool: opencode/big-pickle, opencode/ling-3.0-flash-fin-free, opencode/nemotron-3.5-lightning-free
swarm workers: opencode/deepseek-v4.1-flash
architect runners: opencode/big-pickle, opencode/union-alpha, opencode/ling-3.0-flash-fin-free
interrogate reviewers: opencode/big-pickle, opencode/union-alpha, opencode/nemotron-3.5-lightning-free

session hook: on
