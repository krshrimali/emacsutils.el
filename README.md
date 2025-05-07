# emacsutils.el

Utilities for working with Python in Emacs using Tree-sitter (tested on Doom Emacs).

## 🔧 Installation

1. Place `tgkrsutil.el` in your Doom Emacs config directory (typically `~/.doom.d/`).
2. Add the following line to your `config.el`:
```elisp
(load! "tgkrsutil")
```
3. Reload Doom Emacs (SPC h r r) or restart Emacs.

Once loaded, the following keybindings will be available under the `SPC r` prefix (Python utils):

| Keybinding | Description                    | Function                                        |
|------------|--------------------------------|-------------------------------------------------|
| `SPC r if` | Copy parent function           | `tgkrsutil-python-copy-parent-function`         |
| `SPC r ic` | Copy parent class              | `tgkrsutil-python-copy-parent-class`            |
| `SPC r sf` | Show function signature (echo) | `tgkrsutil-python-show-function-signature`      |
| `SPC r sc` | Show class signature (echo)    | `tgkrsutil-python-show-class-signature`         |
| `SPC r pf` | Popup function signature       | `tgkrsutil-python-popup-function-signature`     |
| `SPC r pc` | Popup class signature          | `tgkrsutil-python-popup-class-signature`        |
| `SPC r tc` | Generate pytest command        | `tgkrsutil-python-generate-test-command`        |

(`SPC` is the leader key here)

Please note that, I have a similar plugin for neovim here: https://github.com/krshrimali/nvim-utils.nvim.
