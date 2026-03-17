#!/bin/bash
# Export Nous director memories to BotNotes for git backup
# Run periodically or after significant memory updates

set -e

BOTNOTES_DIR=~/repos/Ologos.BotNotes
EXPORT_DIR=$BOTNOTES_DIR/director
PGPASSWORD=ologos_nous_2026

export PGPASSWORD

echo "Exporting Nous director memories to BotNotes..."

# Export decisions
psql -U ologos -h localhost -d ologos_nous -t -A -F'|' -c "
SELECT id, created_at, category, title, content, importance, array_to_string(tags, ',')
FROM decisions ORDER BY created_at DESC
" > $EXPORT_DIR/decisions.csv 2>/dev/null || true

# Export facts
psql -U ologos -h localhost -d ologos_nous -t -A -F'|' -c "
SELECT id, created_at, category, subject, content, source, array_to_string(tags, ',')
FROM facts ORDER BY created_at DESC
" > $EXPORT_DIR/facts.csv 2>/dev/null || true

# Export lessons
psql -U ologos -h localhost -d ologos_nous -t -A -F'|' -c "
SELECT id, created_at, category, title, content, context, array_to_string(tags, ',')
FROM lessons ORDER BY created_at DESC
" > $EXPORT_DIR/lessons.csv 2>/dev/null || true

# Export projects
psql -U ologos -h localhost -d ologos_nous -t -A -F'|' -c "
SELECT id, created_at, name, status, description, repo_url, array_to_string(tags, ',')
FROM projects ORDER BY name
" > $EXPORT_DIR/projects.csv 2>/dev/null || true

# Export worker shell summaries
for shell in ~/nous-shells/*.db; do
    name=$(basename "$shell" .db)
    sqlite3 "$shell" "SELECT * FROM identity;" > $BOTNOTES_DIR/shells/${name}_identity.txt 2>/dev/null || true
    sqlite3 "$shell" "SELECT type, COUNT(*) FROM memories GROUP BY type;" > $BOTNOTES_DIR/shells/${name}_stats.txt 2>/dev/null || true
done

echo "Export complete. Remember to commit and push BotNotes if needed."
