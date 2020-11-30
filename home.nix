{ config, pkgs, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (pkgs) fetchFromGitHub;
  promptChar = if pkgs.stdenv.isDarwin then "ᛗ" else "ᛥ";
  personalEmail = "benaduggan@gmail.com";
  workEmail = "ben@hackerrank.com";
  firstName = "Ben";
  lastName = "Duggan";
  username = if isDarwin then "benduggan" else "bduggan";

  # chief keefs stuff
  kwbauson-cfg = import (fetchFromGitHub {
    owner = "kwbauson";
    repo = "cfg";
    rev = "cd73ff040e5f28695c7557a70ad7c5b2e9e8c2be";
    sha256 = "1szlpmi8dyiwcv8xlwflb9czrijxbkzs2bz6034g8ivaxy30kxl8";
  });
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = username;
  home.homeDirectory =
    if isDarwin then "/Users/${username}" else "/home/${username}";
  home.stateVersion = "21.03";

  home.packages = with pkgs; [
    (python3.withPackages (pkgs: with pkgs; [ black mypy bpython ipdb ]))
    atool
    bc
    bzip2
    cachix
    coreutils-full
    cowsay
    curl
    diffutils
    direnv
    dos2unix
    ed
    exa
    fd
    file
    figlet
    gawk
    git
    gitAndTools.delta
    gnugrep
    gnused
    gnutar
    gzip
    htop
    less
    libarchive
    libnotify
    lolcat
    loop
    lsof
    man-pages
    moreutils
    nano
    ncdu
    netcat-gnu
    nix-direnv
    nix-bash-completions
    nix-index
    nix-info
    nix-prefetch-github
    nix-prefetch-scripts
    nix-tree
    nixfmt
    nmap
    openssh
    p7zip
    patch
    perl
    php
    pigz
    pssh
    procps
    pv
    ranger
    re2c
    ripgrep
    ripgrep-all
    rlwrap
    rsync
    scc
    sd
    socat
    starship
    swaks
    time
    tmux
    unzip
    watch
    wget
    which
    xxd
    zip
    kwbauson-cfg.better-comma
    kwbauson-cfg.nle
    kwbauson-cfg.fordir
    kwbauson-cfg.git-trim
  ];

  home.file.sqliterc = {
    target = ".sqliterc";
    text = ''
      .output /dev/null
      .headers on
      .mode column
      .prompt "> " ". "
      .separator ROW "\n"
      .nullvalue NULL
      .output stdout
    '';
  };

  programs.starship.enable = true;
  programs.starship.settings = {
    add_newline = false;
    character = {
      symbol = promptChar;
      success_symbol = "[${promptChar}](bright-green)";
      error_symbol = "[${promptChar}](bright-red)";
    };
    golang = {
      style = "fg:#00ADD8";
      symbol = "go ";
    };
    directory.style = "fg:#d442f5";
    nix_shell = {
      pure_msg = "";
      impure_msg = "";
      format = "via [$symbol$state]($style) ";
    };
    kubernetes = {
      disabled = false;
      style = "fg:#326ce5";
    };

    # disabled plugins
    aws.disabled = true;
    cmd_duration.disabled = true;
    gcloud.disabled = true;
    package.disabled = true;
  };

  # gitconfig
  programs.git = {
    enable = true;
    userName = "${firstName} ${lastName}";
    userEmail = personalEmail;
    aliases = {
      co = "checkout";
      cam = "commit -am";
      ca = "commit -a";
      cm = "commit -m";
      st = "status";
      br = "branch -v";
      branch-name = "!git rev-parse --abbrev-ref HEAD";
      # Push current branch
      put = "!git push origin $(git branch-name)";
      # Pull without merging
      get = "!git pull origin $(git branch-name) --ff-only";
      # Pull Master without switching branches
      got =
        "!f() { CURRENT_BRANCH=$(git branch-name) && git checkout $1 && git pull origin $1 --ff-only && git checkout $CURRENT_BRANCH;  }; f";
      lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
      lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";

      # delete local branch and pull from remote
      fetchout =
        "!f() { git co master; git branch -D $@; git fetch && git co $@; }; f";
      pufl = "!git push origin $(git branch-name) --force-with-lease";
      putf = "put --force-with-lease";
    };
    extraConfig = {
      color.ui = true;
      push.default = "simple";
      pull.ff = "only";
      core = {
        editor = if isDarwin then "code --wait" else "vim";
        pager = "delta --dark";
      };
    };
  };
}
