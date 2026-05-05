# BOGA Shoe Collection · 上線指南

完整的「從零到上線」步驟，一邊看一邊做即可。

預計時間：**30–40 分鐘**

需要準備：
- Gmail 信箱（您已經有了：duck11230@gmail.com / boga20140614@gmail.com）
- 一張信用卡（**不會被收費**，只是 Vercel 與 Supabase 註冊時偶爾會要求驗證；兩個服務都有免費方案）
- 這個資料夾裡的 4 個檔案：`index.html`、`admin.html`、`supabase-setup.sql`、`vercel.json`

---

## 📋 上線流程一覽

```
Step 1  建立 Supabase 專案           （5 分鐘）
Step 2  執行 SQL 建立資料表           （3 分鐘）
Step 3  建立 Storage 兩個 bucket       （3 分鐘）
Step 4  設定 Email 驗證碼模板         （5 分鐘）
Step 5  把 URL 與 Key 填到兩個 HTML     （2 分鐘）
Step 6  上傳到 GitHub                 （5 分鐘）
Step 7  部署到 Vercel                 （5 分鐘）
Step 8  測試前後台運作                 （5 分鐘）
Step 9  分享給消費者                   ✓
```

---

## Step 1 · 建立 Supabase 專案（5 分鐘）

1. 前往 <https://supabase.com> → 點 **Start your project** → 用 Google 帳號登入
2. 點右上角 **New project**
3. 填寫：
   - **Name**: `boga-shoe-collection`
   - **Database Password**: 點 *Generate a password* 自動產一組（**請存到密碼管理器，重要！**）
   - **Region**: `Northeast Asia (Tokyo)` ← 台灣選這個最快
   - **Pricing Plan**: `Free` 即可
4. 點 **Create new project** → 等待 2 分鐘建置完成

---

## Step 2 · 執行 SQL 建立資料表（3 分鐘）

1. 左側選單 → **SQL Editor**（圖示像兩個齒輪）
2. 點 **+ New query**
3. 開啟本資料夾的 `supabase-setup.sql` → 全選複製整份內容 → 貼到 SQL Editor
4. 點右下角 **Run**（或按 Ctrl/Cmd + Enter）
5. 看到綠色 `Success. No rows returned` 就完成了

✅ 此步驟會建立：
- `shoes`、`profiles`、`stamps` 三張表
- 12 款預設鞋款
- 行級安全政策（RLS）— 兩位管理員 email 已寫入
- Realtime 即時同步
- 註冊自動建檔觸發器

---

## Step 3 · 建立 Storage 兩個 bucket（3 分鐘）

1. 左側選單 → **Storage**
2. 點 **New bucket**
   - **Name**: `stamp-photos`
   - **Public bucket**: ✅ 勾起來（消費者要看到自己上傳的照片）
   - 點 **Save**
3. 再點一次 **New bucket**
   - **Name**: `shoe-images`
   - **Public bucket**: ✅ 勾起來
   - 點 **Save**

⚠️ Bucket 名稱要**完全相同**（連大小寫都一樣），不然程式找不到。

---

## Step 4 · 設定 Email 驗證碼模板（5 分鐘）

預設 Supabase 寄出的驗證信是「點連結登入」，但我們要改成「6 位數驗證碼」。

1. 左側選單 → **Authentication** → **Email Templates**
2. 點 **Magic Link** 那個分頁
3. 把模板內容換成下面這段（複製貼上）：

```html
<h2>BOGA Shoe Collection</h2>
<p>您的登入驗證碼是：</p>
<h1 style="letter-spacing:8px;font-family:monospace;color:#c9a96e;">{{ .Token }}</h1>
<p>此驗證碼將於 5 分鐘後失效。如果不是您本人操作，請忽略此信。</p>
```

4. 點 **Save changes**
5. 再切到 **Confirm signup** 分頁，**重複貼上同一段內容** → Save

---

## Step 5 · 把 URL 與 Key 填到兩個 HTML（2 分鐘）

1. 左側選單 → **Project Settings**（齒輪圖示）→ **API**
2. 您會看到兩個重要值：
   - **Project URL** （像 `https://xxxxxxxx.supabase.co`）
   - **anon public** key （一長串開頭是 `eyJh...`）
3. 用任何文字編輯器打開 `index.html`，找到這兩行（大約在 1410 行附近）：

```js
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

把 `YOUR_SUPABASE_URL` 換成 Project URL；`YOUR_SUPABASE_ANON_KEY` 換成 anon public key。

4. 同樣的事在 `admin.html` 也做一次（大約 951 行附近）

5. 存檔。

---

## Step 6 · 上傳到 GitHub（5 分鐘）

Vercel 會從 GitHub 抓檔案，所以先把檔案放到 GitHub。

1. 前往 <https://github.com> → 註冊或登入
2. 右上角 **+** → **New repository**
3. 填寫：
   - **Repository name**: `boga-shoe-collection`
   - **Public** 或 **Private** 都可以
   - **不要**勾選 README、.gitignore
4. **Create repository**
5. 在新頁面找到 **uploading an existing file** 的連結，點進去
6. 把這 4 個檔案拖進去：
   - `index.html`
   - `admin.html`
   - `supabase-setup.sql`
   - `vercel.json`
7. 拉到頁面下方 → 點 **Commit changes**

---

## Step 7 · 部署到 Vercel（5 分鐘）

1. 前往 <https://vercel.com> → 點 **Sign Up** → **Continue with GitHub**
2. 授權 Vercel 存取 GitHub
3. 進入 Vercel 後 → **Add New** → **Project**
4. 找到 `boga-shoe-collection` → 點 **Import**
5. 設定畫面什麼都不用改 → 直接點 **Deploy**
6. 等 1 分鐘 → 看到「🎉 Congratulations」就完成了
7. 點上面的網址（像 `boga-shoe-collection.vercel.app`）即可開啟前台

📱 **網址記得收好** — 這就是消費者要打開的網址！

- 前台（消費者）：`https://boga-shoe-collection.vercel.app`
- 後台（您管理用）：`https://boga-shoe-collection.vercel.app/admin.html`

---

## Step 8 · 測試前後台運作（5 分鐘）

### 測試前台
1. 用手機打開前台網址
2. 輸入您的 email 與姓名 → 寄送驗證碼
3. 收信、輸入 6 位數 → 應該能進入會員卡
4. 點任一款鞋 → 上傳一張測試照片 + 訂單編號 → 送出

### 測試後台
1. 用電腦打開後台網址
2. 輸入 `duck11230@gmail.com`（或 `boga20140614@gmail.com`）→ 寄送驗證碼
3. 收信輸入驗證碼登入
4. 在「集章審核」會看到剛才送出的測試集章 → 點通過
5. 回到手機 → 應該會即時收到通過通知 + 療癒小卡

✅ 都能跑通就表示上線成功。

---

## Step 9 · 分享給消費者

把前台網址貼到：
- 官網「會員」連結
- IG bio
- 包裹卡片 / 名片 上印 QR code（用 <https://www.qr-code-generator.com> 免費產生）

---

## 🌐 自訂網域（之後要做）

如果想用 `card.boga.com.tw` 之類的網址，而不是 `xxx.vercel.app`：

1. 到任一個網域註冊商買網域（推薦 Cloudflare Registrar，便宜不亂收費）
   - `.com.tw` 約 NT$700/年
   - `.com` 約 NT$400/年
2. Vercel → 您的專案 → **Settings** → **Domains** → 輸入您的網域
3. 照畫面指示在網域註冊商加上 DNS 記錄即可（5–10 分鐘生效）

---

## 💰 費用預估（中小規模流量）

| 項目 | 費用 |
|---|---|
| Supabase 免費方案 | $0 — 500MB 儲存、50,000 月活躍用戶 |
| Vercel Hobby 方案 | $0 — 100GB 流量/月 |
| 網域（選配） | NT$400–700/年 |

🎯 **預估**：每月 1,000 位活躍會員以內可以完全免費運行。超過再升級即可。

---

## 🆘 常見問題

**Q: 驗證碼信沒收到？**
A: 檢查垃圾信件匣。Supabase 免費版每小時最多 3–4 封，超過會 rate limit。正式上線建議到 Authentication → SMTP Settings 接自家 SMTP（如 SendGrid 免費 100 封/天）。

**Q: 前台顯示「尚未設定 Supabase」？**
A: 表示 Step 5 沒做好，回去確認 `index.html` 的 URL 與 Key 是否正確替換。

**Q: 後台登入說「無管理員權限」？**
A: 確認您用的 email 是 `duck11230@gmail.com` 或 `boga20140614@gmail.com`。要新增管理員需要修改 `admin.html` 的 `ADMIN_EMAILS` 陣列，**並且**修改 `supabase-setup.sql` 裡的 `is_admin()` 函式，重新到 SQL Editor 執行。

**Q: 想要新增鞋款怎麼做？**
A: 後台 → 鞋款管理 → 點「＋ 新增鞋款」即可。不需要改程式。

**Q: 想改里程碑禮物？**
A: 後台 → 禮物里程碑 → 點「＋ 新增里程碑」或編輯現有的，前台會自動同步。

---

## 📁 檔案清單

```
.
├── index.html              ← 消費者前台（會員卡）
├── admin.html              ← 管理後台
├── supabase-setup.sql      ← 一次性執行的資料庫建表腳本
├── vercel.json             ← Vercel 部署設定
└── README.md               ← 本指南
```

有任何問題隨時問我，祝上線順利 🎉
