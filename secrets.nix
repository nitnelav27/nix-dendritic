let
  ## Personal public key, generated in nixtop
  valentin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9CaJu6FJJ4s4NaL546RufQdrw7UB4zlChTN10avrpt valentinvergara@gmail.com";

  ## The server's public host key (you can view this by running `cat /etc/ssh/ssh_host_ed25519_key.pub` on each host)
  nixos-vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEGDsCDWlkOKolVms+OGo4a4Z6E9lJNhhNGHS+NPCU7K root@nixos-vm";

in
  {

  "secrets/cloudflare-ddns.age".publicKeys = [ valentin nixos-vm ];
  "secrets/cloudflare-acme.age".publicKeys = [ valentin nixos-vm ];

}
