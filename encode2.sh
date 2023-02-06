#!/bin/bash
set -euo pipefail

whereami="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
out_dir="${whereami}"/out

function do_route_camera() {
  route="$1"
  camera="$2"
  cameranoextension="$(echo "$camera" | cut -d '.' -f 1)"
  # full route date + time
  cams="$(find "${out_dir}" | grep "${route}" | grep "${camera}" | sort -V)"
  numcams="$(echo "${cams}" | wc -l)"

  concat_list="$(echo ${cams} | tr ' ' '|')"
  out="${out_dir}/${route}--${cameranoextension}.mp4"
  test -f "${out}" && return
  true
  ffmpeg -hide_banner -hwaccel cuda \
  -i "concat:${concat_list}" \
  -vf "scale=1542:966,format=nv12" \
  -c:v hevc_nvenc \
  -preset:v slow \
  -movflags +faststart \
  -r 20 \
  $out
}
function do_route_camera_fullsize() {
  route="$1"
  camera="$2"
  cameranoextension="$(echo "$camera" | cut -d '.' -f 1)"
  # full route date + time
  cams="$(find "${out_dir}" | grep "${route}" | grep "${camera}" | sort -V)"
  numcams="$(echo "${cams}" | wc -l)"

  concat_list="$(echo ${cams} | tr ' ' '|')"
  out="${out_dir}/${route}--${cameranoextension}.fullsize.mp4"
  test -f "${out}" && return
  true
  ffmpeg -hide_banner -hwaccel cuda \
  -i "concat:${concat_list}" \
  -vf "scale=1928:1208,format=nv12" \
  -c:v hevc_nvenc \
  -preset:v slow \
  -movflags +faststart \
  -r 20 \
  $out
}
function do_route_camera_fullsize_cuvid() {
  route="$1"
  camera="$2"
  cameranoextension="$(echo "$camera" | cut -d '.' -f 1)"
  # full route date + time
  cams="$(find "${out_dir}" | grep "${route}" | grep "${camera}" | sort -V)"
  numcams="$(echo "${cams}" | wc -l)"

  concat_list="$(echo ${cams} | tr ' ' '|')"
  out="${out_dir}/${route}--${cameranoextension}.cuvid.mp4"
  test -f "${out}" && return
  true
  #-vsync 0
  #-resize 1928x1208
  ffmpeg -hide_banner \
    -hwaccel cuvid \
    -r 20 \
    -c:v hevc_cuvid \
    -i "concat:${concat_list}" \
    -c:v hevc_nvenc \
    -preset:v slow \
    -movflags +faststart \
    -r 20 \
    $out
}

route="2023-01-30--16-50-55"
camera="dcamera.hevc"
do_route_camera "${route}" "${camera}"
do_route_camera_fullsize "${route}" "${camera}"
camera="ecamera.hevc"
do_route_camera "${route}" "${camera}"
do_route_camera_fullsize "${route}" "${camera}"
do_route_camera_fullsize_cuvid "${route}" "${camera}"
camera="fcamera.hevc"
do_route_camera "${route}" "${camera}"

route="2023-01-30--17-13-13"
camera="dcamera.hevc"
do_route_camera "${route}" "${camera}"
camera="ecamera.hevc"
do_route_camera "${route}" "${camera}"
camera="fcamera.hevc"
do_route_camera "${route}" "${camera}"

# https://superuser.com/questions/1296374/best-settings-for-ffmpeg-with-nvenc
# https://superuser.com/questions/1525315/hevc-nvenc-option-information

#-tune:v lossless \
#-tune:v hq \
#-rc:v vbr \
#-cq:v 23 \
#-profile:v high \
#-b:v 0 \
