secarg="$2"
function run {
  if [[ $secarg == "--run" ]] ; then
    $3 $1
  else
    $2 $1
  fi
}
function lscolor {
  ls -a --color $1
}
function mycd {
  cd $1
  run.sh
}
format=$(file -b -L --mime-type $1 2> /dev/null)
case "$format" in
  "text/"*) run "$1" cat nvim ;;
  "image"/*) run "$1" feh feh1 ;;
  "application"/*) echo Binary ;;
  "inode/directory") run "$1" lscolor mycd ;;
  "inode/x-empty") run "$1" lscolor myerr ;;
  "audio"/*) play $1 ;;
  *) echo $format ;;
esac
