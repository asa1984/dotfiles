{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wofi
    wofi-emoji
  ];
  home.file.".config/wofi/style.css".text = ''
    window {
      font-family: "Noto Sans CJK JP";
      font-weight: bold;
      margin: 0px;
      border-radius: 10px;
      background-color: rgba(27, 30, 43, 0.9);
    }

    #input {
      all: unset;
      padding: 2px;
      border-radius: 6px;
      margin: 5px;
      border: none;
      color: #c8d3f5;
      background-color: rgba(200, 211, 245, 0.2);
    }

    #inner-box {
      margin: 5px;
      border: none;
      background-color: transparent;
    }

    #outer-box {
      margin: 5px;
      border: none;
      background-color: transparent;
    }

    #scroll {
      margin: 0px;
      border: none;
    }

    #text {
      margin: 5px;
      border: none;
      color: #c8d3f5;
    }

    #entry {
      border: none;
    }

    #entry:focus {
      border: none;
    }

    #entry:selected {
      background-color: rgba(200, 211, 245, 0.2);
      border-radius: 5px;
      border: none;
    }
  '';
}
