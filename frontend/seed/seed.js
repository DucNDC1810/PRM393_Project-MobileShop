const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const now = admin.firestore.Timestamp.now();

// ============================================
// DATA MẪU — BEAUTY & GLOW COSMETICS
// ============================================

const categories = [
  { id: 'cat_skincare', name: 'Skincare',      slug: 'skincare', icon: '💧', order: 1, is_active: true },
  { id: 'cat_makeup',   name: 'Makeup',        slug: 'makeup',   icon: '💄', order: 2, is_active: true },
  { id: 'cat_perfume',  name: 'Nước hoa',      slug: 'perfume',  icon: '🌸', order: 3, is_active: true },
  { id: 'cat_hair',     name: 'Chăm sóc tóc',  slug: 'hair',     icon: '✨', order: 4, is_active: true },
  { id: 'cat_body',     name: 'Chăm sóc thân', slug: 'body',     icon: '🧴', order: 5, is_active: true },
];

const storeLocations = [{
  id: 'store_q1',
  name: 'Beauty & Glow — Chi nhánh Quận 1',
  address: '456 Nguyễn Huệ, P. Bến Nghé, Quận 1, TP.HCM',
  lat: 10.7769, lng: 106.7009,
  hotline: '0909888777',
  hours: '9:00 – 22:00 (Thứ 2 – Chủ Nhật)',
  website: 'www.beautyandglow.vn',
  is_active: true,
}];

const products = [
  {
    sku: 'INN-GTS-80ML', name: 'Green Tea Seed Serum',
    brand: 'Innisfree', category: 'skincare', category_id: 'cat_skincare',
    images: ['https://via.placeholder.com/400x400/E8F5E9/085041?text=Innisfree+Serum'],
    price: 350000, sale_price: 250000,
    description: 'Serum dưỡng ẩm chuyên sâu từ hạt trà xanh Jeju, cân bằng độ ẩm và se khít lỗ chân lông.',
    ingredients: ['Green Tea Extract', 'Hyaluronic Acid', 'Niacinamide'],
    volume: '80ml', skin_types: ['da_dau', 'da_hon_hop'],
    usage: 'Thoa 2-3 giọt lên mặt sau bước toner, massage nhẹ đến khi thấm.',
    return_policy: 'Đổi trả trong 30 ngày nếu sản phẩm lỗi sản xuất.',
    stock: 120, is_active: true, tags: ['best_seller'],
    created_at: now, updated_at: now,
  },
  {
    sku: 'LAN-WSM-70ML', name: 'Water Sleeping Mask',
    brand: 'Laneige', category: 'skincare', category_id: 'cat_skincare',
    images: ['https://via.placeholder.com/400x400/E3F2FD/0C447C?text=Laneige+Mask'],
    price: 550000, sale_price: 420000,
    description: 'Mặt nạ ngủ dưỡng ẩm tối ưu, phục hồi da mềm mịn qua đêm với SLEEP-TOX.',
    ingredients: ['Mineral Water', 'Apricot Extract', 'Evening Primrose'],
    volume: '70ml', skin_types: ['da_kho', 'da_binh_thuong'],
    usage: 'Thoa bước cuối skincare tối. Rửa sạch vào buổi sáng.',
    return_policy: 'Đổi trả trong 30 ngày nếu sản phẩm lỗi sản xuất.',
    stock: 85, is_active: true, tags: ['new'],
    created_at: now, updated_at: now,
  },
  {
    sku: 'LOR-RVL-50ML', name: 'Revitalift Laser Cream',
    brand: "L'Oréal", category: 'skincare', category_id: 'cat_skincare',
    images: ['https://via.placeholder.com/400x400/FFF3E0/E65100?text=LOreal+Cream'],
    price: 420000, sale_price: 0,
    description: 'Kem dưỡng chống lão hoá với Pro-Retinol, giảm nếp nhăn và làm sáng da.',
    ingredients: ['Pro-Retinol', 'Vitamin C', 'Hyaluronic Acid'],
    volume: '50ml', skin_types: ['da_lao_hoa', 'da_binh_thuong'],
    usage: 'Thoa đều lên mặt và cổ sáng tối sau bước serum.',
    return_policy: 'Đổi trả trong 30 ngày nếu sản phẩm lỗi sản xuất.',
    stock: 60, is_active: true, tags: [],
    created_at: now, updated_at: now,
  },
  {
    sku: 'COS-SNL-100ML', name: 'Advanced Snail 96 Mucin Essence',
    brand: 'COSRX', category: 'skincare', category_id: 'cat_skincare',
    images: ['https://via.placeholder.com/400x400/F3E5F5/4A148C?text=COSRX+Essence'],
    price: 280000, sale_price: 0,
    description: 'Tinh chất ốc sên 96% phục hồi da tổn thương, mờ thâm và cấp ẩm hiệu quả.',
    ingredients: ['Snail Secretion Filtrate 96%', 'Betaine'],
    volume: '100ml', skin_types: ['da_dau', 'da_mun'],
    usage: 'Sau bước toner, thoa đều và vỗ nhẹ cho thấm.',
    return_policy: 'Đổi trả trong 30 ngày nếu sản phẩm lỗi sản xuất.',
    stock: 200, is_active: true, tags: ['best_seller'],
    created_at: now, updated_at: now,
  },
  {
    sku: 'MAC-STF-30ML', name: 'Studio Fix Fluid SPF 15',
    brand: 'MAC', category: 'makeup', category_id: 'cat_makeup',
    images: ['https://via.placeholder.com/400x400/FCE4EC/880E4F?text=MAC+Foundation'],
    price: 780000, sale_price: 650000,
    description: 'Kem nền che phủ hoàn hảo, lâu trôi 24h với SPF 15 bảo vệ da khỏi tia UV.',
    ingredients: ['Titanium Dioxide', 'Dimethicone'],
    volume: '30ml', skin_types: ['da_dau', 'da_hon_hop'],
    usage: 'Thoa đều bằng cọ hoặc mút, tán từ trong ra ngoài.',
    return_policy: 'Đổi trả trong 30 ngày nếu sản phẩm lỗi sản xuất.',
    stock: 0, is_active: true, tags: [],  // hết hàng để test UI
    created_at: now, updated_at: now,
  },
  {
    sku: 'MAY-FM-8G', name: 'Fit Me Matte + Poreless Powder',
    brand: 'Maybelline', category: 'makeup', category_id: 'cat_makeup',
    images: ['https://via.placeholder.com/400x400/E8EAF6/1A237E?text=Maybelline'],
    price: 185000, sale_price: 145000,
    description: 'Phấn phủ kiểm soát dầu, che lỗ chân lông, lâu trôi 8h.',
    ingredients: ['Silica', 'Talc', 'Mica'],
    volume: '8.5g', skin_types: ['da_dau', 'da_hon_hop'],
    usage: 'Dùng bông phấn thoa sau khi trang điểm nền.',
    return_policy: 'Đổi trả trong 30 ngày nếu sản phẩm lỗi sản xuất.',
    stock: 150, is_active: true, tags: ['best_seller'],
    created_at: now, updated_at: now,
  },
  {
    sku: 'TFS-RWT-150ML', name: 'Rice Water Bright Toner',
    brand: 'The Face Shop', category: 'skincare', category_id: 'cat_skincare',
    images: ['https://via.placeholder.com/400x400/FFF8E1/F57F17?text=TFS+Toner'],
    price: 220000, sale_price: 165000,
    description: 'Toner nước gạo làm sáng và cấp ẩm tức thì, phù hợp mọi loại da.',
    ingredients: ['Rice Water', 'Niacinamide', 'Glycerin'],
    volume: '150ml', skin_types: ['da_kho', 'da_binh_thuong', 'da_dau'],
    usage: 'Thấm toner lên bông tẩy trang và lau nhẹ sau khi rửa mặt.',
    return_policy: 'Đổi trả trong 30 ngày nếu sản phẩm lỗi sản xuất.',
    stock: 75, is_active: true, tags: [],
    created_at: now, updated_at: now,
  },
  {
    sku: 'SUL-FC-60ML', name: 'First Care Activating Serum',
    brand: 'Sulwhasoo', category: 'skincare', category_id: 'cat_skincare',
    images: ['https://via.placeholder.com/400x400/E8F5E9/1B5E20?text=Sulwhasoo'],
    price: 1850000, sale_price: 1480000,
    description: 'Tinh chất dưỡng cao cấp từ thảo dược Hàn Quốc, tăng hiệu quả hấp thụ của các bước skincare sau.',
    ingredients: ['JAUM Activator', 'Korean Herbal Complex'],
    volume: '60ml', skin_types: ['da_kho', 'da_lao_hoa'],
    usage: 'Bước đầu tiên sau rửa mặt — thoa nhẹ và vỗ cho thấm.',
    return_policy: 'Đổi trả trong 30 ngày nếu sản phẩm lỗi sản xuất.',
    stock: 30, is_active: true, tags: ['new'],
    created_at: now, updated_at: now,
  },
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
  console.log('🌸 Bắt đầu seed data Beauty & Glow...\n');
  await seedCol('categories',      categories,     true);
  await seedCol('store_locations', storeLocations, true);
  await seedCol('products',        products,       false);
  console.log('\n✅ Xong! Kiểm tra Firebase Console để xem data.');
  process.exit(0);
}

main().catch(err => {
  console.error('❌ Lỗi:', err);
  process.exit(1);
});