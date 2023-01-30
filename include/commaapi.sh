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

