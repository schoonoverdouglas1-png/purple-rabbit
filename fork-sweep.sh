#!/bin/bash
# Fork EVERY repo of the Meta orgs into schoonoverdouglas1-png. Add-only.
LOG=~/workspace/purple-rabbit/fork-sweep.log
exec >>"$LOG" 2>&1
echo "=== SWEEP START $(date -Is) ==="
gh repo list schoonoverdouglas1-png --limit 1000 --json name -q '.[].name' > /tmp/pr_existing.txt
for org in meta facebook meta-llama pytorch react; do
  echo "--- ORG $org ---"
  gh api "orgs/$org/repos?per_page=100" --paginate -q '.[].full_name' 2>/dev/null | while read -r full; do
    name="${full##*/}"
    if grep -qx "$name" /tmp/pr_existing.txt; then echo "SKIP-EXISTS $full"; continue; fi
    if gh repo fork "$full" --clone=false >/dev/null 2>&1; then echo "FORKED $full"; echo "$name" >> /tmp/pr_existing.txt; else echo "FAILED $full"; fi
    gh api -X PUT "user/starred/$full" >/dev/null 2>&1 && echo "STARRED $full" || echo "STAR-FAILED $full"
    sleep 1
  done
done
echo "=== SWEEP END $(date -Is) ==="
gh repo list schoonoverdouglas1-png --limit 1000 --json name,isFork -q '[.[] | select(.isFork)] | length' | sed 's/^/TOTAL-FORKS-NOW /'
