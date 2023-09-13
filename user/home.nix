{ config, pkgs, ... }:

let 
  catppuccin-gtk = {
    name = "Catppuccin-Macchiato-Standard-Mauve-Dark";
    package = pkgs.catppuccin-gtk.override {
      accents = [ "mauve" ];
      size = "standard";
      tweaks = [ "rimless" ];
      variant = "macchiato";
    };
  };
   
  nvimPlugins = with pkgs.vimPlugins; [
    telescope-fzf-native-nvim
    nvim-treesitter.withAllGrammars
  ];
  update-user = pkgs.writeShellScriptBin "update-user" ''
    pushd ~/.dotfiles/user/ > /dev/null 2>&1
    home-manager switch -f ./home.nix
    popd > /dev/null 2>&1
  '';

  update-system = pkgs.writeShellScriptBin "update-system" ''
    pushd ~/.dotfiles/system/ > /dev/null 2>&1
    sudo nixos-rebuild switch -I nixos-config=./configuration.nix
    popd > /dev/null 2>&1
  '';
  in
{
  home.username = "alice";
  home.homeDirectory = "/home/alice";

  home.stateVersion = "23.05"; # Please read the comment before changing.

  programs.bash = {
    enable = true;
    initExtra = ''
      export EDITOR="nvim"
      export GTK_THEME="Catppuccin-Macchiato-Standard-Mauve-Dark"
    '';
  };

  home.packages = with pkgs; [
    kitty
    firefox
    tree
    qbittorrent
    vlc

    gnomeExtensions.user-themes
    gnomeExtensions.unite

    update-user
    update-system
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    GTK_THEME = catppuccin-gtk.name;
  };
  
  gtk = {
    enable = true;
    theme = {
      name = catppuccin-gtk.name;
      package = catppuccin-gtk.package;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;

        # `gnome-extensions list` for a list
        enabled-extensions = [
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "unite@hardpixel.eu"
        ];
      };

      "org/gnome/shell/extensions/user-theme" = {
       name = catppuccin-gtk.name;
      };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };
    };
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
    style.name =  "gtk2";
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = nvimPlugins;
  };

  #generate lua file containing a table with Nix managed plugins (pkg.name = pkg.out) and their locations
  home.file.".config/nvim/lua/nixos-dir/managed.lua".text = let
    tableEntries = map (plugin: 
      ''pkgs["${plugin.src.repo}"] = "${plugin.out}"''
    ) nvimPlugins;
  in ''
  local pkgs = {}
  ${builtins.concatStringsSep "\n" tableEntries}
  return pkgs
  '';
   
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
