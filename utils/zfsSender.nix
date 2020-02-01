{config, pkgs, lib, ...}:
let wrapScriptFunc = pkgs.helpers.scriptWriter;
    zfsNoSync = wrapScriptFunc /etc/nixos/sources/zfsSender/zfsNoSync.sh [pkgs.zfs];
    zfsSync = wrapScriptFunc /etc/nixos/sources/zfsSender/zfsSync.sh [pkgs.zfs];
    cfg = config.services.zfsSendSnapshots;
in

{
  options = with lib; {
    services.zfsSendSnapshots = {
      sendFromToPairs = mkOption {
         default = [];
         example = [ {from = "system/home"; to = "hdd/backups/home";} {from = "system/root"; to = "hdd/backups/root"; sync = false;}];

         type = types.listOf types.attrs;
         description = ''
           A list of pairs from your snapshotting filesystems and backup filesystems.
         '';
      };
      customPeriod = mkOption {
         default = false;
         type = types.bool;
         description = ''
           If true, you must specify time for systemd timer in sendFromToPairs. For example:
           {from = "system/home"; to = "hdd/backups/home"; period = "*:0,15,30,45";}
         '';
      };
    };
  };
  config = let systemdName = lib.stringAsChars (char: if char == "/" then "_" else char);
  in
    lib.mkIf (cfg.sendFromToPairs != []) {
    systemd.services = builtins.listToAttrs (map (pair: 
    {
      name = "zfs-snapshot-sender-from-${systemdName pair.from}-to-${systemdName pair.to}";
      value = {
        after = [ "zfs-snapshot-hourly.service" ];
        description = "";
        enable = true;
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          ExecStart = if pair.sync then  "${zfsSync}/zfsSync.sh ${pair.from} ${pair.to}" 
          else "${zfsNoSync}/zfsNoSync.sh ${pair.from} ${pair.to}";
        };
      };
    }) cfg.sendFromToPairs);

    systemd.timers = let time = x: (if cfg.customPeriod && x != "" then x else "hourly");
    in
    builtins.listToAttrs (map (pair:
    {
      name = "zfs-snapshot-sender-from-${systemdName pair.from}-to-${systemdName pair.to}";
      value = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          #Wow it works! Thanks to lazy evaluation!
          OnCalendar = time pair.period;
          Persistent = "yes";
        };
      };
    }) cfg.sendFromToPairs);

  };
 }
