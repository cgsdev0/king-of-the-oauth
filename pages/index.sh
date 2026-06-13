
source config.sh

declare -A names
declare -A images

# load in names
while read -r id name; do
  names[$id]=$name
done < data/names

# load in images
while read -r id image; do
  images[$id]=$image
done < data/images

read CUR_ID OLD_TIME < data/current

htmx_page << EOF
  <h1>${PROJECT_NAME}</h1>
  <img src="${images[$CUR_ID]}"/>
  <p>${names[$CUR_ID]} is currently king-of-the-oauth.</p>
  <a href="${RECURSE_BASE_URL}/oauth/authorize?client_id=${APP_ID}&redirect_uri=${REDIRECT_URI}&response_type=code">Login</a>
EOF

