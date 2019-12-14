function onlydate {
  zfs list -t snapshot | grep $1 | awk '{print $1;}' | cut -d "@" -f 2
}
difference=$(diff <(onlydate $1) <(onlydate $2))
echo $difference
for line in $(echo $difference | grep '>' | awk '{print $2;}')
do
  zfs destroy $2@$line
done
notBackuped=$(echo $difference | grep '<' | awk '{print $2;}')
[[ -z $notBackuped ]] && echo no snaps && exit

last=$(echo $notBackuped | tail -n 1)
lastBackuped=$(onlydate $2 | tail -n 1)

if [[ -z $lastBackuped ]] ; then
  zfs send $1@$(onlydate $1 | head -n 1) | zfs recv -F $2
  zfs send -I $1@$(onlydate $1 | head -n 1) $1@$last | zfs recv $2
  exit
fi

#If some idiot decide to modify his snapshot filesystem
zfs rollback $2@$lastBackuped
zfs send -I $1@$lastBackuped $1@$last | zfs recv $2

exit
