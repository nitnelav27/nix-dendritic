{ self, ... }: {

  ## Reusable project scaffolds, initialized per-project with:
  ##   nix flake init -t path:/home/vvh/nix-dendritic#python-ds
  ## (or a github: ref once this repo is pushed). Keeps each project's
  ## devShell independent and editable without touching this flake.
  flake.templates.python-ds = {
    path = self + "/templates/python-ds";
    description = "Per-project Python data-science dev shell (numpy, scipy, pandas, matplotlib, networkx, sqlalchemy, jupyter) activated via direnv";
  };
}
