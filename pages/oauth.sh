# headers

source config.sh

ACCESS_TOKEN=$(curl -Ss -X POST \
  "$RECURSE_BASE_URL/oauth/token?grant_type=authorization_code&code=${QUERY_PARAMS[code]}&redirect_uri=${REDIRECT_URI}&client_id=${APP_ID}&client_secret=${APP_SECRET}" \
 | jq -r '.access_token')

if [[ "$ACCESS_TOKEN" == null ]]; then
  end_headers
  end_headers
  return $(status_code 401)
fi

header Location /
end_headers
end_headers

DATA=$(curl -Ss "$RECURSE_BASE_URL/api/v1/profiles/me" \
  --header "Authorization: Bearer $ACCESS_TOKEN")

NAME=$(echo "$DATA" | jq -r '.name')
IMAGE=$(echo "$DATA" | jq -r '.image_path')
ID=$(echo "$DATA" | jq -r '.id')

# echo "<pre>"
# echo "$NAME"
# echo "$IMAGE"
# echo "$ID"
# echo "</pre>"
# echo "<img src=\"$IMAGE\" />"

touch data/names
touch data/scores
touch data/images
touch data/current

sed -i "/^$ID /d" data/names
sed -i "/^$ID /d" data/images
echo "$ID $NAME" >> data/names
echo "$ID $IMAGE" >> data/images

NOW=$(date "+%s")
# CUR_ID is '' if first user
read CUR_ID OLD_TIME < data/current
OLD_TIME="${OLD_TIME:-$NOW}"

if [[ "$CUR_ID" == "$ID" ]]; then
  if [[ -n "$CUR_ID" ]]; then
    # penalty
    DELTA=10
    OLD_SCORE=$(grep "^$ID " data/scores | cut -d' ' -f2)
    OLD_SCORE=${OLD_SCORE:-0}
    sed -i "/^$ID /d" data/scores
    NEW_SCORE=$((OLD_SCORE - DELTA))
    echo "$ID $NEW_SCORE" >> data/scores
  fi
fi

if [[ "$CUR_ID" != "$ID" ]]; then
  if [[ -n "$CUR_ID" ]]; then
    # update score of CUR_ID
    DELTA=$((NOW - OLD_TIME))
    OLD_SCORE=$(grep "^$CUR_ID " data/scores | cut -d' ' -f2)
    OLD_SCORE=${OLD_SCORE:-0}
    sed -i "/^$CUR_ID /d" data/scores
    NEW_SCORE=$((OLD_SCORE + DELTA))
    echo "$CUR_ID $NEW_SCORE" >> data/scores
  fi

  echo "$ID $NOW" > data/current
fi

return $(status_code 302)
