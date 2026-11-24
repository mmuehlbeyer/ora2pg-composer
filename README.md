# ora2pg composer

Generate an `ora2pg.conf` and example commands for migrating an Oracle database to PostgreSQL with [ora2pg](https://ora2pg.darold.net/).

This is an unofficial helper tool and is not affiliated with the ora2pg project.


2 versions are available

- **Web page** (`index.html`): fill in a form and the config updates as you type.
- **Terminal script** (`ora2pg_config.sh`): answer a few questions in bash and get the same files.

## Web page

Open `index.html` in a browser, or upload it to any web server or static host. 

Use **Copy** or **Download** to get the config, and **Copy commands** for the example commands.

## Terminal script

```
ora2pg_composer.sh
```

Press Enter to accept the default shown in brackets. The script writes two files to the current folder:

- `ora2pg.conf`: the config
- `ora2pg-commands.sh`: example commands. Run them step by step, not as one script.

## What it covers

- Oracle connection, schema and PostgreSQL target version
- Export type: tables, sequences, views, PL/SQL, triggers, data (COPY or INSERT)
- Include and skip lists (`ALLOW`, `EXCLUDE`)
- Batch sizes and parallelism based on data size and CPU cores
- LOB settings (`DATA_LIMIT`, `BLOB_LIMIT`, `LONGREADLEN`)
- BLOBs as PostgreSQL large objects (`--blob_to_lo`)
- Consistent data snapshot at an Oracle SCN (`--scn`)
- Truncating target tables before loading (`TRUNCATE_TABLE`)


