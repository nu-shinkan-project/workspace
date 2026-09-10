[deprecated] 
マルチリポジトリ構成の必然性が失われたため，本リポジトリはdeprecatedとします．
将来的にマルチリポジトリ構成が必要になった際に再利用するための資源として削除せずにarchiveとしていますが，基本的利用しません．

# ワークスペースのセットアップ

Git 管理対象外の `nu-shinkan-workspace` ディレクトリを作成し、開発用リポジトリと
`.devcontainer` をセットアップします。

## Windows

```powershell
irm https://raw.githubusercontent.com/nu-shinkan-project/workspace/main/setup.ps1 | iex
```

実行ポリシーで失敗する場合は、同じ PowerShell セッションで
`Set-ExecutionPolicy -Scope Process Bypass -Force` を先に実行してください。

## macOS / Linux

`git`、`curl`、`unzip` が必要です。

```sh
curl -fsSL https://raw.githubusercontent.com/nu-shinkan-project/workspace/main/setup.sh | bash
```

## 動作

### 自動クローン

セットアップスクリプトは，関連リポジトリを自動でクローンします．
クローンするリポジトリは，`devcontainer/repos`で改行区切りで指定します．

`devcontainer/repos` の各行は、既定では `nu-shinkan-project` organization 内のリポジトリ名として扱われます．完全な Git URLも指定できます．
ただし，空行と `#` で始まる行は無視されます。

なお，自動クローンはすでに同名のディレクトリ・またはファイルがない場合のみに行われます．

### 環境更新

devcontainerへの attach 時に配布元の commit hash を確認し、更新がある場合だけ `.devcontainer` を同期します．自動クローンは，不足しているリポジトリを clone します．行われるのは clone のみで，clone 済みリポジトリに対する `pull` や変更は行いません．
