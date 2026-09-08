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

- `devcontainer/repos` の各行は、既定では `nu-shinkan-project` organization 内のリポジトリ名として扱われます。完全な Git URLも指定できます。
- 空行と `#` で始まる行は無視されます。
- 同名のファイルまたはディレクトリが既にあれば clone も変更も行いません。
- attach 時に配布元の commit hash を確認し、更新がある場合だけ `.devcontainer` を同期してから不足しているリポジトリを clone します。
- clone 済みリポジトリに対する `pull` や変更は行いません。

保存先などは `WORKSPACE_DIRECTORY`、`WORKSPACE_REPOSITORY_URL`、`WORKSPACE_REPOSITORY_REF`、`WORKSPACE_REPOSITORY_ORG` 環境変数で上書きできます。
