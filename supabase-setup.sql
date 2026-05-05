-- ============================================================
-- BOGA Shoe Collection · 資料庫建立腳本
-- 使用方式：複製整份內容，貼到 Supabase SQL Editor → 點 Run
-- 重複執行也不會出錯（已存在會自動跳過）
-- ============================================================

-- 砍掉舊的（如果有的話），全部重建
DROP TABLE IF EXISTS stamps CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP TABLE IF EXISTS shoes CASCADE;

-- 鞋款表
CREATE TABLE shoes (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  sku TEXT,
  emoji TEXT DEFAULT '👠',
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 會員表
CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  stamp_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_profiles_email ON profiles (email);

-- 集章表
CREATE TABLE stamps (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  shoe_id INT REFERENCES shoes(id) ON DELETE CASCADE,
  order_number TEXT NOT NULL,
  photo_url TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 預設 12 款鞋
INSERT INTO shoes (name, sku, emoji) VALUES
  ('Noir Classic', 'BG-001', '👠'),
  ('Rose Nude',    'BG-002', '👠'),
  ('Ivory Sling',  'BG-003', '👡'),
  ('Black Ankle',  'BG-004', '👢'),
  ('Caramel Mule', 'BG-005', '👠'),
  ('Cherry Pump',  'BG-006', '👡'),
  ('Sand Kitten',  'BG-007', '👠'),
  ('Onyx Block',   'BG-008', '👢'),
  ('Milk Strap',   'BG-009', '👡'),
  ('Plum Heel',    'BG-010', '👠'),
  ('Rust Square',  'BG-011', '👡'),
  ('Snow Mule',    'BG-012', '👠');

-- 開啟 RLS 並設成「全開」（demo 階段，安全靠後台審核訂單把關）
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE stamps   ENABLE ROW LEVEL SECURITY;
ALTER TABLE shoes    ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_open" ON profiles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "stamps_open"   ON stamps   FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "shoes_open"    ON shoes    FOR ALL USING (true) WITH CHECK (true);

-- Realtime（重複執行不報錯）
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE stamps;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ✅ 完成！請到 Storage 手動建立兩個 public bucket：stamp-photos / shoe-images
