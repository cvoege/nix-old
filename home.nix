{ config, pkgs, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  promptChar = if pkgs.stdenv.isDarwin then "ᛗ" else "ᛥ";
  personalEmail = "benaduggan@gmail.com";
  workEmail = "ben@hackerrank.com";
  firstName = "Ben";
  lastName = "Duggan";
  username = if isDarwin then "benduggan" else "bduggan";
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = username;
  home.homeDirectory =
    if isDarwin then "/Users/${username}" else "/home/${username}";
  home.stateVersion = "21.03";

  home.packages = with pkgs; [
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
    unzip
    watch
    wget
    which
    xxd
    zip

    # Comma - run nix programs without installing them
    (with pkgs;
      writeShellScriptBin "," ''
        cmd=$1
        db=${path + "/programs.sqlite"}
        sql="select distinct package from Programs where name = '$cmd'"
        packages=$(${sqlite}/bin/sqlite3 -init /dev/null "$db" "$sql" 2>/dev/null)
        if [[ $(echo "$packages" | wc -l) = 1 ]];then
          if [[ -z $packages ]];then
            echo "$cmd": command not found
            exit 127
          else
            attr=$packages
          fi
        else
          attr=$(echo "$packages" | ${fzy}/bin/fzy)
        fi
        if [[ -n $attr ]];then
          exec ${nixUnstable}/bin/nix --experimental-features 'nix-command = nix-flakes' shell -f ${
            toString path
          } "$attr" --command "$@"
        fi
      '')
    (writeShellScriptBin "hms" ''
      git -C ~/.config/nixpkgs/ pull origin main
      home-manager switch
    '')
  ];


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
      fetchout = "!f() { git co master; git branch -D $@; git fetch && git co $@; }; f";
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
