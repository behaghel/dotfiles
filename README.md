Managing my dotfiles and bringing the "home sweet home" feeling on any
machine in no time.

# Getting Started

``` shell
$ git clone [this repo url] ~/.dotfiles
$ cd .dotfiles && install.sh
```

# Installation

## The nix flake way

The recommended way is through [`nix`](https://nixos.org/) and more
specifically through [`flake`](https://nixos.wiki/wiki/Flakes). In
that case, this repository acts as
a [home-manager](https://github.com/nix-community/home-manager)
module.

This repository exposes a flake called `dotfiles` that can be consumed
so:

``` nix
{
  description = "some glorious flake";

  inputs.nixpkgs.url = "nixpkgs/nixos-21.05-small";

  inputs.home-manager.url = "github:nix-community/home-manager/release-21.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.hub-dotfiles.url = "github:behaghel/dotfiles";
  inputs.hub-dotfiles.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, home-manager, hub-dotfiles }:
    let
      # Function to create default (common) system config options
      defFlakeSystem = baseCfg:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # basic config common to all hosts
            # (./hosts/default.nix)
            # Add home-manager option to all configs
            ({ ... }: {
              imports = [
                {
                  # Set the $NIX_PATH entry for nixpkgs. This is necessary in
                  # this setup with flakes, otherwise commands like `nix-shell
                  # -p pkgs.htop` will keep using an old version of nixpkgs.
                  # With this entry in $NIX_PATH it is possible (and
                  # recommended) to remove the `nixos` channel for both users
                  # and root e.g. `nix-channel --remove nixos`. `nix-channel
                  # --list` should be empty for all users afterwards
                  nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
                }
                baseCfg
                home-manager.nixosModules.home-manager
                # DONT set useGlobalPackages! It's not necessary in newer
                # home-manager versions and does not work with configs using
                # `nixpkgs.config`
                { home-manager.useUserPackages = true; }
              ];
              # Let 'nixos-version --json' know the Git revision of this flake.
              system.configurationRevision =
                nixpkgs.lib.mkIf (self ? rev) self.rev;
              nix.registry.nixpkgs.flake = nixpkgs;
            })
          ];
        };
    in {
      nixosConfigurations = {
        inherit nixpkgs;
        my-machine = defFlakeSystem {
          imports = [
            # machine specific config
            (./hosts/my-machine/default.nix)
            # Add home-manager config
            { home-manager.users.hub = hub-dotfiles.nixosModules.dotfiles; }
          ];
        };
      };
    };
}
```

This is another flake that depends on home-manager's official flake
and this repository. The outcome is a flake that configure an entire
host with a user `hub` that has these dotfiles in his `$HOME`. It
means `nix` is a prerequisite (but not NixOS even though it's
recommended). It brings all the benefits that `nix` brings. In
particular, it means if the configuration in this repository worked
once, it will still work 10 years later. For dotfiles, it's a very
relevant and desirable property. You could spend years on the same
machine and then start working on a new one.

The downside is that `nix` has a steep learning curve.

## The stow way

TODO

# Usage

## The nix flake way

To update your local home config using the latest state from this
repository, you need to run the following in the directory that has
the host flake for your machine:

``` shell
$ sudo nixos-rebuild switch --flake .#my-machine --update-input hub-dotfiles
```

## The stow way

TODO

# Tenets

## Embrace The UNIX Philosophy
- KISS & use the least sophisticated approach that works
- DRY & don't reinvent the wheel
- POLP: Principle of Least Privilege
- non-invasive, if you don't need to get out of $HOME, then don't
- be a fundamentalist when it comes to consistency

## Industrialise Like There Is No Tomorrow
- automate from A to Z
- be multi-platform and favour platform-agnostic ways
- reproducibility is vital

## Tell, Don't ask & Verify
- declarative > functional > procedural
- don't assume, test

# Tooling

The ideal case is when `git` and `stow` are all I need and that's the
case for pure dotfile management.

But the idea of this repository is to go a bit beyond and to make me
feel home on any machine I have to work with. That means installing
programs, running daemons, etc. After a careful review of what exists
to handle that in accordance with our tenets, `nix` has easily become
the key foundation. I do have the ambition to maintain an `ansible`
approach for when `nix` is too much for the use case at hand. E.g. for
a node I `ssh` on only occasionally.

## Tools That Were Discarded

- [https://github.com/twpayne/chezmoi](chezmoi) :: clever with lots of
  great functionality but I couldn't resolve myself to only interact
  with my dotfiles through a dedicated command. Too invasive.
- [https://github.com/FooSoft/homemaker](homemaker) :: go makes
  perfect sense here and overall a well balanced project. It's not
  unix-like enough though and is also task-oriented full of script
  code captured in array of strings. It reinvents stow and package
  management.

# Inspiration

- One day I switched channel on my chromebook and lost all my debian
  setup in a snap. If it wasn't too painful to recover, it wasn't
  instantaneous either. Something had to be done.
