# emacsutils.el
All utilities coming from treesitter for emacs (tested on doom)

To use this project, put `tgkrsutil.el` in your doom folder. And copy paste this snippet in your `config.el` file:

```elisp
(load! "tgkrsutil")
```

This should load the module and enable the keymaps. Relevant keymaps can be inferred from:

```elisp
(map! :leader
      (:prefix ("r" . "Python utils")
       :desc "Copy parent function" "if" #'tgkrsutil-python-copy-parent-function
       :desc "Copy parent class" "ic" #'tgkrsutil-python-copy-parent-class
       :desc "Show function signature (echo)" "sf" #'tgkrsutil-python-show-function-signature
       :desc "Show class signature (echo)" "sc" #'tgkrsutil-python-show-class-signature
       :desc "Popup function signature" "pf" #'tgkrsutil-python-popup-function-signature
       :desc "Popup class signature" "pc" #'tgkrsutil-python-popup-class-signature
       :desc "Generate pytest command" "tc" #'tgkrsutil-python-generate-test-command))
```

Please note that, I have a similar plugin for neovim here: https://github.com/krshrimali/nvim-utils.nvim.