{ self, inputs, ... }: {

  ## Authenticates outbound Nix github: fetches (flake update/build) against a
  ## GitHub personal access token so we don't hit the anonymous API rate
  ## limit (60 req/hour, shared with everything else on this network's
  ## egress IP). Token lives encrypted at rest via agenix; nix.extraOptions
  ## pulls it into /etc/nix/nix.conf at activation via `!include`, so the
  ## plaintext never touches the Nix store.
  flake.nixosModules.nasArGithubToken = { config, lib, pkgs, ... }: {

    age.secrets."github-token" = {
      file = self + "/secrets/github-token.age";
    };

    nix.extraOptions = ''
      !include ${config.age.secrets."github-token".path}
    '';

  };
}
