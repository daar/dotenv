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
