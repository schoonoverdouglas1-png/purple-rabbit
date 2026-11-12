#!/bin/bash
# At Douglas's "make it so": wait out GitHub's repo-creation rate limit,
# create purple-rabbit, then run the full fork sweep. Add-only. Zero Muse tokens.
LOG=~/workspace/purple-rabbit/fork-sweep.log
exec >>"$LOG" 2>&1
echo "=== RETRY LOOP START $(date -Is) ==="
cd ~/workspace/purple-rabbit || exit 1
for i in $(seq 1 18); do
  if gh repo view schoonoverdouglas1-png/purple-rabbit >/dev/null 2>&1; then echo "purple-rabbit EXISTS (try $i)"; break; fi
  out=$(gh repo create purple-rabbit --public --source=. --push 2>&1 | tail -1)
  echo "try $i: $out"
  if gh repo view schoonoverdouglas1-png/purple-rabbit >/dev/null 2>&1; then echo "purple-rabbit CREATED on try $i"; break; fi
  if [ "$i" = "18" ]; then echo "GAVE UP after 18 tries — rate limit still closed"; exit 0; fi
  sleep 600
done
bash ~/workspace/purple-rabbit/fork-sweep.sh
echo "=== RETRY LOOP DONE $(date -Is) ==="
