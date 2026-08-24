let
  ## Personal public key, generated in nixtop
  valentin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9CaJu6FJJ4s4NaL546RufQdrw7UB4zlChTN10avrpt valentinvergara@gmail.com";
  vvh-rpiCCP = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFnooPRguWFgea7aS0bnhcBHvcCDJbcXsHWxNetbCaSY NixOS. Raspberry Pi 5 in Concepcion";

  ## The server's public host key (you can view this by running `cat /etc/ssh/ssh_host_ed25519_key.pub` on each host)
  rpiCCP = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEu8bz88GCTzZ8qqh7nXr2/whskR5ISwhr3jQ4hPvk3 root@rpi-ccp";

  admins = [ valentin vvh-rpiCCP];
  all-systems = [ rpiCCP ];

in
  {

  "secrets/cloudflare-ddns.age".publicKeys = admins ++ all-systems;
  "secrets/cloudflare-acme.age".publicKeys = admins ++ all-systems;
  "secrets/homepage-secrets.age".publicKeys = admins ++ all-systems;

}
