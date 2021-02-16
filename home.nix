{ config, pkgs, lib, ... }:
let
  inherit (pkgs.hax) isDarwin fetchFromGitHub;

  personalEmail = "cvoege+nix@gmail.com";
  workEmail = "colton+nix@hackerrank.com";
  firstName = "Colton";
  lastName = "Voege";
  nameHint = "V as in Victor";
  home = (builtins.getEnv "HOME");
  username = (builtins.getEnv "USER");

  # chief keefs stuff
  kwbauson-cfg = import <kwbauson-cfg>;

  coinSound = pkgs.fetchurl {
    url = "https://cobi.dev/sounds/coin.wav";
    sha256 = "18c7dfhkaz9ybp3m52n1is9nmmkq18b1i82g6vgzy7cbr2y07h93";
  };
  guhSound = pkgs.fetchurl {
    url = "https://cobi.dev/sounds/guh.wav";
    sha256 = "1chr6fagj6sgwqphrgbg1bpmyfmcd94p39d34imq5n9ik674z9sa";
  };
  bruhSound = pkgs.fetchurl {
    url = "https://cobi.dev/sounds/bruh.mp3";
    sha256 = "11n1a20a7fj80xgynfwiq3jaq1bhmpsdxyzbnmnvlsqfnsa30vy3";
  };
in with pkgs.hax; {
  # help:
  # https://rycee.gitlab.io/home-manager/options.html

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    username = username;
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
      (python3.withPackages (pkgs: with pkgs; [ black mypy bpython ipdb ]))
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
      # ruby
      scc
      sd
      shellcheck
      shfmt
      socat
      sox
      swaks
      tealdeer
      time
      unzip
      watch
      watchexec
      wget
      which
      xxd
      zip
      kwbauson-cfg.better-comma
      kwbauson-cfg.nle
      kwbauson-cfg.fordir
      kwbauson-cfg.git-trim
      (writeShellScriptBin "hms" ''
        git -C ~/.config/nixpkgs/ pull origin main
        home-manager switch
      '')
      (soundScript "coin" coinSound)
      (soundScript "guh" guhSound)
      (soundScript "bruh" bruhSound)
    ];

    file.gitmessage = {
      target = ".gitmessage";
      text = ''
        # [Tag]: Subject
        []:

        # Why

        # Meta



        # Tag should be one of the following:
        # * Feature (new feature)
        # * Bugfix (bug fix)
        # * QOL (Quality of Life fix)
        # * Documentation (changes to documentation)
        # * Style (change in code format, no logic change)
        # * Refactor (refactoring production code)
        # * Test (adding missing tests, refactoring tests; no production code change)
        # * Chore (updating webpack or gulp tasks etc; no production code change)

        # The first line should contain a type and a subject in the imperative tone.
        #     i.e. [Feature]: Add dropdown list to contact select form.

        # In the "Why" section, take a few lines to explain why this change was needed,
        # what code the change effects, and any possible side effects of the change.

        # Use "Meta" to add useful information like issue tracking id, signature (if working
        # on an open source project, give a relevant identification), and any other relevant information
        # about the project itself.
      '';
    };

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
      drmi = "di | grep none | awk '{print $3}' | sponge | xargs docker rmi";
      dc = "docker-compose";

      # k8s
      k = "kubectl";
      kx = "kubectx";
      ka = "k get pods";
      kaw = "k get pods -o wide";
      knuke = "k delete pods --grace-period=0 --force";
      klist =
        "k get pods --all-namespaces -o jsonpath='{..image}' | tr -s '[[:space:]]' '\\n' | sort | uniq -c";

      # aws stuff
      aws_id = "aws sts get-caller-identity --query Account --output text";

      # misc
      rot13 = "tr 'A-Za-z' 'N-ZA-Mn-za-m'";
      space = "du -Sh | sort -rh | head -10";
      now = "date +%s";

      # local_ops
      local_ops = "nix-local-env -d $HOME/hr/local_ops run python dev.py";
      lo = "local_ops";
      lor = "lo run";
      los = "lo status";

      #nix
      nixc = "cd ~/.config/nixpkgs";

      stop-classroom = "docker kill  $(docker ps -a | grep class | awk '{print $1}') && docker kill  $(docker ps -a | grep integration | awk '{print $1}')";

      # fzfp = "fzf --preview 'bat --style=numbers --color=always {}'";
    };

    initExtra = ''
      shopt -s histappend
      set +h

      export DO_NOT_TRACK=1

      export MONOREPO_DIR="$HOME/mimir"
      export LOCAL_OPS_USE_NIX=true

      # add local scripts to path
      export PATH="$PATH:$HOME/.bin/:$HOME/.local/bin"

      # asdf and base nix
    '' + (if isDarwin then ''
      source /usr/local/opt/asdf/asdf.sh
      source /usr/local/opt/asdf/etc/bash_completion.d/asdf.bash
    '' else ''
      source $HOME/.asdf/asdf.sh
      source $HOME/.asdf/completions/asdf.bash
    '') + ''
      source ~/.nix-profile/etc/profile.d/nix.sh

      # bash completions
      source ~/.nix-profile/etc/profile.d/bash_completion.sh
      # source ~/.nix-profile/etc/bash_completion.d/better-comma.sh
      source ~/.nix-profile/share/bash-completion/completions/git
      source ~/.nix-profile/share/bash-completion/completions/ssh
    '';
  };

  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };

  programs.mcfly = {
    enable = true;
    enableBashIntegration = true;
  };

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
      symbol = if isDarwin then "ᛗ" else "ᛥ";
      success_symbol = "[${symbol}](bright-green)";
      error_symbol = "[${symbol}](bright-red)";
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
      shake = "remote prune origin";
    };
    extraConfig = {
      color.ui = true;
      push.default = "simple";
      pull.ff = "only";
      core = {
        editor = if isDarwin then "code --wait" else "nano";
        pager = "delta --dark";
      };
    };
  };
}
