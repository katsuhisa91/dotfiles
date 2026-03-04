# dotfiles

# dotfiles

このリポジトリは各種dotfilesの管理用です。セットアップは`make setup`のみで完了します。

## セットアップ方法

```zsh
make setup
source ~/.zshrc
```

`make setup`で以下が一括で行われます：
- Preztoのインストール（未インストールの場合）
- Prezto runcomsのリンク作成
- dotfilesのシンボリックリンク作成
- VSCode/WezTermの設定ファイルコピー

詳細はMakefileを参照してください。

## Author
[Katsuhisa Kitano](https://twitter.com/katsuhisa__)