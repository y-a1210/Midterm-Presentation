/*
  アンケートの設定（GitHub Pages で公開する版）。書き換えるのはこのファイルだけです。
  GitHub 上でこのファイルを開き、鉛筆のボタンで編集 →「Commit changes」で保存すると、1〜2分で公開ページに反映されます。
*/
window.SURVEY_CONFIG = {
  // 回答の受け取り側（Supabase）。Supabase の「Project Settings → API」（または Connect）にある値をそのまま貼る
  supabaseUrl: '',   // Project URL（例：https://abcdefghijklmn.supabase.co）
  supabaseKey: '',   // Publishable key（sb_publishable_… で始まる）または anon public key。公開してよい鍵です（secret / service_role の鍵は絶対に入れない）

  // 同意画面の「問い合わせ先」に出す文（例：'工学院大学 ヒューマンインタフェース研究室 山岡（メール：…）'）
  contact: '（実施時に記載）',

  // 倫理審査の承認番号（空のままなら「実施前に記載」と出る）
  ethics: '',

  // 参加者IDの頭文字（W001, W002, … になる）と、画面の順序の割付の乱数の種
  idPrefix: 'W',
  allocSeed: 'uicmp-web',

  // 研究者メニューで「所要時間が短すぎる」として除外する時間（分）
  minMinutes: 10,

  // 完了コードを出すか（クラウドソーシングで募集し、謝礼のためにコードを入力してもらうときだけ true）
  showCode: false,
};
