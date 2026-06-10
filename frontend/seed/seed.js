const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const now = admin.firestore.Timestamp.now();

// ============================================
// DATA MẪU — BEAUTY & GLOW COSMETICS STORE
// 5 sản phẩm mỗi danh mục × 4 danh mục = 20 sản phẩm
// ============================================

const categories = [
  { id: 'cat_skincare',    name: 'Dưỡng da (Skincare)',       slug: 'skincare',    icon: '🧴', order: 1, is_active: true },
  { id: 'cat_makeup',      name: 'Trang điểm (Makeup)',       slug: 'makeup',      icon: '💄', order: 2, is_active: true },
  { id: 'cat_perfume',     name: 'Nước hoa (Perfume)',        slug: 'perfume',     icon: '🧪', order: 3, is_active: true },
  { id: 'cat_accessories', name: 'Phụ kiện (Accessories)',    slug: 'accessories', icon: '🖌️', order: 4, is_active: true },
];

const storeLocations = [{
  id: 'store_district1',
  name: 'Beauty & Glow — District 1 Flagship',
  address: '456 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh',
  lat: 10.7740,
  lng: 106.7037,
  hotline: '+84 28 3823 1234',
  hours: '9:00 – 22:00 (Hàng ngày)',
  website: 'www.beautyglow.vn',
  is_active: true,
}];

// ============================================
// SKINCARE — 5 SẢN PHẨM
// ============================================
const skincareProducts = [
  {
    sku: 'BGL-LUM-VITC-50',
    name: 'Hydrating Glow Serum with Vitamin C',
    brand: 'LUMIÈRE',
    category: 'skincare',
    category_id: 'cat_skincare',
    emoji: '🧴',
    images: ['https://lh3.googleusercontent.com/aida-public/AB6AXuAl6toz-v7CAXXlDNyqA5Z8cdqj8yxUrmbRjfgV3yqOtfTJRpkG_PpQdeJ5FluqwjJ4GPE8jYJwPpQK_4_iAswHnF1ewb5_uHSnuj06eJPjn0bOQ_1X9Kx1erJkbu2bzg9hWT1vXTdPdys4o-MCl2BdpEYPrBql1ZVSPDOoyjtruzIcFxX3IlIYpY_1QZ11kL4P191LC0f4UFSKE4KoFEfXKIjqmlgFVgxozBkiRay3Q_2OaqiTgl3cxin4PBHW7elcDA-igRToY0Ki'],
    price: 1100000,
    sale_price: 0,
    rating: 4.8,
    review_count: 234,
    description: 'Serum dưỡng ẩm làm sáng da cao cấp với Vitamin C và chiết xuất thảo mộc hữu cơ. Thấm sâu giúp làn da luôn căng bóng, rạng rỡ tự nhiên.',
    specs: {
      volume: '50ml',
      origin: 'Pháp (France)',
      skin_type: 'Mọi loại da, đặc biệt là da xỉn màu',
      key_ingredients: 'Vitamin C, Hyaluronic Acid, Rose Gold extract',
      usage: 'Thoa 2-3 giọt mỗi buổi sáng và tối trước khi bôi kem dưỡng.'
    },
    stock: 100,
    is_active: true,
    tags: ['new', 'best_seller'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-PUR-FACE-ROSE',
    name: 'Botanical Face Oil with Rosehip',
    brand: 'PURE',
    category: 'skincare',
    category_id: 'cat_skincare',
    emoji: '🌹',
    images: ['https://lh3.googleusercontent.com/aida-public/AB6AXuARszt-FUFQlfMvC5doKc68gBOa9p11CB6Ov43oFqjopw8VgYIGB3Js_qSECPtOX5WQ9MOwLLqq3afqwT-mXhgjhpdAwz9Iaxe8N9f_R9hyXdXyyvOWbuOf7Q1Gk2-vdYCd9y3UdjBbUKsaGJS-GHfPjs1ZxDOC8B2Qz-15vyezO4Y9WPUMATsBbkXKZFSQ0uePtM5mJCwPSdyjk3Vd_hknWX1_h4hxWqu3eh7hjJo5bnf-ErIg4Oth8tDMHXHSKQYyeQC-rslcMpK0'],
    price: 1300000,
    sale_price: 0,
    rating: 4.7,
    review_count: 188,
    description: 'Dầu dưỡng da chiết xuất hạt tầm xuân hữu cơ giúp làm dịu, tái tạo và nuôi dưỡng làn da khô ráp, mang lại vẻ mềm mại tự nhiên.',
    specs: {
      volume: '30ml',
      ingredients: '100% Organic Rosehip Seed Oil',
      benefits: 'Giảm thâm sạm, dưỡng ẩm sâu, mờ vết nhăn li ti',
      origin: 'Úc (Australia)',
      usage: 'Massage 2-3 giọt lên mặt ẩm sau bước serum.'
    },
    stock: 60,
    is_active: true,
    tags: ['best_seller'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-SKN-RETINOL-30',
    name: 'Retinol Night Repair Cream',
    brand: 'LUMIÈRE',
    category: 'skincare',
    category_id: 'cat_skincare',
    emoji: '🌙',
    images: ['https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400'],
    price: 1650000,
    sale_price: 1320000,
    rating: 4.9,
    review_count: 312,
    description: 'Kem dưỡng ban đêm chứa Retinol 0.3% kết hợp Peptide và Niacinamide giúp tái tạo tế bào da, giảm nếp nhăn và sạm nám hiệu quả sau 4 tuần.',
    specs: {
      volume: '50ml',
      active: 'Retinol 0.3% + Peptide Complex + Niacinamide 5%',
      skin_type: 'Da lão hóa, da có nếp nhăn, da sạm nám',
      origin: 'Hàn Quốc (Korea)',
      usage: 'Thoa đều lên mặt sau khi rửa mặt buổi tối. Dùng kem chống nắng vào ban ngày.'
    },
    stock: 75,
    is_active: true,
    tags: ['best_seller', 'sale'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-SKN-SUNSCREEN-SPF50',
    name: 'Invisible Shield SPF50+ PA++++',
    brand: 'SHIELD',
    category: 'skincare',
    category_id: 'cat_skincare',
    emoji: '☀️',
    images: ['https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400'],
    price: 620000,
    sale_price: 0,
    rating: 4.6,
    review_count: 521,
    description: 'Kem chống nắng vật lý SPF50+ PA++++ không gây bít lỗ chân lông, phù hợp mọi loại da kể cả da nhạy cảm. Bảo vệ toàn diện chống UVA, UVB và ánh sáng xanh.',
    specs: {
      volume: '60ml',
      spf: 'SPF50+ PA++++',
      texture: 'Kết cấu gel nhẹ, thấm nhanh không bóng nhờn',
      skin_type: 'Mọi loại da',
      origin: 'Nhật Bản (Japan)'
    },
    stock: 200,
    is_active: true,
    tags: ['new', 'best_seller'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-SKN-TONER-HA',
    name: 'Hyaluronic Acid Hydra-Boost Toner',
    brand: 'PURE',
    category: 'skincare',
    category_id: 'cat_skincare',
    emoji: '💧',
    images: ['https://images.unsplash.com/photo-1612817288484-6f916006741a?w=400'],
    price: 780000,
    sale_price: 650000,
    rating: 4.5,
    review_count: 167,
    description: 'Toner dưỡng ẩm chuyên sâu với Hyaluronic Acid 3 cấp độ phân tử giúp căng mọng, cấp nước tức thì và duy trì độ ẩm lên đến 72 giờ.',
    specs: {
      volume: '150ml',
      key_ingredients: 'Triple Hyaluronic Acid, Centella Asiatica, Panthenol',
      skin_type: 'Da khô, da mất nước, da nhạy cảm',
      origin: 'Hàn Quốc (Korea)',
      usage: 'Thoa sau rửa mặt, trước serum và kem dưỡng.'
    },
    stock: 90,
    is_active: true,
    tags: ['sale'],
    created_at: now,
    updated_at: now,
  },
];

// ============================================
// MAKEUP — 5 SẢN PHẨM
// ============================================
const makeupProducts = [
  {
    sku: 'BGL-ESE-MATTE-RP',
    name: 'Velvet Matte Lipstick - Rose Petal',
    brand: 'ESENCE',
    category: 'makeup',
    category_id: 'cat_makeup',
    emoji: '💄',
    images: ['https://lh3.googleusercontent.com/aida-public/AB6AXuCdhNHpJUkBV9BBn5NV8MnMBik6hKdqstBR-Q6YFjNAHSxgG_0ksF6kfW7ixmefNPiTew2HW2NPPELK88sL99qCwaYK1A33I7Ju4RN6cD3BG5MAFNJVt1Mo6iMQGp0S5KYrUKckd-PrSwAKATiuVB-Wt25vdTvO2mCBqlIFj8S1XZKV0a8SfSd1Xt25qd1JP0Ek5RzSojc_Nodpk2UEl3KgpuJRX-7s0a2UvS5I4M1ikB07oietUwUHfHkWRahhRnqG82nVMzUwmU_Q'],
    price: 750000,
    sale_price: 550000,
    rating: 4.7,
    review_count: 298,
    description: 'Son lì mịn mượt như nhung tông màu Cánh Hồng Khô (Rose Petal) thời thượng. Không gây khô môi, giữ màu lâu trôi lên đến 8 giờ.',
    specs: {
      weight: '3.5g',
      finish: 'Matte (Lì mịn)',
      shade: 'Rose Petal (Hồng cánh hoa)',
      features: 'Chứa dưỡng chất từ dầu Jojoba và Vitamin E nuôi dưỡng môi',
      origin: 'Ý (Italy)'
    },
    stock: 120,
    is_active: true,
    tags: ['best_seller', 'sale'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-LUM-EYEPAL-CE',
    name: 'Celestial Glow Eyeshadow Palette',
    brand: 'LUMIÈRE',
    category: 'makeup',
    category_id: 'cat_makeup',
    emoji: '🎨',
    images: ['https://lh3.googleusercontent.com/aida-public/AB6AXuCDejDysTFdoF7GeNd2gaeSB5zUlRWyr89XXVK-rc7q3u46miQePR7RijuzA8CEMEQwOccoch1mhyfCEMY6t1w_wqg7G1LrSLdI5oD0-xM_28U61zmPRC7UEc_I2OQML-kOgiF8SDQX-lNUEQep2bzUpVr4U3w91dYNzRObQ2Q0F_Fz7CaIcUJJ7B42KS3bPcvAPVXYjWX9eCALJO9dm5Iano6uomePbU2BkTeG1j2HaYifd_28K-L7vdWSUayU2H8aeO1tzg6Q6pu_'],
    price: 1480000,
    sale_price: 0,
    rating: 4.8,
    review_count: 143,
    description: 'Bảng phấn mắt 12 màu sang trọng kết hợp các tông màu lì ấm áp và màu nhũ lấp lánh lung linh giúp đôi mắt cuốn hút rạng rỡ suốt ngày dài.',
    specs: {
      shades: '12 màu đa dạng (Lì & Nhũ lấp lánh)',
      finish: 'Matte & Shimmer',
      weight: '15g',
      features: 'Phấn mịn dễ tán, lên màu chuẩn và lâu trôi'
    },
    stock: 50,
    is_active: true,
    tags: ['new'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-MKP-FOUNDATION-N20',
    name: 'Glow Skin Tint Foundation SPF20',
    brand: 'ESENCE',
    category: 'makeup',
    category_id: 'cat_makeup',
    emoji: '✨',
    images: ['https://images.unsplash.com/photo-1586495777744-4e6232bf2604?w=400'],
    price: 920000,
    sale_price: 0,
    rating: 4.6,
    review_count: 210,
    description: 'Kem nền mỏng nhẹ SPF20 che phủ tự nhiên, tạo lớp nền căng mịn như da thật. Công thức kết hợp serum dưỡng ẩm giúp da luôn rạng rỡ suốt 12 giờ.',
    specs: {
      volume: '30ml',
      coverage: 'Che phủ vừa đến cao',
      spf: 'SPF20 PA++',
      shades: '15 tông màu phù hợp mọi làn da',
      finish: 'Satin (Bán lì bóng mịn)',
      origin: 'Hàn Quốc (Korea)'
    },
    stock: 85,
    is_active: true,
    tags: ['new', 'best_seller'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-MKP-BLUSH-CORAL',
    name: 'Glow Blush & Highlighter Duo - Coral Sunset',
    brand: 'ARTISTRY',
    category: 'makeup',
    category_id: 'cat_makeup',
    emoji: '🌅',
    images: ['https://images.unsplash.com/photo-1631730486784-74757f03c3b5?w=400'],
    price: 680000,
    sale_price: 540000,
    rating: 4.5,
    review_count: 97,
    description: 'Bộ đôi phấn má hồng và highlight tông Coral Sunset tạo nên làn da căng bóng tự nhiên, ửng hồng rạng rỡ. Dạng phấn mịn dễ tán, phù hợp dùng hàng ngày.',
    specs: {
      weight: '8g (4g phấn má + 4g highlight)',
      finish: 'Satin Glow',
      shade: 'Coral Sunset',
      skin_type: 'Mọi loại da'
    },
    stock: 65,
    is_active: true,
    tags: ['sale'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-MKP-MASCARA-VOL',
    name: 'Volume & Curl Waterproof Mascara',
    brand: 'ESENCE',
    category: 'makeup',
    category_id: 'cat_makeup',
    emoji: '👁️',
    images: ['https://images.unsplash.com/photo-1512207736890-6ffed8a84e8d?w=400'],
    price: 450000,
    sale_price: 0,
    rating: 4.4,
    review_count: 389,
    description: 'Mascara chống nước kép vừa tạo độ dày vừa uốn cong mi tự nhiên. Công thức đặc biệt không vón cục, dễ tán và tẩy sạch bằng nước tẩy trang dịu nhẹ.',
    specs: {
      volume: '10ml',
      features: 'Chống nước, không vón cục, uốn cong mi',
      brush: 'Cọ mascara siêu mảnh tiếp cận tới từng sợi mi',
      origin: 'Pháp (France)'
    },
    stock: 150,
    is_active: true,
    tags: ['best_seller'],
    created_at: now,
    updated_at: now,
  },
];

// ============================================
// PERFUME — 5 SẢN PHẨM
// ============================================
const perfumeProducts = [
  {
    sku: 'BGL-AUR-EDP-MJ100',
    name: 'Eau de Parfum - Midnight Jasmine',
    brand: 'AURUM',
    category: 'perfume',
    category_id: 'cat_perfume',
    emoji: '🧪',
    images: ['https://lh3.googleusercontent.com/aida-public/AB6AXuDI03yw5mSW3S3GXeMoF66s67XyOi1zoNMWx7eoKT_bbz8uIrQsKQU9oUTqeaFNBvH4ZelB98u_w-Ufkf2w0WKLBG02PAz86jcCmdD9alLSxCvpzB587sSvLVLRBYJSnulntVlRNWWpBoywMDIIiGklAnUw8oZNdAHiF4P0jFq_pMXikJFZk4Wk08gIHgiSjcMeh37bg7wnwA4XmE-36FidSYp7LOaEca3bE5pD2C--7oR0PJVy42VZx189qDEQ_em-2bsKaJ3ypuxJ'],
    price: 2800000,
    sale_price: 0,
    rating: 4.9,
    review_count: 156,
    description: 'Nước hoa cao cấp hương Hoa Lài Đêm huyền bí và sang trọng. Nốt hương nồng ấm quyến rũ thích hợp cho các buổi tiệc tối thanh lịch.',
    specs: {
      volume: '100ml',
      concentration: 'Eau de Parfum (EDP)',
      scent_family: 'Floral Woody (Hương hoa và gỗ ấm)',
      notes: 'Hương đầu: Cam Bergamot. Hương giữa: Hoa lài đêm. Hương cuối: Gỗ đàn hương, Hổ phách',
      longevity: '6 - 8 giờ'
    },
    stock: 35,
    is_active: true,
    tags: ['new'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-AUR-EDT-RG50',
    name: 'Eau de Toilette - Rose Garden',
    brand: 'AURUM',
    category: 'perfume',
    category_id: 'cat_perfume',
    emoji: '🌹',
    images: ['https://images.unsplash.com/photo-1541643600914-78b084683702?w=400'],
    price: 1650000,
    sale_price: 1350000,
    rating: 4.6,
    review_count: 203,
    description: 'Nước hoa nhẹ nhàng tinh tế hương Vườn Hoa Hồng — sự kết hợp tuyệt vời giữa hoa hồng tươi mát, mẫu đơn và gỗ tuyết tùng ấm áp. Thích hợp dùng hàng ngày.',
    specs: {
      volume: '50ml',
      concentration: 'Eau de Toilette (EDT)',
      scent_family: 'Floral (Hương hoa)',
      notes: 'Hương đầu: Chanh, Cam. Hương giữa: Hoa hồng, Mẫu đơn. Hương cuối: Tuyết tùng, Xạ hương',
      longevity: '4 - 5 giờ'
    },
    stock: 48,
    is_active: true,
    tags: ['best_seller', 'sale'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-ORR-EDP-OUD-75',
    name: 'Oud & Amber Intense EDP',
    brand: 'ORRIENT',
    category: 'perfume',
    category_id: 'cat_perfume',
    emoji: '🏺',
    images: ['https://images.unsplash.com/photo-1564460576398-ef55d99548b2?w=400'],
    price: 3500000,
    sale_price: 0,
    rating: 4.8,
    review_count: 89,
    description: 'Nước hoa Oriental cao cấp với gỗ Oud Trung Đông và Hổ Phách hòa quyện, tạo nên mùi hương quyến rũ, mạnh mẽ và sang trọng — dành cho những ai yêu hương gỗ ấm.',
    specs: {
      volume: '75ml',
      concentration: 'Eau de Parfum Intense',
      scent_family: 'Oriental Woody (Gỗ phương Đông)',
      notes: 'Hương đầu: Saffron, Gừng. Hương giữa: Hoa lài, Gỗ oud. Hương cuối: Hổ phách, Vani, Xạ hương',
      longevity: '8 - 12 giờ'
    },
    stock: 22,
    is_active: true,
    tags: ['new'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-FRE-EDT-OCEAN-100',
    name: 'Fresh Ocean Breeze EDT',
    brand: 'FREESIA',
    category: 'perfume',
    category_id: 'cat_perfume',
    emoji: '🌊',
    images: ['https://images.unsplash.com/photo-1590736969955-71cc94901144?w=400'],
    price: 1200000,
    sale_price: 0,
    rating: 4.4,
    review_count: 176,
    description: 'Nước hoa tươi mát hương biển cả xanh trong — cảm giác trong trẻo như làn gió đại dương. Phù hợp đi học, đi làm hay dạo phố hàng ngày.',
    specs: {
      volume: '100ml',
      concentration: 'Eau de Toilette (EDT)',
      scent_family: 'Aquatic Fresh (Hương biển tươi mát)',
      notes: 'Hương đầu: Cam, Bạc hà. Hương giữa: Hoa trắng, Muối biển. Hương cuối: Gỗ xám, Xạ hương',
      longevity: '4 - 6 giờ'
    },
    stock: 70,
    is_active: true,
    tags: ['best_seller'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-AUR-MIST-VANILLA-200',
    name: 'Sweet Vanilla Body Mist',
    brand: 'AURUM',
    category: 'perfume',
    category_id: 'cat_perfume',
    emoji: '🍦',
    images: ['https://images.unsplash.com/photo-1547887538-e3a2f32cb1cc?w=400'],
    price: 480000,
    sale_price: 380000,
    rating: 4.3,
    review_count: 342,
    description: 'Xịt thơm toàn thân hương Vani ngọt ngào dịu dàng — nhẹ nhàng, dễ chịu và không gây kích ứng da. Hoàn hảo để mang theo và xịt lại suốt ngày.',
    specs: {
      volume: '200ml',
      concentration: 'Body Mist',
      scent_family: 'Gourmand (Hương ngọt)',
      notes: 'Hương Vani, Đường nâu, Hoa nhài nhẹ',
      longevity: '2 - 3 giờ'
    },
    stock: 110,
    is_active: true,
    tags: ['sale'],
    created_at: now,
    updated_at: now,
  },
];

// ============================================
// ACCESSORIES — 5 SẢN PHẨM
// ============================================
const accessoriesProducts = [
  {
    sku: 'BGL-ART-BRUSH-5P',
    name: 'Essential Brush Set (5 Piece)',
    brand: 'ARTISTRY',
    category: 'accessories',
    category_id: 'cat_accessories',
    emoji: '🖌️',
    images: ['https://lh3.googleusercontent.com/aida-public/AB6AXuCaP5mIKfHig-y3yfUXBpIs8y9qnz9NII-3zXstjUs0WF_6umnUmz8hSo5JlFJvH0pP6IBZaco24HgZKMGfUy1hM_W62ZvavTBI4LFqcHiIjDC5VUvb2bUVJAxNR81TRVHg7K0LPClUNBkCmrpghqM5BH40dpY-nn06UEBJZ0EufH7jsT_FrL3y2794HRRlDJZAb-clWM1zU0vzfdfKdY-z-BwSZB0fNoz9PETHe66QZ0Hn4ARbcgcb_BlBqTe_Vw3O0307uZldB2_F'],
    price: 1050000,
    sale_price: 880000,
    rating: 4.7,
    review_count: 124,
    description: 'Bộ cọ trang điểm thiết yếu 5 món với lông cọ nhân tạo siêu mềm mịn và cổ cọ mạ vàng hồng (Rose Gold) sang chảnh đi kèm bao da tiện dụng.',
    specs: {
      count: '5 cây cọ trang điểm chuyên dụng',
      material: 'Sợi nhân tạo mềm mại thuần chay, thân gỗ cao cấp',
      includes: 'Cọ phấn phủ, cọ má hồng, cọ tán nền, cọ bầu mắt, cọ kẻ viền',
      clean: 'Rửa định kỳ bằng dung dịch giặt cọ chuyên dụng'
    },
    stock: 80,
    is_active: true,
    tags: ['best_seller', 'sale'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-ACC-LASHCURL-RG',
    name: 'Rose Gold Lash Curler Pro',
    brand: 'ARTISTRY',
    category: 'accessories',
    category_id: 'cat_accessories',
    emoji: '✂️',
    images: ['https://images.unsplash.com/photo-1522338242992-e1a54906a8da?w=400'],
    price: 320000,
    sale_price: 0,
    rating: 4.5,
    review_count: 214,
    description: 'Kẹp mi màu Rose Gold sang trọng với lực bấm êm ái, uốn cong mi tự nhiên và không gây gãy mi. Đệm silicon thay thế được, bền bỉ theo thời gian.',
    specs: {
      material: 'Thép không gỉ mạ Rose Gold + Đệm silicon y tế',
      pad: 'Kèm 2 miếng đệm silicon thay thế',
      design: 'Ergonomic — phù hợp mọi hình dáng mắt',
      features: 'Uốn cong nhanh, không cần nhiệt'
    },
    stock: 120,
    is_active: true,
    tags: ['new'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-ACC-MIRROR-FOLD',
    name: 'Foldable LED Vanity Mirror',
    brand: 'GLOWUP',
    category: 'accessories',
    category_id: 'cat_accessories',
    emoji: '🪞',
    images: ['https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400'],
    price: 850000,
    sale_price: 720000,
    rating: 4.6,
    review_count: 91,
    description: 'Gương trang điểm LED gấp gọn 3 chế độ ánh sáng (Ấm / Tự nhiên / Lạnh) với độ phóng đại 1x và 10x. Pin sạc USB tiện lợi, hoàn hảo để mang theo.',
    specs: {
      size: '20cm × 15cm (gập lại được)',
      magnification: '1x & 10x',
      light: '3 chế độ: Ấm, Tự nhiên, Lạnh',
      battery: 'Pin Li-ion sạc USB-C 2000mAh',
      features: 'Đèn LED không gây hại mắt, 36 bóng LED'
    },
    stock: 55,
    is_active: true,
    tags: ['new', 'sale'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-ACC-SKINROLLER-JA',
    name: 'Jade Roller & Gua Sha Set',
    brand: 'PURE',
    category: 'accessories',
    category_id: 'cat_accessories',
    emoji: '💎',
    images: ['https://images.unsplash.com/photo-1583241800698-e8ab01830a24?w=400'],
    price: 560000,
    sale_price: 0,
    rating: 4.4,
    review_count: 178,
    description: 'Bộ lăn mặt đá Jade và cạo gua sha tự nhiên giúp kích thích tuần hoàn máu, giảm phù nề, thông kinh lạc và hỗ trợ hấp thu serum hiệu quả hơn.',
    specs: {
      material: '100% Đá Jade tự nhiên + Tay cầm thép không gỉ',
      includes: '1 Jade Roller 2 đầu + 1 Gua Sha bướm',
      benefits: 'Giảm phù, thon gọn mặt, hỗ trợ hấp thu dưỡng chất',
      usage: 'Làm lạnh đá trước khi dùng để tăng hiệu quả'
    },
    stock: 95,
    is_active: true,
    tags: ['best_seller'],
    created_at: now,
    updated_at: now,
  },
  {
    sku: 'BGL-ACC-ORGANIZER-PK',
    name: 'Acrylic Makeup Organizer (12-Grid)',
    brand: 'GLOWUP',
    category: 'accessories',
    category_id: 'cat_accessories',
    emoji: '🗂️',
    images: ['https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=400'],
    price: 420000,
    sale_price: 350000,
    rating: 4.3,
    review_count: 263,
    description: 'Kệ đựng mỹ phẩm mica trong suốt 12 ngăn sang trọng — sắp xếp son môi, serum, kem dưỡng và phụ kiện ngăn nắp gọn gàng trên bàn trang điểm.',
    specs: {
      material: 'Mica acrylic cao cấp dày 3mm',
      size: '20cm × 20cm × 15cm',
      compartments: '12 ngăn (6 ngăn đứng + 6 ngăn ngang)',
      features: 'Chịu nước, dễ vệ sinh, không phai màu'
    },
    stock: 75,
    is_active: true,
    tags: ['sale'],
    created_at: now,
    updated_at: now,
  },
];

// Gộp tất cả sản phẩm
const products = [
  ...skincareProducts,
  ...makeupProducts,
  ...perfumeProducts,
  ...accessoriesProducts,
];

// ============================================
// HÀM SEED
// ============================================

async function deleteCollection(name) {
  const snap = await db.collection(name).get();
  if (snap.empty) return;
  const batch = db.batch();
  snap.docs.forEach(doc => batch.delete(doc.ref));
  await batch.commit();
  console.log(`  🧹 Đã xóa ${snap.size} docs trong '${name}'`);
}

async function seedCol(name, data, customId = false) {
  console.log(`Seeding ${name}...`);
  // Firestore batch limit = 500 docs, chia nhỏ nếu cần
  const chunkSize = 400;
  for (let i = 0; i < data.length; i += chunkSize) {
    const chunk = data.slice(i, i + chunkSize);
    const batch = db.batch();
    chunk.forEach(doc => {
      const ref = customId
        ? db.collection(name).doc(doc.id)
        : db.collection(name).doc();
      batch.set(ref, doc);
    });
    await batch.commit();
  }
  console.log(`  ✅ ${data.length} docs → '${name}'`);
}

async function main() {
  console.log('🌸 Bắt đầu dọn dẹp và seed data Beauty & Glow Cosmetics...\n');

  // Xóa data cũ
  console.log('Đang xóa collections cũ...');
  await deleteCollection('categories');
  await deleteCollection('store_locations');
  await deleteCollection('products');

  // Seed mới
  console.log('\nĐang seed data mới...');
  await seedCol('categories',      categories,     true);
  await seedCol('store_locations', storeLocations, true);
  await seedCol('products',        products,       false);

  console.log(`
✅ HOÀN TẤT! Đã seed ${products.length} sản phẩm:
   • Skincare (Dưỡng da): ${skincareProducts.length} sản phẩm
   • Makeup (Trang điểm): ${makeupProducts.length} sản phẩm
   • Perfume (Nước hoa):  ${perfumeProducts.length} sản phẩm
   • Accessories (Phụ kiện): ${accessoriesProducts.length} sản phẩm
  `);
  process.exit(0);
}

main().catch(err => {
  console.error('❌ Lỗi:', err);
  process.exit(1);
});