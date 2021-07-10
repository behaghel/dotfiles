Managing my dotfiles and bringing the "home sweet home" feeling on any machine in no time.

# Getting Started

``` shell
$ git clone [this repo url] ~/.dotfiles
$ cd .dotfiles && install.sh
```

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

## Tell, Don't ask & Verify
- declarative > functional > procedural
- don't assume, test

# Tooling

The ideal case is when `git` and `stow` are all I need and that's the case for pure dotfile management.

But the idea of this repository is to go a bit beyond and to make me feel home on any machine I have to work with. That implies at times reconfiguring part of it for which I use **Ansible**. It also entails installing stuff for which I use **homebrew**. It's reasonably platform agnostic. Homebrew is also helpful in treating parts of my config as module and orchestrating pre/post hooks and dependencies between them.

Both Ansible and homebrew are well aligned with our tenets.

Bottom line: if `stow` isn't enough to get me a capability from this repo ready to be used on my workstation then I rely on `brew` to activate it. And I minimise the ad hoc scripting and enforce idempotent declarative behaviour with _Ansible_.

## Tools That Were Discarded

- [https://github.com/twpayne/chezmoi](chezmoi) :: clever with lots of great functionality but I couldn't resolve myself to only interact with my dotfiles through a dedicated command. Too invasive. 
- [https://nixos.org/](nix) :: looks good, on paper seems even more aligned than `brew` with our tenets… I may simply need to try.
- [https://github.com/FooSoft/homemaker](homemaker) :: go makes perfect sense here and overall a well balanced project. It's not unix-like enough though and is also task-oriented full of script code captured in array of strings. It reinvents stow and package management.

# Inspiration
- One day I switched channel on my chromebook and lost all my debian setup in a snap. If it wasn't too painful to recover, it wasn't instantaneous either. Something had to be done.
