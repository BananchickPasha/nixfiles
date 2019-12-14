#I hate bash
cd /etc/nixos
prevGen=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | grep current | awk '{print $1;}')
currentGen=$(($prevGen+1))
git add *
git commit -m "Generation $currentGen"
git push
echo $currentGen
