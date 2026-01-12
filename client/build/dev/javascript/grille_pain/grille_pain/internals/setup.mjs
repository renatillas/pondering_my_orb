import * as $result from "../../../gleam_stdlib/gleam/result.mjs";
import { Ok } from "../../gleam.mjs";
import * as $error from "../../grille_pain/error.mjs";
import * as $element from "../../grille_pain/internals/element.mjs";
import * as $shadow from "../../grille_pain/internals/shadow.mjs";
import * as $unsafe from "../../grille_pain/internals/unsafe.mjs";

function do_mount() {
  return $result.try$(
    $element.create("grille-pain"),
    (node) => {
      return $result.try$(
        $element.create("div"),
        (lustre_root_) => {
          let lustre_root = $unsafe.coerce(lustre_root_);
          return $result.try$(
            $shadow.attach(node),
            (shadow) => {
              return $result.try$(
                $shadow.append_child(shadow, lustre_root_),
                (shadow) => {
                  return $result.try$(
                    $shadow.add_styles(shadow),
                    (shadow) => {
                      return $result.try$(
                        $element.body(),
                        (body) => {
                          let $ = $element.append_child(body, node);
                          
                          return new Ok([lustre_root, shadow]);
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

export function mount() {
  let _pipe = do_mount();
  return $error.context(_pipe, "Impossible to mount grille_pain.");
}
