function athena_request {
  jwt="${1}"
  dongle="${2}"
  athena_message="${3}"
  curl -H "Authorization: JWT ${jwt}" "https://athena.comma.ai/${dongle}" \
    -d "${athena_message}"
}
function athena_method_list_data_directory {
  jwt="${1}"
  dongle="${2}"
  athena_message='{"method":"listDataDirectory","params":{},"jsonrpc":"2.0","id":0}'
  athena_request "${jwt}" "${dongle}" "${athena_message}"
}
