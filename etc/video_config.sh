#!/bin/bash
#
#

set -euo pipefail

## CONSTANTS
framew=1920
frameh=1208
fps=20
#iwq=482
#iwh=964
#ihq=302
#ihh=604

## constants but more intended to be configured
## by a user.
ffmpeg_generic_opts=()
ffmpeg_generic_opts+=(
  "\-\-protocol_whitelist" "concat,http,https,tls,tcp"
)
transcode_qp=29 # tested on amd radeon vaapi hevc_vaapi cqp prof
transcode_frame_scale=0.6
transcode_frame_w="$(python3 -c 'print(round('"${transcode_frame_scale}"'*'"${framew}"'))')"
transcode_frame_h="$(python3 -c 'print(round('"${transcode_frame_scale}"'*'"${frameh}"'))')"
hwaccel=vaapi # or macOS VideoToolbox 
              # or nvdec on nvidia pascal/turing t116

#
#        "-f", "mp4",
#        "-movflags", "empty_moov",

_ffmpeg_cropscale_transcode_vaapi() {
  in="$1"
  out="$2"
  scale_vaapi="${transcode_frame_w}:h=${transcode_frame_h}"
  cmd="ffmpeg "
  cmd+="${ffmpeg_generic_opts[@]} "
  cmd+="${ffmpeg_generic_opts[@]} "
  cmd+="-r "$fps" -i "$in" "
  cmd+="-hwaccel vaapi -hwaccel_output_format vaapi "
  cmd+="-vf 'hwupload,scale_vaapi='"${scale_vaapi}"',format=nv12' "
  cmd+="-c:v hevc_vaapi "
  cmd+="-profile:v main "
  cmd+="-rc_mode CQP "
  cmd+="-qp "$transcode_qp" "
  cmd+="$out "

  echo "$cmd"
  sleep 2
  "$cmd"


}
ffmpeg_cropscale_transcode() { a="_ffmpeg_cropscale_transcode_${hwaccel}";
  in="$1"
  out="$2"
  test -f "$out" && echo file alreadyexists
  test -f "$out" && return
  "$a" "$in" "$out"
}
