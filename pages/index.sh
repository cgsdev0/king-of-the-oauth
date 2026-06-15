
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
NOW=$(date "+%s")
DELTA=$((NOW-OLD_TIME))



function returnLeaderboard {
  while read -r id score; do
    if [[ "$id" == "$CUR_ID" ]]; then
      ((score+=DELTA))
    fi

    echo -n $score ${names[$id]}

    if [[ "$id" == "$CUR_ID" ]]; then
      echo " 🐙"
    else
      echo
    fi

  done < data/scores | sort -nr
}

htmx_page << EOF
  <h1>${PROJECT_NAME}</h1>
  <div hx-ext="sse" sse-connect="/sse" sse-swap="leader">
  <img src="${images[$CUR_ID]}"/>
  <p>${names[$CUR_ID]} is currently king-of-the-oauth.</p>
  </div>
  <h2>leaderboard</h2>
  <pre>$(returnLeaderboard)</pre>
  <a href="${RECURSE_BASE_URL}/oauth/authorize?client_id=${APP_ID}&redirect_uri=${REDIRECT_URI}&response_type=code">Capture Now!</a>
  <br>
  <br>
  <br>
  <br>
  <br>
  <br>
  <br>
  <br>
  <br>
  <br>
  <br>
  <br>
  <br>
  <br>
  <br>
  <a href="https://github.com/cgsdev0/king-of-the-oauth/">Source Code</a>
EOF
