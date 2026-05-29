let
  ## Personal public key, generated in nixtop
  valentin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9CaJu6FJJ4s4NaL546RufQdrw7UB4zlChTN10avrpt valentinvergara@gmail.com";
  vvh-nixosVm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEb/75yCQOiDvuAoRPEtC9L9T+QzvktxkSeC5qFuqFUI Valentín en NixOS-VM, Proxmox";

  ## The server's public host key (you can view this by running `cat /etc/ssh/ssh_host_ed25519_key.pub` on each host)
  nixosVm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEGDsCDWlkOKolVms+OGo4a4Z6E9lJNhhNGHS+NPCU7K root@nixos-vm";

  admins = [ valentin vvh-nixosVm];
  all-systems = [ nixosVm ];

in
  {

  "secrets/cloudflare-ddns.age".publicKeys = admins ++ [ nixosVm ];
  "secrets/cloudflare-acme.age".publicKeys = admins ++ [ nixosVm ];
  "secrets/homepage-secrets.age".publicKeys = admins ++ [ nixosVm ];

}
