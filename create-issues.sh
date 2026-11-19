#!/usr/bin/env bash
# Creates the WA3870-CAP starter task list as GitHub Issues and adds each one
# to your GitHub Project board.
#
# Run from inside your evergreen-quote-launch repo:
#   chmod +x create-issues.sh && ./create-issues.sh
#
# Optional: skip the board prompt by setting PROJECT_NUMBER first
#   export PROJECT_NUMBER=3
#
# Safe to re-run: issues whose titles already exist are skipped.

set -euo pipefail

# ---------- Preflight ----------
command -v gh >/dev/null || { echo "gh CLI not found."; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Not logged in. Run: gh auth login"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Run this from inside your repo folder."; exit 1; }
gh repo view >/dev/null 2>&1 || { echo "This folder isn't linked to a GitHub repo yet."; exit 1; }

REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
OWNER="$(gh repo view --json owner --jq .owner.login)"
echo "Repo:  $REPO"

# ---------- Find the project board (optional) ----------
list_projects () {
  gh project list --owner "$OWNER" --format json \
    --jq '.projects[] | "\(.number)\t\(.title)"' 2>/dev/null
}

BOARD_OK=0
PROJECTS=""

if [[ -z "${PROJECT_NUMBER:-}" ]]; then
  PROJECTS="$(list_projects || true)"
  if [[ -z "$PROJECTS" ]]; then
    echo "Couldn't read your project boards (the login may lack the 'project' permission)."
    echo "Trying: gh auth refresh -s project"
    if gh auth refresh -s project; then
      PROJECTS="$(list_projects || true)"
    fi
  fi

  if [[ -n "$PROJECTS" ]]; then
    COUNT="$(printf '%s\n' "$PROJECTS" | wc -l | tr -d ' ')"
    if [[ "$COUNT" -eq 1 ]]; then
      PROJECT_NUMBER="$(printf '%s' "$PROJECTS" | cut -f1)"
    else
      echo "Which board should the issues go on?"
      printf '%s\n' "$PROJECTS" | awk -F'\t' '{printf "  %s) %s\n", $1, $2}'
      read -rp "Project number: " PROJECT_NUMBER
    fi
  fi
fi

if [[ -n "${PROJECT_NUMBER:-}" ]] && gh project view "$PROJECT_NUMBER" --owner "$OWNER" >/dev/null 2>&1; then
  BOARD_OK=1
  echo "Board: project $PROJECT_NUMBER"
else
  echo
  echo "WARNING: can't reach a project board from the command line."
  echo "The issues can still be created; you'd then add them to the board in the browser."
  read -rp "Create the issues without adding them to the board? [y/N] " ANSWER
  [[ "$ANSWER" =~ ^[Yy]$ ]] || { echo "Stopped. Nothing was created."; exit 1; }
fi
echo

# ---------- Existing issues (so re-runs don't duplicate) ----------
EXISTING="$(gh issue list --state all --limit 500 --json title --jq '.[].title')"

make_issue () {
  local title="$1" who="$2" done_items="$3" out_of_scope="$4"

  if printf '%s\n' "$EXISTING" | grep -Fxq "$title"; then
    echo "Skipped (already exists): $title"
    return
  fi

  local body
  body="$(printf '%s\n\nDone criteria\n%s\n\nOut of scope\n- %s\n\nLinked decisions / risks\n- (add links as the week goes on)\n' \
    "$who" "$done_items" "$out_of_scope")"

  local url
  url="$(gh issue create --title "$title" --body "$body")"
  if [[ "$BOARD_OK" -eq 1 ]]; then
    gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$url" >/dev/null
    echo "Created + added to board: $title"
  else
    echo "Created: $title"
  fi
}

# ---------- The tasks ----------
make_issue "[WIRE] Run all three parts; log the client/API data gap" \
"Who it's for: the delivery team. What they get: a confirmed starting point. Why it matters: we know exactly what is and isn't connected before we change anything." \
"- [ ] Landing page opens in Live Server
- [ ] API seeded and answering curl on port 3000
- [ ] npm test passes in api/ before any changes
- [ ] Client runs on port 5173
- [ ] The client/API gap is written down as observed" \
"Fixing the gap (see the wiring issue)."

make_issue "[WIRE] Wire the client to the API (proxy, types, api module, context, form)" \
"Who it's for: the shopper. What they get: quotes that come from the database and survive a reload. Why it matters: this is the launch." \
"- [ ] Dev proxy forwards client requests to the API
- [ ] Recent-quotes panel shows quotes from the database
- [ ] A quote saved in the browser is still there after reload" \
"New features; redesigning the client."

make_issue "[TYPES] Fix the seam defect the type-check catches (kit one-line fix)" \
"Who it's for: the engineering team. What they get: a client whose types agree with the API's data. Why it matters: we catch the mismatch now instead of at launch." \
"- [ ] Type-check passes
- [ ] Fix is the kit's one-line change, not a weakened contract" \
"Changing the shared data contract."

make_issue "[DATA] Retire the static data feed and bundled sample" \
"Who it's for: the shopper. What they get: only real data on screen. Why it matters: stub data hides integration problems." \
"- [ ] sampleQuotes.ts and public/quotes.json removed with git rm
- [ ] The app still builds and runs against the API" \
"Changing seed data in the API."

make_issue "[CONFIG] Align the client rates to the API; set the launch title and banner" \
"Who it's for: the sponsor and the shopper. What they get: consistent prices and launch branding. Why it matters: the on-screen estimate must match the saved premium." \
"- [ ] Client BASE_RATES match the API's rates
- [ ] Launch title set in client/.env
- [ ] Landing banner and both quote links set" \
"Any pricing logic changes."

make_issue "[GRAPHQL] Mount GraphQL; run one query in the explorer; peek in mongosh" \
"Who it's for: the partner pilot. What they get: a working GraphQL endpoint. Why it matters: confirms the API's second interface is live." \
"- [ ] Kit's two paste lines added at the INSERT markers
- [ ] One query runs successfully in the explorer
- [ ] Documents seen in mongosh" \
"Writing new GraphQL schema or resolvers."

make_issue "[DOCKER] Build and run evergreen-quote-api:2.0; run the stack with the container" \
"Who it's for: the platform team. What they get: a portable image of the API. Why it matters: the same artifact runs everywhere." \
"- [ ] Image evergreen-quote-api:2.0 builds
- [ ] Container runs and answers the health check
- [ ] Client works against the container" \
"Pushing to a registry."

make_issue "[K8S] Demonstrate the full stack on the local cluster" \
"Who it's for: the sponsor. What they get: proof the launch runs on the cluster. Why it matters: it's the demo environment for Friday." \
"- [ ] Three API pods and one mongo pod Running
- [ ] Client works against the cluster unchanged
- [ ] A quote saved in the browser lands in the cluster's database" \
"Cloud deployment."

make_issue "[CI] Enable the two-job workflow" \
"Who it's for: the engineering team. What they get: automatic checks on every push. Why it matters: failures show up immediately." \
"- [ ] Workflow file in place under .github/workflows
- [ ] API test job green
- [ ] Client type-check and build job green" \
"New pipeline stages or environments."

make_issue "[BUILD] Production build; preview the built client against the API" \
"Who it's for: the shopper. What they get: the production version working end to end. Why it matters: dev mode can hide build problems." \
"- [ ] Production build succeeds
- [ ] Preview serves the app and talks to the API" \
"Deploying the build anywhere."

make_issue "[REVIEW] Open PR from delivery/lead to main; self-review the program's diff" \
"Who it's for: the team and the stakeholders. What they get: a reviewed, mergeable change. Why it matters: the diff is the launch on one page." \
"- [ ] PR opened from delivery/lead into main
- [ ] At least one inline review comment that asks a question
- [ ] Merged with both CI jobs green" \
"Refactoring things noticed during review (log them instead)."

make_issue "[SHOWCASE] Build and rehearse the program showcase" \
"Who it's for: managers and the sponsor. What they get: a clear 5-minute story of the launch. Why it matters: it's how the work gets seen." \
"- [ ] Five slides (or one page) written in delivery-review-outline.md
- [ ] Dry run timed at about 5 minutes
- [ ] Demo plan (live or screenshots) written down, with a fallback" \
"Adding new demo features."

make_issue "[AI] Document one Copilot-assisted step + critique (stretch)" \
"Who it's for: the delivery team. What they get: a record of how AI help was checked. Why it matters: leaders oversee AI output, not just accept it." \
"- [ ] One Copilot-assisted step documented
- [ ] Critique of the output against tests or contracts" \
"Using AI-generated code without review."

echo
if [[ "$BOARD_OK" -eq 1 ]]; then
  echo "Done. Open your board: gh project view $PROJECT_NUMBER --owner $OWNER --web"
else
  echo "Done. Add the issues to your board in the browser (see the note from Claude)."
fi