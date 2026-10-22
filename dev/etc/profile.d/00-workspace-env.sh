if [ "$WORKSPACE_ENV_LOADED" = "1" ]; then
    return 0
fi
export WORKSPACE_ENV_LOADED=1

# Set PATH to include node and composer
export PATH="$PATH:./node_modules/.bin:./vendor/bin:./bin"

# Set RUNTIME_URL based on MELDIT_PORT_8080 and ensure a trailing slash
if [ -n "$MELDIT_PORT_8080" ]; then
    export RUNTIME_URL="${MELDIT_PORT_8080%/}/"
fi

# Set WEB_ROOT based on MELDIT_PROJECT_PATH
if [ -n "$MELDIT_PROJECT_PATH" ]; then
    export WEB_ROOT="$MELDIT_PROJECT_PATH"
fi
