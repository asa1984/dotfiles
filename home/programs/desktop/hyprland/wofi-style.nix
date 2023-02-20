colorscheme: let
  inherit (colorscheme) hashrgb;
in ''
  window { background: unset; }
  flowboxchild { outline-width: 0; }
  #outer-box {
    background: ${hashrgb.bg};
    border: 3px solid ${hashrgb.blue};
    border-radius: 24px;
    box-shadow: 0 2px 3px #151b16;
    margin: 5px 5px 10px;
    padding: 5px 5px 10px;
  }
  #input {
    background-color: ${hashrgb.bg};
    border: none;
    border-radius: 16px;
    color: ${hashrgb.fg};
    margin: 5px;
  }
  #inner-box {
    background-color: ${hashrgb.bg};
    border: none;
    border-radius: 16px;
    margin: 5px;
  }
  #scroll {
    border: none;
    margin: 0px;
  }
  #text {
    color: ${hashrgb.fg};
    margin: 5px;
  }
  #entry { border-radius: 16px; }
  #entry:selected {
    background-color: ${hashrgb.white};
  }
''
