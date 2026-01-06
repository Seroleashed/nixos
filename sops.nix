{ condig, lib, ... }:

# sops-nix Secrets Management
{
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.sshKeyPaths = [ "/home/stinooo/.ssh/sops-key" ];
   
    # Beispiel-Secrets (aktiviere nach Bedarf)
    # secrets = {
    #   wifi_password = {
    #     owner = "root";
    #   };
    #   github_ssh_key = {
    #     owner = "stinooo";
    #     mode = "0600";
    #   };
    # };
  };
}
