{ config, pkgs, lib, ... }:
let
  # inherit (pkgs.hax) isDarwin fetchFromGitHub;

  isDarwin = true;
  # successPromptChar = if isDarwin then "ᛗ" else "ᛥ";
  successPromptChar = "👌";
  errorPromptChar = "👀";


  personalEmail = "cvoege+nix@gmail.com";
  workEmail = "colton@beacons.ai";
  firstName = "Colton";
  lastName = "Voege";
  nameHint = "V as in Victor";
  home = builtins.getEnv "HOME";
  username = builtins.getEnv "USER";

  # chief keefs stuff
  kwbauson-cfg = import <kwbauson-cfg> { };

  jacobi = import
    (fetchTarball {
      name = "jpetrucciani-2022-07-26";
      url = "https://github.com/jpetrucciani/nix/archive/f9d139e4a2b80d0e4ba5585ce722493996b4bf44.tar.gz";
      sha256 = "00bbaj4z7nzm29c47nv19afyaz3r3mdx8in7v6hdsqvfsnbmgd11";
    })
    { };

in
{
  # nixpkgs.overlays = [ (import ./overlays.nix) ];
  # help:
  # https://rycee.gitlab.io/home-manager/options.html

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    inherit username;
    homeDirectory = home;

    # The global home manager state version
    stateVersion = "21.03";

    sessionVariables = {
      # Fuck you keith
      EDITOR = "nano";
      HISTCONTROL = "ignoreboth";
      PAGER = "less";
      LESS = "-iR";
      BASH_SILENCE_DEPRECATION_WARNING = "1";
    };

    packages = with lib; with pkgs; lib.flatten [
      (lib.optional stdenv.isLinux ungoogled-chromium)
      (python311.withPackages (pkgs: with pkgs; [
        black
        mypy
        pip
      ]))
      amazon-ecr-credential-helper
      atool
      bash-completion
      bashInteractive
      bat
      bc
      bzip2
      cachix
      coreutils-full
      cowsay
      crane
      curl
      deno
      diffutils
      dos2unix
      ed
      exa
      fd
      file
      figlet
      gawk
      gitAndTools.delta
      gnugrep
      gnused
      gnutar
      google-cloud-sdk
      gron
      gzip
      htop
      jq
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
      nixpkgs-fmt
      nodejs_20
      nmap
      openssh
      p7zip
      patch
      pigz
      postgresql
      pssh
      procps
      pv
      ranger
      re2c
      ripgrep
      rlwrap
      rsync
      # ruby
      scc
      sd
      shellcheck
      shfmt
      socat
      sox
      # spotify
      swaks
      tealdeer
      time
      # touchegg
      unzip
      watch
      watchexec
      wget
      which
      xxd
      yarn
      zip
      (with kwbauson-cfg; [
        better-comma
        nle
        fordir
        git-trim
      ])
      (writeShellScriptBin "hms" ''
        git -C ~/.config/home-manager/ pull origin main
        home-manager switch
      '')

      # jacobi memes
      (with jacobi; [
        # meme_sounds
        aws_id
        batwhich
        slack_meme
        jwtdecode
        fif
        rot13
        docker_pog_scripts
      ])
    ];

    file.gitmessage = {
      target = ".gitmessage";
      text = ''
        # Commit and PR name format
        # [Type][Jira-ID]: Description

        # For additions to the user experience
        # [Feature][READ-###]: Description of feature

        # For fixes to user-facing bugs
        # [Bugfix][READ-###]: Description of bug

        # For techincal changes that are not user-facing
        # [Tech][READ-###]: Description of techincal problem/debt addressed

        # For non-technical, non-user-facing additions, such as new components or
        # routes which are not yet surfaced in the application
        # [Chore][READ-###]: Description of non-user-facing, non-technical addition

        # For things our bots do on their own
        # [Tech][Auto]: Knapsack Report Update

      '';
    };

    # file.toucheggconf = {
    #   target = ".config/touchegg/touchegg.conf";
    #   source = ./config/touchegg.conf;
    # };

    file.sqliterc = {
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

    file.irbrc = {
      target = ".irbrc";
      text = ''
        IRB.conf[:SAVE_HISTORY] = 2_000_000
        IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.local/share/irb_history"
      '';
    };
  };

  programs.bash = {
    enable = true;
    inherit (config.home) sessionVariables;
    historyFileSize = -1;
    historySize = -1;
    shellAliases = {
      ls = "ls --color=auto";
      l = "exa -alFT -L 1";
      ll = "ls -ahlFG";
      mkdir = "mkdir -pv";
      hm = "home-manager";
      wrun =
        "watchexec --debounce 50 --no-shell --clear --restart --signal SIGTERM -- ";

      # git
      g = "git";
      ga = "g add -A .";
      cm = "g commit -m ";

      # docker
      d = "docker";
      da = "docker ps -a";
      di = "docker images";
      de = "docker exec -it";
      dr = "docker run --rm -it";
      daq = "docker ps -aq";
      drma = "docker stop $(docker ps -aq) && docker rm -f $(docker ps -aq)";
      dc = "docker-compose";

      space = "du -Sh | sort -rh | head -10";
      now = "date +%s";

      #nix
      nixc = "cd ~/.config/home-manager";

    };

    initExtra = ''
      shopt -s histappend
      set +h

      export DO_NOT_TRACK=1

      # add local scripts to path
      export PATH="$PATH:$HOME/.bin/:$HOME/.local/bin"
      # export PATH="$PATH:$HOME/flutter/bin"

      # asdf and base nix
    '' + (if isDarwin then ''
      # source /usr/local/opt/asdf/asdf.sh
      # source /usr/local/opt/asdf/etc/bash_completion.d/asdf.bash
      [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
      [[ -d /Applications/Docker.app/Contents/Resources/bin/ ]] && export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"
      alias o=open
    '' else ''
      # source $HOME/.asdf/asdf.sh
      # source $HOME/.asdf/completions/asdf.bash
      alias o=xdg-open
    '') + ''
      # source ~/.nix-profile/etc/profile.d/nix.sh

      pack-epub() { zip -rX "../$(basename $(pwd)).epub" ./* ; }

      export NIX_HOME_PATH="$HOME/.config/home-manager"
      ehome() { code "$NIX_HOME_PATH/home.nix" ; }

      lput() { yarn lint:fix && git add -A && git commit -m "$@" && git put ; }
      codedir() { EDITOR="code --wait" , vidir "$@"; }

      # bash completions
      source ~/.nix-profile/etc/profile.d/bash_completion.sh
      # source ~/.nix-profile/etc/bash_completion.d/better-comma.sh
      source ~/.nix-profile/share/bash-completion/completions/git
      source ~/.nix-profile/share/bash-completion/completions/ssh

      guh() {
        MSG="guh"
        if [ $# -gt 0 ] ; then
          MSG="$@"
        fi
        git add -A
        git commit -m "$MSG"
        git put
      }

      alias guhlint="lint-all && guh lint"
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # programs.mcfly = {
  #   enable = true;
  #   enableBashIntegration = true;
  # };

  # programs.fzf = {
  #   enable = true;
  #   enableBashIntegration = false;
  #   defaultCommand = "fd -tf -c always -H --ignore-file ${./ignore} -E .git";
  #   defaultOptions = words "--ansi --reverse --multi --filepath-word";
  # };

  programs.starship.enable = true;
  programs.starship.settings = {
    add_newline = false;
    character = rec {
      success_symbol = "[${successPromptChar}](bright-green)";
      error_symbol = "[${errorPromptChar}](bright-red)";
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
      disabled = true;
      style = "fg:#326ce5";
    };

    # disabled plugins
    aws.disabled = true;
    cmd_duration.disabled = true;
    gcloud.disabled = true;
    package.disabled = true;
  };

  programs.tmux = {
    enable = true;
    tmuxp.enable = true;
    historyLimit = 500000;
    shortcut = "j";
    extraConfig = ''
      # ijkl arrow key style pane selection
      bind -n M-j select-pane -L
      bind -n M-i select-pane -U
      bind -n M-k select-pane -D
      bind -n M-l select-pane -R

      # split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      set-option -g mouse off
    '';
  };

  programs.htop.enable = true;
  programs.dircolors.enable = true;

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "${firstName} ${lastName}";
    userEmail = workEmail;
    lfs = {
      enable = true;
    };
    aliases = {
      co = "checkout";
      dad = "add";
      cam = "commit -am";
      ca = "commit -a";
      cm = "commit -m";
      st = "status";
      br = "branch -v";
      ff = "merge --ff-only";
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
        "!f() { git co main; git branch -D $@; git fetch && git co $@; }; f";
      pufl = "!git push origin $(git branch-name) --force-with-lease";
      putf = "put --force-with-lease";
      shake = "remote prune origin";
    };
    extraConfig = {
      color.ui = true;
      push.default = "simple";
      pull.ff = "only";
      init = {
        defaultBranch = "main";
      };
      core = {
        editor = "code --wait";
        pager = "delta --dark";
      };
    };
  };

  # systemd.user.services.touchegg-client = {
  #   Unit = { Description = "touchegg-client"; };

  #   Install = { WantedBy = [ "graphical-session.target" ]; };

  #   Service = {
  #     # Restart = "on-failure";
  #     PrivateTmp = true;
  #     ProtectSystem = "full";
  #     ProtectHome = "yes";
  #     Type = "exec";
  #     Slice = "session.slice";
  #     ExecStart = "${pkgs.touchegg}/bin/touchegg";
  #   };
  # };
}

# sudo ln -s /home/cvoege/.nix-profile/lib/systemd/system/touchegg.service /etc/systemd/system/touchegg.service
# sudo systemctl daemon-reload
# sudo systemctl enable --now touchegg
# sudo systemctl status touchegg
# systemctl --user start touchegg-client.service

