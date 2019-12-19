export PATH="$coreutils/bin"
mkdir $out
for i in $1
do
  name=$(echo $i | cut -d '-' -f 2)
  full=$out/$name
  echo "#!$zsh/bin/zsh" >> $full
  echo $2$out/ >> $full
  echo "out=$out" >> $full
  cat $i >> $full
  chmod +x $full
done
