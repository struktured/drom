(**************************************************************************)
(*                                                                        *)
(*    Copyright 2020 OCamlPro & Origin Labs                               *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

open Ezcmd.V2
open EZCMD.TYPES

let cmd_name = "run"

let action ~args ~cmd ~package =
  decr Globals.verbosity;
  (* By default, `drom run` should be quiet *)
  let p = Build.build ~args () in
  let cmd = !cmd in
  let cmd =
    match package with
    | Some package -> package :: cmd
    | None -> (
      match p.package.kind with
      | Library -> cmd
      | Program -> p.package.name :: cmd
      | Virtual -> cmd )
  in
  Misc.call
    (Array.of_list
       ("opam" :: "exec" :: "--" :: "dune" :: "exec" :: "--" :: cmd))

let cmd =
  let cmd = ref [] in
  let package = ref None in
  let args, specs = Build.build_args () in
  EZCMD.sub cmd_name
    (fun () -> action ~args ~cmd ~package:!package)
    ~args: (
      [ ( [ "p" ],
          Arg.String (fun s -> package := Some s),
          EZCMD.info ~docv:"PACKAGE" "Package to run" );
        ( [],
          Arg.Anons (fun list -> cmd := list),
          EZCMD.info "Arguments to the command" )
      ]
      @ specs
    )
    ~doc: "Execute the project"
