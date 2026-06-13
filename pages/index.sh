
source config.sh

htmx_page << EOF
  <h1>${PROJECT_NAME}</h1>
  <a href="${RECURSE_BASE_URL}/oauth/authorize?client_id=${APP_ID}&redirect_uri=${REDIRECT_URI}&response_type=code">Login</a>
EOF
