#!/usr/bin/env bash
# Answer a few questions, get ora2pg.conf and example commands.
# Usage: bash ora2pg_composer.sh

ask() { local a; read -r -p "$1 [$2]: " a; echo "${a:-$2}"; }
yes() { local a; read -r -p "$1 (y/N): " a; [[ $a == [yY]* ]]; }

# --- Questions ---
host=$(ask "Oracle host" "oracle.example.com")
port=$(ask "Oracle port" "1521")
service=$(ask "Oracle service name" "ORCLPDB1")
user=$(ask "Oracle user" "system")
schema=$(ask "Schema" "HR"); schema=$(echo "$schema" | tr a-z A-Z)
pg_version=$(ask "PostgreSQL version" "16")
type=$(ask "Export type (TABLE, SEQUENCE, VIEW, COPY, INSERT)" "TABLE"); type=$(echo "$type" | tr a-z A-Z)
size_gb=$(ask "Data size in GB" "10")
lobs=0; blob_to_lo=0; numbers=0; truncate=0; scn=""
yes "Has BLOB/CLOB columns?" && lobs=1
[[ $lobs == 1 ]] && yes "Export BLOBs as large objects (--blob_to_lo)?" && blob_to_lo=1
yes "Has NUMBER columns without precision?" && numbers=1
allow=$(ask "Only these tables (empty = all)" "")
exclude=$(ask "Tables to skip" "")
is_data=0; [[ $type == COPY || $type == INSERT ]] && is_data=1
if [[ $is_data == 1 ]]; then
  scn=$(ask "Export as of SCN (empty = none)" "")
  yes "Truncate target tables before loading?" && truncate=1
fi
pg_db=$(ask "PostgreSQL database" "appdb")
pg_host=$(ask "PostgreSQL host" "localhost")
pg_user=$(ask "PostgreSQL user" "postgres")

# --- Config ---
cores=$(nproc 2>/dev/null || echo 2)
parallel=1; (( size_gb >= 10 )) && parallel=$(( cores / 4 > 1 ? cores / 4 : 1 ))
copies=1;   (( size_gb >= 100 )) && copies=2
jobs=$(( cores < 2 ? cores : 2 ))
limit=10000; [[ $lobs == 1 ]] && limit=500
numeric=bigint; [[ $numbers == 1 ]] && numeric=numeric
out=$(echo "$type" | tr 'A-Z' 'a-z').sql

{
  echo "ORACLE_DSN       dbi:Oracle:host=$host;service_name=$service;port=$port"
  echo "ORACLE_USER      $user"
  echo "# ORACLE_PWD: not stored, pass it with -w"
  echo "SCHEMA           $schema"
  echo "EXPORT_SCHEMA    1"
  echo "NLS_LANG         AMERICAN_AMERICA.AL32UTF8"
  echo "CLIENT_ENCODING  UTF8"
  echo "PG_VERSION       $pg_version"
  echo "TYPE             $type"
  echo "PRESERVE_CASE    0"
  echo "PG_NUMERIC_TYPE  1"
  echo "PG_INTEGER_TYPE  1"
  echo "DEFAULT_NUMERIC  $numeric"
  echo "PARALLEL_TABLES  $parallel"
  echo "ORACLE_COPIES    $copies"
  echo "JOBS             $jobs"
  echo "DATA_LIMIT       $limit"
  echo "OUTPUT_DIR       ./output"
  echo "OUTPUT           $out"
  [[ -n $allow ]]   && echo "ALLOW            $allow"
  [[ -n $exclude ]] && echo "EXCLUDE          $exclude"
  if [[ $lobs == 1 ]]; then
    echo "BLOB_LIMIT       100"
    echo "# LONGREADLEN is 10 MB, raise it if LOBs are bigger"
    echo "LONGREADLEN      10485760"
  fi
  if [[ $is_data == 1 ]]; then
    echo "FILE_PER_TABLE   1"
    echo "DISABLE_TRIGGERS 1"
  fi
  [[ $truncate == 1 ]] && echo "TRUNCATE_TABLE   1"
} > ora2pg.conf

# --- Commands ---
pw='-w "$ORACLE_PWD"'
flags=""
[[ -n $scn ]] && flags+=" --scn $scn"
[[ $blob_to_lo == 1 && ( $type == TABLE || $type == INSERT ) ]] && flags+=" --blob_to_lo"

{
  echo 'read -s -p "Oracle password: " ORACLE_PWD'
  echo "ora2pg -c ora2pg.conf -t SHOW_VERSION $pw   # test the connection"
  echo "ora2pg -c ora2pg.conf -t SHOW_TABLE $pw     # list tables"
  echo "ora2pg -c ora2pg.conf $pw$flags   # run the export"
  echo "psql -h $pg_host -U $pg_user -d $pg_db -f output/$out"
  echo
  echo '# SCN: get it with SELECT CURRENT_SCN FROM V$DATABASE;'
  echo "ora2pg -c ora2pg.conf -t COPY --scn ${scn:-<SCN>} $pw"
  if [[ $blob_to_lo == 1 ]]; then
    echo
    echo "# BLOBs as large objects (TABLE and INSERT only, not COPY)"
    echo "ora2pg -c ora2pg.conf -t TABLE --blob_to_lo $pw"
    echo "ora2pg -c ora2pg.conf -t INSERT --blob_to_lo $pw"
  fi
} > ora2pg-commands.sh

echo
echo "Wrote ora2pg.conf and ora2pg-commands.sh"
[[ $blob_to_lo == 1 && $type == COPY ]] && echo "Note: --blob_to_lo doesn't work with COPY, use INSERT."
exit 0
