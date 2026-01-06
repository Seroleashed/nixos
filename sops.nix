{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.sshKeyPaths = [ "/home/stinooo/.ssh/sops-key" ];
  };
}
