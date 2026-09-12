{ lib, ocamlPackages, ... }:
# herdr のサイドバーに、エージェントの状態を書き込む常駐プロセス。
# herdr の socket を購読し、agent.list を見て $row_* トークンを pane.report_metadata する。
ocamlPackages.buildDunePackage {
  pname = "herdr-glance";
  version = "0.1.0";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./dune-project
      ./bin
      ./lib
      ./test
    ];
  };
  minimalOCamlVersion = "5.1";
  buildInputs = with ocamlPackages; [
    eio
    eio_main
    yojson
  ];
  checkInputs = [ ocamlPackages.alcotest ];
  doCheck = true;
  meta.mainProgram = "herdr-glance";
}
