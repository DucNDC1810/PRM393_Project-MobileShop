const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const now = admin.firestore.Timestamp.now();

// ============================================
// DATA MẪU — BEAUTY & GLOW COSMETICS STORE
// ============================================

const categories = [
  { id: 'cat_skincare', name: 'Dưỡng da (Skincare)', slug: 'skincare', icon: '🧴', order: 1, is_active: true },
  { id: 'cat_makeup', name: 'Trang điểm (Makeup)', slug: 'makeup', icon: '💄', order: 2, is_active: true },
  { id: 'cat_perfume', name: 'Nước hoa (Perfume)', slug: 'perfume', icon: '🧪', order: 3, is_active: true },
  { id: 'cat_accessories', name: 'Phụ kiện (Accessories)', slug: 'accessories', icon: '🖌️', order: 4, is_active: true },
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

const products = [
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
    sku: 'BGL-ESE-MATTE-RP',
    name: 'Velvet Matte Lipstick - Rose Petal',
    brand: 'ESENCE',
    category: 'makeup',
    category_id: 'cat_makeup',
    emoji: '💄',
    images: ['https://lh3.googleusercontent.com/aida-public/AB6AXuCdhNHpJUkBV9BBn5NV8MnMBik6hKdqstBR-Q6YFjNAHSxgG_0ksF6kfW7ixmefNPiTew2HW2NPPELK88sL99qCwaYK1A33I7Ju4RN6cD3BG5MAFNJVt1Mo6iMQGp0S5KYrUKckd-PrSwAKATiuVB-Wt25vdTvO2mCBqlIFj8S1XZKV0a8SfSd1Xt25qd1JP0Ek5RzSojc_Nodpk2UEl3KgpuJRX-7s0a2UvS5I4M1ikB07oietUwUHfHkWRahhRnqG82nVMzUwmU_Q'],
    price: 750000,
    sale_price: 550000,
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
    tags: ['best_seller'],
    created_at: now,
    updated_at: now,
  },
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
    sku: 'BGL-PUR-FACE-ROSE',
    name: 'Botanical Face Oil with Rosehip',
    brand: 'PURE',
    category: 'skincare',
    category_id: 'cat_skincare',
    emoji: '🧴',
    images: ['https://lh3.googleusercontent.com/aida-public/AB6AXuARszt-FUFQlfMvC5doKc68gBOa9p11CB6Ov43oFqjopw8VgYIGB3Js_qSECPtOX5WQ9MOwLLqq3afqwT-mXhgjhpdAwz9Iaxe8N9f_R9hyXdXyyvOWbuOf7Q1Gk2-vdYCd9y3UdjBbUKsaGJS-GHfPjs1ZxDOC8B2Qz-15vyezO4Y9WPUMATsBbkXKZFSQ0uePtM5mJCwPSdyjk3Vd_hknWX1_h4hxWqu3eh7hjJo5bnf-ErIg4Oth8tDMHXHSKQYyeQC-rslcMpK0'],
    price: 1300000,
    sale_price: 0,
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
    sku: 'BGL-ART-BRUSH-5P',
    name: 'Essential Brush Set (5 Piece)',
    brand: 'ARTISTRY',
    category: 'accessories',
    category_id: 'cat_accessories',
    emoji: '🖌️',
    images: ['https://lh3.googleusercontent.com/aida-public/AB6AXuCaP5mIKfHig-y3yfUXBpIs8y9qnz9NII-3zXstjUs0WF_6umnUmz8hSo5JlFJvH0pP6IBZaco24HgZKMGfUy1hM_W62ZvavTBI4LFqcHiIjDC5VUvb2bUVJAxNR81TRVHg7K0LPClUNBkCmrpghqM5BH40dpY-nn06UEBJZ0EufH7jsT_FrL3y2794HRRlDJZAb-clWM1zU0vzfdfKdY-z-BwSZB0fNoz9PETHe66QZ0Hn4ARbcgcb_BlBqTe_Vw3O0307uZldB2_F'],
    price: 1050000,
    sale_price: 880000,
    description: 'Bộ cọ trang điểm thiết yếu 5 món với lông cọ nhân tạo siêu mềm mịn và cổ cọ mạ vàng hồng (Rose Gold) sang chảnh đi kèm bao da tiện dụng.',
    specs: {
      count: '5 cây cọ trang điểm chuyên dụng',
      material: 'Sợi nhân tạo mềm mại thuần chay, thân gỗ cao cấp',
      includes: 'Cọ phấn phủ, cọ má hồng, cọ tán nền, cọ bầu mắt, cọ kẻ viền',
      clean: 'Rửa định kỳ bằng dung dịch giặt cọ chuyên dụng'
    },
    stock: 80,
    is_active: true,
    tags: [],
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
  }
];

// ============================================
// HÀM SEED
// ============================================

async function seedCol(name, data, customId = false) {
  console.log(`Seeding ${name}...`);
  const batch = db.batch();
  data.forEach(doc => {
    const ref = customId
      ? db.collection(name).doc(doc.id)
      : db.collection(name).doc();
    batch.set(ref, doc);
  });
  await batch.commit();
  console.log(`  ✅ ${data.length} docs → ${name}`);
}

async function main() {
  console.log('🌸 Bắt đầu dọn dẹp và seed data Beauty & Glow Cosmetics...\n');
  
  // Clean existing collections before seeding
  console.log('Cleaning old collections...');
  const collections = ['categories', 'store_locations', 'products'];
  for (const col of collections) {
    const snap = await db.collection(col).get();
    const batch = db.batch();
    snap.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
    console.log(`  🧹 Đã xóa data cũ trong ${col}`);
  }
  
  console.log('\nSeeding new data...');
  await seedCol('categories',      categories,     true);
  await seedCol('store_locations', storeLocations, true);
  await seedCol('products',        products,       false);
  console.log('\n✅ Xong! Cơ sở dữ liệu Firestore đã được cập nhật sang mỹ phẩm.');
  process.exit(0);
}

main().catch(err => {
  console.error('❌ Lỗi:', err);
  process.exit(1);
});