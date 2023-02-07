function athena_request {
  jwt="${1}"
  dongle="${2}"
  athena_message="${3}"
  curl 2>/dev/null -H "Authorization: JWT ${jwt}" "https://athena.comma.ai/${dongle}" \
    -d "${athena_message}"
}
function athena_method_list_data_directory {
  jwt="${1}"
  dongle="${2}"
  #,"params":{"prefix": "boot"},
  athena_message='{"method":"listDataDirectory","params":{},"jsonrpc":"2.0","id":0}'
  athena_request "${jwt}" "${dongle}" "${athena_message}"
}
function athena_method_list_upload_queue {
  jwt="${1}"
  dongle="${2}"
  athena_message='{"method":"listUploadQueue","params":{},"jsonrpc":"2.0","id":0}'
  athena_request "${jwt}" "${dongle}" "${athena_message}"
}
function athena_method_upload_file_to_url {
  jwt="${1}"
  dongle="${2}"
  upload_file="${3}"
  upload_url="${4}"
  expiry="$(date "+%s" -d tomorrow)"
  athena_message='{"id":0,"jsonrpc":"2.0","method":"uploadFilesToUrls","params":{"files_data":[{"fn":"'"${upload_file}"'","url":"'"${upload_url}"'","headers":{"x-ms-blob-type":"BlockBlob"},"allow_cellular":false}]},"expiry":'"${expiry}"'}'
  athena_request "${jwt}" "${dongle}" "${athena_message}"
}
function request {
  url=https://api.commadotai.com/
  jwt="${1}"
  endpoint="${2}"
  curl 2>/dev/null -L -H "Authorization: JWT ${jwt}" \
    "${url}/${endpoint}"
}
function request_uploaded_files_for_route {
  jwt="${1}"
  routefull="${2}" # "<dongle>|<route>"
  request "${jwt}" v1/route/"${routefull}"/files
}
function date_to_epoch_millis() {
  date_in="${1}"
  secs=$(date -d "${date_in}" +%s)
  echo $((secs * 1000))
}
function epoch_millis_n_days_ago() {
  n_days="${1}"
	nowsecs=$(date "+%s")
  from_secs=$((nowsecs - (n_days * 24 * 60 * 60)))
  #from_date="$(date_to_epoch_millis "$(date -d "@${from_secs}")")"
  from="$((from_secs * 1000))"
  echo $from
}
function request_routes_last_n_days() {
  jwt="${1}"
  dongle="${2}"
  n_days="${3}"
  #routefull="${2}" # "<dongle>|<route>"
  from=$(epoch_millis_n_days_ago ${n_days})
  request "${jwt}" v1/devices/${dongle}/segments?from=${from}
  #request v1/devices/${dong}/segments?from=${from} | jq -r '.[].canonical_route_name' | uniq
}
function request_upload_url_creation {
  jwt="${1}"
  dongle="${2}"
  filename="${3}"
  expire_date_days=1
  filename="$(echo "$filename" | sed -E 's/rlog$/rlog.bz2/g')"
  filename="$(echo "$filename" | sed -E 's/qlog$/qlog.bz2/g')"
  request "${jwt}" v1.4/"${dongle}"/upload_url/"?path=${filename}&expiry_days=${expire_date_days}"
}

