# 航空券予約サイトの画面についてのアンケート（SORAMADO UI比較アンケート v3.1）

工学院大学大学院 ヒューマンインタフェース研究室の修士論文の実験で使うアンケートサイトです。
参加者は、予約メモの状況で3つの航空チケットを、3種類の予約画面で1つずつ予約し、前後の質問に答えます（約25分・PC／スマートフォン）。

- 参加者用のページ：`index.html`（GitHub Pages で公開）
- 設定：`config.js`（回答の保存先・問い合わせ先などは、ここだけ書き換える）
- 回答の保存先の準備：`supabase_setup.sql`（Supabase の SQL Editor で1回実行）

ページの中の一覧画面は、一般的な航空券予約サイトの画面構成を研究用に再現したもので、実在のサイトとは関係ありません。予約・支払いは模擬で、実際には行いません。

---

## 公開の手順

### 1. GitHub Pages で公開する
1. このフォルダの4つのファイル（`index.html`・`config.js`・`supabase_setup.sql`・`README.md`）を、リポジトリの「Add file → Upload files」にまとめてドラッグし、「Commit changes」。
2. リポジトリの「Settings → Pages」→ Source：**Deploy from a branch**、Branch：**main** ／ **/(root)** →「Save」。
3. 1〜2分後に `https://（ユーザー名）.github.io/（リポジトリ名）/` が公開URLになります（Settings → Pages の上に表示）。

この時点でページは誰でも見られますが、回答はまだ集まりません（次の2・3を済ませると集まります）。

### 2. 回答の保存先（Supabase）を作る
1. https://supabase.com →「Start your project」→「Continue with GitHub」でログイン。
2. 「New project」：名前（例：soramado-survey）、Database Password は「Generate a password」、Region は **Northeast Asia (Tokyo)** →「Create new project」（1〜2分待つ）。
3. 左の「SQL Editor」を開き、`supabase_setup.sql` の中身を全部貼り付けて「Run」。最後に表示される **read_key（読み取りキー）** を控える（研究者メニューで使う。公開しない）。
4. 「Project Settings → API Keys」（または画面上部の「Connect」）で、**Project URL** と **Publishable key**（`sb_publishable_…`）をコピー。
   - `secret` や `service_role` の鍵は使わない・どこにも貼らない。

### 3. config.js に貼る
GitHub でこのリポジトリの `config.js` を開き、鉛筆のボタン（Edit）で次を書き換えて「Commit changes」。

```js
supabaseUrl: 'https://xxxxxxxx.supabase.co',
supabaseKey: 'sb_publishable_xxxxxxxx',
contact: '工学院大学 ヒューマンインタフェース研究室 山岡（メール：…）',
ethics: '（承認番号）',
```

Publishable key は、ページに入れて公開してよい鍵です。この設定では、回答を保存する・割付の番号をもらう・読み取りキーで全員分を読む、の3つの関数しか使えず、表を直接読むことはできません。

### 4. 確認する
1. 公開URLを開いて、1回最後まで回答する（終了画面に「回答データを送信しました」と出る）。
2. Supabase の「Table Editor → survey_sessions」に1行入っていることを確かめる。
3. 研究者メニュー：公開URLの末尾に `#lab` を付けて開く →「回答データ」→ 読み取りキーを入れて「集めた回答を読み込む」→「集計表」。
4. 本番の前に試しの回答を消す：SQL Editor で `supabase_setup.sql` の一番下の2行（`delete …` と `alter sequence …`）の先頭の `--` を消して実行。

## 補足
- 参加者IDと画面の順序は、同意したときに Supabase から割付の番号をもらって決まります（6人ごとに6通りの順序が1回ずつ。つながらないときは乱数）。
- 送信に失敗したときは、終了画面に「もう一度送信する」が出ます。回答はその端末にも残り、次にページを開いたときに自動で送り直します。
- Supabase の無料プランは、1週間まったく使われないと一時停止します（データは残り、ダッシュボードの「Restore」で戻せます）。
