#!/bin/bash
set -euo pipefail

whereami="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
out_dir="${whereami}"/out

function do_both() {
  ecam="$1"
  dcam="$2"
  out="$3"
  test -f "${out}" && return
  true
  ffmpeg -hide_banner -hwaccel cuvid \
    -c:v hevc_cuvid -i "${ecam}" \
    -c:v hevc_cuvid -i "${dcam}" \
    -filter_complex 'hwdownload,format=nv12,hstack,v360=dfisheye:equirect:ih_fov=185:iv_fov=122,hwupload' \
  -c:v hevc_nvenc \
  -preset:v slow \
  -movflags +faststart \
  -r 20 \
  $out
}
function equirect_it() {
  in="$1"
  out="$2"
  test -f "${out}" && return
  true
#ffmpeg -y -i clip.stacked.mp4 -vf v360=dfisheye:equirect:ih_fov=185:iv_fov=185 -c:v libx265 clip.equirect.mp4
  ffmpeg -hide_banner -hwaccel cuvid \
    -c:v hevc_cuvid -i "${in}" \
    -filter_complex 'hwdownload,format=nv12,v360=dfisheye:equirect:ih_fov=185:iv_fov=185,hwupload' \
  -c:v hevc_nvenc \
  -preset:v slow \
  -movflags +faststart \
  -r 20 \
  $out
}
function stack_it() {
  ecam="$1"
  dcam="$2"
  out="$3"
  test -f "${out}" && return
  true
  #ffmpeg -i clip.ecam.clipped.mp4 -i clip.dcam.clipped.mp4 -filter_complex hstack -c:v libx265 clip.stacked.mp4
  ffmpeg -hide_banner -hwaccel cuvid \
    -c:v hevc_cuvid -i "${ecam}" \
    -c:v hevc_cuvid -i "${dcam}" \
    -filter_complex 'hwdownload,format=nv12,hstack,hwupload' \
  -c:v hevc_nvenc \
  -preset:v slow \
  -movflags +faststart \
  -r 20 \
  $out
}

route="2023-01-30--16-50-55"
ecam="${out_dir}/${route}--ecamera.fullsize.mp4"
dcam="${out_dir}/${route}--dcamera.fullsize.mp4"
out="${ecam/ecamera.fullsize.mp4/stacked.fullsize.mp4}"
stack_it "${ecam}" "${dcam}" "${out}"
in="$out"
out="${in/stacked.fullsize.mp4/equirect.fullsize.mp4}"
equirect_it "${in}" "${out}"

out="${ecam/ecamera.fullsize.mp4/equirectboth.fullsize.mp4}"
do_both "${ecam}" "${dcam}" "${out}"
#do_route_camera "${route}" "${camera}"
#do_route_camera_fullsize "${route}" "${camera}"

