-- House Finder — recommended SQL schema (AI-ready)

CREATE TABLE users (
  user_id TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('seeker', 'owner', 'admin')),
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE admins (
  admin_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(user_id),
  permissions TEXT
);

CREATE TABLE categories (
  category_id TEXT PRIMARY KEY,
  name TEXT UNIQUE NOT NULL
);

CREATE TABLE houses (
  house_id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL REFERENCES users(user_id),
  title TEXT NOT NULL,
  description TEXT,
  price REAL NOT NULL,
  town TEXT NOT NULL,
  county TEXT NOT NULL,
  address TEXT NOT NULL,
  area TEXT,
  latitude REAL,
  longitude REAL,
  house_type TEXT,
  category TEXT,
  bedrooms INTEGER,
  bathrooms INTEGER,
  parking INTEGER DEFAULT 0,
  security TEXT,
  furnished INTEGER DEFAULT 0,
  water INTEGER DEFAULT 1,
  electricity INTEGER DEFAULT 1,
  wifi INTEGER DEFAULT 0,
  cctv INTEGER DEFAULT 0,
  garden INTEGER DEFAULT 0,
  balcony INTEGER DEFAULT 0,
  gated_compound INTEGER DEFAULT 0,
  pet_friendly INTEGER DEFAULT 0,
  family_friendly INTEGER DEFAULT 0,
  nearby_schools INTEGER DEFAULT 0,
  nearby_hospitals INTEGER DEFAULT 0,
  nearby_shopping INTEGER DEFAULT 0,
  public_transport INTEGER DEFAULT 0,
  religious_facility INTEGER DEFAULT 0,
  availability TEXT DEFAULT 'available',
  owner_name TEXT,
  owner_phone TEXT,
  owner_email TEXT,
  amenities TEXT,
  approved INTEGER DEFAULT 0,
  reported INTEGER DEFAULT 0,
  report_reason TEXT,
  view_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE house_images (
  image_id TEXT PRIMARY KEY,
  house_id TEXT NOT NULL REFERENCES houses(house_id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0
);

CREATE TABLE user_preferences (
  preference_id TEXT PRIMARY KEY,
  user_id TEXT UNIQUE NOT NULL REFERENCES users(user_id),
  preferred_location TEXT,
  preferred_area TEXT,
  minimum_budget REAL,
  maximum_budget REAL,
  house_type TEXT,
  bedrooms INTEGER,
  bathrooms INTEGER,
  maximum_distance REAL,
  parking INTEGER,
  security TEXT,
  furnished INTEGER,
  water INTEGER DEFAULT 0,
  electricity INTEGER DEFAULT 0,
  wifi INTEGER DEFAULT 0,
  cctv INTEGER DEFAULT 0,
  gated_compound INTEGER DEFAULT 0,
  nearby_schools INTEGER DEFAULT 0,
  nearby_hospitals INTEGER DEFAULT 0,
  nearby_shopping INTEGER DEFAULT 0,
  public_transport INTEGER DEFAULT 0,
  religious_facility INTEGER DEFAULT 0
);

CREATE TABLE favorites (
  favorite_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(user_id),
  house_id TEXT NOT NULL REFERENCES houses(house_id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, house_id)
);

CREATE TABLE user_interactions (
  interaction_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(user_id),
  house_id TEXT REFERENCES houses(house_id) ON DELETE SET NULL,
  interaction_type TEXT NOT NULL CHECK (
    interaction_type IN (
      'view', 'inquiry', 'favorite', 'unfavorite',
      'search', 'call', 'whatsapp'
    )
  ),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE search_history (
  search_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(user_id),
  query TEXT NOT NULL,
  location TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE inquiries (
  inquiry_id TEXT PRIMARY KEY,
  house_id TEXT NOT NULL REFERENCES houses(house_id) ON DELETE CASCADE,
  seeker_id TEXT NOT NULL REFERENCES users(user_id),
  message TEXT NOT NULL,
  status TEXT DEFAULT 'open',
  owner_reply TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  replied_at TIMESTAMP
);

CREATE TABLE notifications (
  notification_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(user_id),
  title TEXT NOT NULL,
  body TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read_flag INTEGER DEFAULT 0
);
