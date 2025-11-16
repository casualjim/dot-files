Contains the files I use to setup my environment for editing code.

Install script provided:

```bash
bash <(curl -s https://raw.githubusercontent.com/casualjim/dot-files/master/infect.sh)
```


## Antidote setup:

```sh
antidote bundle < "$REPO_ROOT/zsh_plugins.${OS:l}.txt" >| ~/.zsh_plugins.zsh
```