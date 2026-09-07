# Installation Guide

## 1. Prerequisites

- **Elixir** ~> 1.15 and **Erlang/OTP** (verify with `elixir --version`)
- **Mix** (included with Elixir)
- A working C compiler and build tools (e.g., `gcc`, `make`) – required for `bcrypt_elixir` native extensions

## 2. Obtaining the Source Code

Download or clone the project repository to your local machine.

```bash
git clone <repository-url> live_board
cd live_board
```

*(Replace `<repository-url>` with the actual URL if available.)*

## 3. Install Dependencies

```bash
mix deps.get
```

This fetches and compiles all Elixir dependencies listed in `mix.exs`.

## 4. Environment Configuration

Copy the example environment file and set the required variables:

```bash
cp .env.example .env
```

Edit `.env` as needed. The following variables are used:

- `DATABASE_PATH` – SQLite database file location (default: `priv/repo/live_board_dev.db`)
- `PORT` – Server listening port (default: `4000`)
- `SECRET_KEY_BASE` – Required for production; can be generated with `mix phx.gen.secret`

For development, the defaults are usually sufficient.

## 5. Database Setup

Run the custom alias to create the database, run migrations, and load seed data:

```bash
mix setup
```

*(This alias executes `ecto.create`, `ecto.migrate`, and `run priv/repo/seeds.exs`.)*

Alternatively, run each step manually:

```bash
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs
```

The database is an SQLite file located at the path specified by `DATABASE_PATH`.

## 6. Starting the Development Server

```bash
mix phx.server
```

The application will be available at `http://localhost:4000` (or the custom `PORT`).

## 7. Running Tests

```bash
mix test
```

## 8. Production Build

To create a release:

```bash
MIX_ENV=prod mix release
```

## 9. Troubleshooting

- **`elixir` not found**: Ensure Elixir and Erlang are installed and added to your `PATH`.
- **`mix deps.get` fails**: Check network connectivity and that `git` is available.
- **`bcrypt_elixir` compilation errors**: Install a C compiler (e.g., `gcc`) and build tools like `make`. On Ubuntu/Debian: `sudo apt install build-essential`.
- **Port already in use**: Change `PORT` in `.env` or stop the process using the port (`lsof -i :4000`).
- **Database permission issues**: Ensure the user running the app has write permissions to the directory containing the SQLite file.