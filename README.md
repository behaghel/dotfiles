Managing my dotfiles and bringing the "home sweet home" feeling on any
machine in no time.

# Getting Started

For a quick (and dirty) setup, using only `git` and `stow` in the shell:
``` shell
$ git clone [this repo url] ~/.dotfiles
$ cd .dotfiles && install.sh
```

When using nix (or nix-darwin on macOS), replace `install.sh` with
`nix run`. In that scenario, the `hostname` will be used to find
a _hostConfiguration_ with that name and configure your machine
accordingly.

# Usage

## The nix flake way

To update your local home config using the latest state from this
repository, you need to run the following in the directory that has
the host flake for your machine:

``` shell
$ sudo nixos-rebuild switch --flake .#my-machine --update-input hub-dotfiles
```

# Project Structure

The _root_ is meant to list all the _modules_ I use at least in one
_configuration_. A _module_ is a set of software that supports me for
one activity. That activity could doing my emails (`./mail`), coding
in _pharo_ (`./pharo`), etc.

In a _module_, we often find a special subdirectory called `._setup`.
It contains all the meta elements to build, install, configure and run
the software in this module.

## Inside ._setup

This project allows for 2 modes: `stow` and `nix`.

### The `stow` mode

The `stow` mode is the unix way. GNU `stow` is a command that uses
symbolic links to install select packages (and versions) into the
right path of a UNIX system. Any _module_ in that project can be
installed into a host by simply _stowing_ it. Stowing concretely in
that context means surfacing its content in the `HOME` directory.
That's why we need the special directory `._setup`: to store the parts
that shouldn't be installed in `HOME` (e.g. installation script).

In its simplest form then, a module is just a directory that host
dotfiles. When stowed, its dotfiles are linked in the home directory.

This doesn't help with installing the related programs. To mitigate
that, the `stow` mode supports a basic execution model that augments
the pure stowing. It uses the following files in `._setup.sh`. They
are all optional.

``` shell
._setup/
├── fonts
├── needs
├── post.sh
├── pre.sh
└── verify.sh
```

`needs` allows to list the dependencies to this module. It's one
dependency per line. Comments start with `#`. Dependencies can be
packages to be installed on the system when the module is stowed. By
default, the package will be installed with APT. That is to say the
default assumption is that we are on a Debian system (or derived).
Since this assumption isn't always valid there is (rudimentary)
support for ansible packages. This is triggered when the dependency
name is prefixed with `ansible:`.

Another type of dependency is another module. If a record in `needs`
is the same as the name of a directory at the root of this project, it
will be detected and that module will be installed as a prerequisite
to this module's stowing. This also allows to mix in home configs
easily for different machines or purposes. E.g. you can create
a simple module `minimal` with only such `needs` file:

``` shell
zsh
vim
tmux
```

You could also have another module `kitchensink` with a long list of
packages and modules in `needs`. Then all you'd have to do is to
`install.sh minimal` or `install.sh kitchensink` on your hosts
depending on what environment you want to find yourself into.

`pre.sh` is run before the stowing. It's a good place to do the
installation of all the programs that cannot be installed via the
dependencies in `needs`.

`post.sh` is run after the stowing.

`verify.sh` is a simple predicate, a check, that if true tells the
system that this module is already installed. Since uninstalling and
reinstalling is manual / unsupported, it can be useful at times to
look into it to understand how to force the reinstallation.

`fonts` allows to have one URL per line. Each URL should point to
a font file or an ZIP archive with several fonts. These fonts are
considered dependencies to the module and are installed during the
same phase as the dependencies in `needs`.

#### The ROOT module

The root directory itself has its own `._setup`. Initially it was
meant to be the default module, what gets setup when no argument is
passed to `install.sh`. For some reasons that I have forgotten, this
wasn't a good idea.

It has all the internal configs: ansible, nix, etc. It also has the
tests (more are sorely needed…).

#### A Note On The Reliability of the `stow` Mode

Since I embraced `nix`, I have used this mode less and less. If there
is some testing (via `bat` which was a good finding), it's far from
covering seriously what it should. This is to say you should expect
some rough edges. Also one shortcomings of this mode is that it's not
"eternal". There is no guarantee that a config that worked in 2019
will still work as is in 2025. It's a very desirable property but it's
incredibly difficult to achieve. This is largely due to the "impurity"
of internet, packages, systems, etc. This goes far beyond what
a single project can tackle.

Still, I am willing to do my best to support it. If you find problems,
create issues and I'll see what I can do.

### A Note On Nix Support

The complexity that comes with supporting different host systems and
the unguaranteed durability of my configs are by and large what led me
to `nix`. In fact, it's surprising how my embryonic project share in
the fundamentals of `nix`. The primitives I had to create, the
reliance on links, the concept of modules, etc. But of course `nix`
embraces purity at the system level and is a Turing-complete language
as well as a fully-fledged system-agnostic package management system.

Now nix makes things slightly more complicated. And this may well be
the sysadmin understatement of the century. Somehow it's worth it. One
of my goal with this project is to bring the goodness of `nix` while
preserving as much as possible the simplicity of the `stow` mode.
Disclaimer: we are far from having achieved this at the time of this
writing.

Let's look at how the `nix` mode works here.

### The `nix` Mode

I won't even try to explain `nix` here. In this mode, this project is
a `nix` flake. The entry point is therefore the file `flake.nix` at
the root.

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

## Why I Went Beyond Pure Dotfiles Management

- One day I switched channel on my chromebook and lost all my debian
  setup in a snap. If it wasn't too painful to recover, it wasn't
  instantaneous either. Something had to be done.
