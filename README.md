# ora2pg config generator

Generate an `ora2pg.conf` and example commands for migrating an Oracle database to PostgreSQL with [ora2pg](https://ora2pg.darold.net/).

> This is an unofficial helper tool and is not affiliated with the ora2pg project. ora2pg is developed by Gilles Darold.

Two versions are included:

- **Web page** (`index.html`): fill in a form and the config updates as you type.
- **Terminal script** (`ora2pg_config.sh`): answer a few questions in bash and get the same files.

## Web page

Open `index.html` in a browser, or upload it to any web server or static host. It is a single file with no build step and no server code. Everything runs in the browser; nothing you enter is sent anywhere.

Use **Copy** or **Download** to get the config, and **Copy commands** for the example commands.

The page loads the IBM Plex fonts from Google Fonts. To avoid that, remove the `<link>` line in the `<head>`; the page then uses system fonts.

## Terminal script

```
bash ora2pg_config.sh
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

The web page has a few more options (character set, identifier case, partitions, direct load) and shows notes on settings worth a second look.

## Passwords

No password is ever stored in the config. Pass the Oracle password with `-w` (the example commands read it with `read -s` so it stays out of your shell history) and the PostgreSQL password with the `PGPASSWORD` environment variable.

## Before you run a migration

The generated values are starting points, not tuned settings. Review the config, check it against `ora2pg --help` and the documentation for your ora2pg version, and do a test run on a copy of your data first.
