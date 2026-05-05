-- ============================================================
-- BOGA Shoe Collection — Supabase 資料庫建立腳本
-- 使用方式：複製整份內容，貼到 Supabase Dashboard → SQL Editor → Run
-- ============================================================

-- ─── 鞋款資料表 ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS shoes (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  sku TEXT,
  emoji TEXT DEFAULT '👠',
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── 會員資料表 ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  email TEXT,
  stamp_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── 集章紀錄 ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS stamps (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  shoe_id INT REFERENCES shoes(id) ON DELETE CASCADE,
  order_number TEXT NOT NULL,
  photo_url TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── 初始鞋款（之後可在後台改） ─────────────────────────────
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
  ('Snow Mule',    'BG-012', '👠')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 管理員判定函式（兩位管理員 email 寫死於此）
-- 之後若要新增管理員，修改這裡的 email 列表即可
-- ============================================================
CREATE OR REPLACE FUNCTION is_admin() RETURNS BOOLEAN AS $$
  SELECT (auth.jwt() ->> 'email') IN (
    'duck11230@gmail.com',
    'boga20140614@gmail.com'
  );
$$ LANGUAGE SQL STABLE;

-- ============================================================
-- Row Level Security
-- ============================================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE stamps   ENABLE ROW LEVEL SECURITY;
ALTER TABLE shoes    ENABLE ROW LEVEL SECURITY;

-- shoes：所有人可讀；僅管理員可寫
DROP POLICY IF EXISTS "shoes_read_all" ON shoes;
CREATE POLICY "shoes_read_all" ON shoes FOR SELECT USING (true);

DROP POLICY IF EXISTS "shoes_admin_write" ON shoes;
CREATE POLICY "shoes_admin_write" ON shoes FOR ALL
  USING (is_admin()) WITH CHECK (is_admin());

-- profiles：自己讀寫；管理員可讀全部
DROP POLICY IF EXISTS "profiles_self_read" ON profiles;
CREATE POLICY "profiles_self_read" ON profiles FOR SELECT
  USING (auth.uid() = id OR is_admin());

DROP POLICY IF EXISTS "profiles_self_update" ON profiles;
CREATE POLICY "profiles_self_update" ON profiles FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_self_insert" ON profiles;
CREATE POLICY "profiles_self_insert" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- stamps：使用者讀寫自己的；管理員可讀寫全部（審核通過/退件）
DROP POLICY IF EXISTS "stamps_self_read" ON stamps;
CREATE POLICY "stamps_self_read" ON stamps FOR SELECT
  USING (auth.uid() = user_id OR is_admin());

DROP POLICY IF EXISTS "stamps_self_insert" ON stamps;
CREATE POLICY "stamps_self_insert" ON stamps FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "stamps_admin_update" ON stamps;
CREATE POLICY "stamps_admin_update" ON stamps FOR UPDATE
  USING (auth.uid() = user_id OR is_admin());

-- ============================================================
-- Realtime（讓前台能即時收到審核結果）
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE stamps;

-- ============================================================
-- 註冊時自動建立 profile
-- ============================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name', NEW.email)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- Storage Bucket：請手動到 Dashboard → Storage 建立兩個 public bucket：
--   1. stamp-photos
--   2. shoe-images
-- ============================================================
