# `Dotenv` Free Pascal .env Loader

A lightweight `.env` file loader for **Free Pascal**. This library lets you load key/value pairs from a `.env` file into your Free Pascal program, with support for:

- `KEY=VALUE` parsing
- Single-quoted and double-quoted values
- Escaped characters inside double quotes (`\n`, `\r`, `\t`, `\\`, `\"`)
- Variable expansion using `${VAR}`
- Required variable checks

> ⚠️ Note: This implementation does **not** modify the system environment.  
> All variables are stored internally in memory and accessed via `DotEnvGet(Key)`.


## Why?

Managing configuration through environment variables is a best practice, especially for web or desktop applications.  
Instead of hardcoding secrets or config values, you can keep them in a `.env` file and load them safely into your Pascal application. `.env` files can be excluded from your repository to keep sensitive data secure.


## Installation

If you use [Nova Packager](https://github.com/daar/nova), add this package to your project:

```bash
nova require daar/dotenv
````

Then import it in your Pascal code:

```pascal
uses Dotenv;
```



## Usage

### 1. Create a `.env` file

```env
# Database settings
DB_HOST=localhost
DB_USER=root
DB_PASS="secret"

# Paths
BASE_DIR=/home/user
LOG_DIR=${BASE_DIR}/logs
```



### 2. Load the `.env` file in your Pascal code

```pascal
program DemoEnv;

uses
  SysUtils, Dotenv;

begin
  // Load .env file)
  LoadDotEnv('.env');

  // Require some variables
  RequireEnvVars(['DB_HOST', 'DB_USER', 'DB_PASS']);

  // Print them
  WriteLn('DB_HOST = ', DotEnvGet('DB_HOST'));
  WriteLn('DB_USER = ', DotEnvGet('DB_USER'));
  WriteLn('DB_PASS = ', DotEnvGet('DB_PASS'));
  WriteLn('LOG_DIR = ', DotEnvGet('LOG_DIR'));
end.
```

Output:

```
DB_HOST = localhost
DB_USER = root
DB_PASS = secret
LOG_DIR = /home/user/logs
```



### 3. Require specific variables

Ensure that critical variables exist before running:

```pascal
RequireEnvVars(['DB_HOST', 'DB_USER', 'DB_PASS']);
```

If any variable is missing, the program raises an exception:

```
Required environment variable "DB_PASS" is not set!
```



## Features

* ✅ Reads `.env` files line by line
* ✅ Supports comments (`# ...`)
* ✅ Handles quotes and escape sequences
* ✅ Expands variables (`${VAR}`) using internal values
* ✅ Provides `RequireEnvVars()` for safety checks
* ✅ Fully self-contained — no system environment modification



## License

MIT — free to use and modify.
