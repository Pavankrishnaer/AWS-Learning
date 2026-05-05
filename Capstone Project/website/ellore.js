// ═══════════════════════════════════════════════
// ELLORE — Shared JavaScript
// ellore.js — include on every page
// ═══════════════════════════════════════════════

// ─────────────────────────────────────────────
// API GATEWAY CONFIGURATION
// ─────────────────────────────────────────────
const API_BASE_URL = 'https://wuyzjjmuzk.execute-api.eu-central-1.amazonaws.com/prod';

const API_ENDPOINTS = {
  contact: `${API_BASE_URL}/contact`,
  order: `${API_BASE_URL}/order`,
  newsletter: `${API_BASE_URL}/newsletter`,
  translate: `${API_BASE_URL}/translate`
};

// ─────────────────────────────────────────────
// API HELPER FUNCTIONS
// ─────────────────────────────────────────────
async function callAPI(endpoint, data, requireAuth = false) {
  try {
    const headers = {
      'Content-Type': 'application/json',
    };

    // Add authentication token if required
    if (requireAuth && typeof Auth !== 'undefined') {
      const session = await Auth.currentSession();
      if (session) {
        headers['Authorization'] = `Bearer ${session.idToken}`;
      } else if (requireAuth) {
        throw new Error('Authentication required');
      }
    }

    const response = await fetch(endpoint, {
      method: 'POST',
      headers: headers,
      body: JSON.stringify(data)
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.status} ${response.statusText}`);
    }

    return await response.json();
  } catch (error) {
    console.error('API call failed:', error);
    throw error;
  }
}

// Make authenticated API call (requires auth.js)
async function makeAuthenticatedAPICall(endpoint, data) {
  if (typeof Auth === 'undefined') {
    throw new Error('Authentication library not loaded');
  }

  const session = await Auth.currentSession();
  if (!session) {
    alert('Please login to continue');
    window.location.href = 'login.html';
    throw new Error('Not authenticated');
  }

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${session.idToken}`
    },
    body: JSON.stringify(data)
  });

  if (response.status === 401) {
    alert('Session expired. Please login again.');
    Auth.signOut();
    window.location.href = 'login.html';
    throw new Error('Session expired');
  }

  if (!response.ok) {
    throw new Error(`API error: ${response.status}`);
  }

  return await response.json();
}

// ─────────────────────────────────────────────
// IMAGE PATHS — update when real images are added
// All images live in: images/men/, images/women/, images/kids/
// ─────────────────────────────────────────────
const IMG = {
  hero: 'images/hero/hero-main.jpg',
  menCategory: 'images/men/men-category.jpg',
  womenCategory: 'images/women/women-category.jpg',
  kidsCategory: 'images/kids/kids-category.jpg',
  menBanner: 'images/men/men-banner.jpg',
  womenBanner: 'images/women/women-banner.jpg',
  kidsBanner: 'images/kids/kids-banner.jpg',
  men: Array.from({ length: 8 }, (_, i) => `images/men/men-product-${i + 1}.jpg`),
  women: Array.from({ length: 8 }, (_, i) => `images/women/women-product-${i + 1}.jpg`),
  kids: Array.from({ length: 8 }, (_, i) => `images/kids/kids-product-${i + 1}.jpg`),
};

// ─────────────────────────────────────────────
// PRODUCT CATALOGUE
// ─────────────────────────────────────────────
const PRODUCTS = [
  // MEN (ids 1-8)
  {
    id: 1, name: 'Sculpted Wool Bomber', nameDE: 'Skulpturierter Woll-Bomber', price: 420, category: 'MEN', tag: 'OUTERWEAR', badge: 'NEW',
    img: IMG.men[0], desc: 'A masterpiece of modern tailoring. The Sculpted Wool Bomber redefines outerwear with its architectural silhouette and premium Italian wool construction.',
    descDE: 'Ein Meisterwerk moderner Schneiderei. Der skulpturierte Woll-Bomber definiert Oberbekleidung mit seiner architektonischen Silhouette neu.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'], colors: ['Cream', 'Charcoal']
  },
  {
    id: 2, name: '240g Heavyweight Tee', nameDE: 'Schweres T-Shirt 240g', price: 85, category: 'MEN', tag: 'BASICS',
    img: IMG.men[1], desc: 'Crafted from 240gsm premium cotton, this heavyweight tee offers structure and longevity far beyond standard basics.',
    descDE: 'Aus 240g/m² Premium-Baumwolle gefertigt bietet dieses T-Shirt Struktur und Langlebigkeit weit über Standard-Basics hinaus.',
    sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'], colors: ['Black', 'White', 'Grey']
  },
  {
    id: 3, name: 'Japanese Selvedge Denim', nameDE: 'Japanische Selvedge-Jeans', price: 210, category: 'MEN', tag: 'DENIM',
    img: IMG.men[2], desc: 'Raw indigo selvedge denim woven on vintage shuttle looms in Okayama, Japan. Each pair develops a unique fade pattern over time.',
    descDE: 'Roher Indigo-Selvedge-Denim auf Vintage-Shuttle-Webstühlen in Okayama, Japan gewoben.',
    sizes: ['28', '30', '32', '34', '36'], colors: ['Raw Indigo']
  },
  {
    id: 4, name: 'Merino Roll-Neck', nameDE: 'Merino-Rollkragen', price: 165, category: 'MEN', tag: 'KNITWEAR', badge: 'BESTSELLER',
    img: IMG.men[3], desc: 'Superfine 18.5 micron merino wool in a relaxed roll-neck silhouette. Temperature-regulating, odour-resistant, and supremely soft.',
    descDE: 'Superfeine 18,5-Mikron-Merinowolle in entspannter Rollkragen-Silhouette.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'], colors: ['Charcoal', 'Navy', 'Oat']
  },
  {
    id: 5, name: 'Technical Cargo Trousers', nameDE: 'Technische Cargohosen', price: 195, category: 'MEN', tag: 'TROUSERS',
    img: IMG.men[4], desc: 'Engineered from water-repellent ripstop fabric with articulated knees and minimal cargo pockets. Form meets extreme function.',
    descDE: 'Aus wasserabweisendem Ripstop-Stoff mit geformten Knien und minimalen Cargotaschen gefertigt.',
    sizes: ['28', '30', '32', '34', '36'], colors: ['Olive', 'Black', 'Stone']
  },
  {
    id: 6, name: 'Linen Overshirt', nameDE: 'Leinen-Overshirt', price: 130, category: 'MEN', tag: 'SHIRTS',
    img: IMG.men[5], desc: 'Stonewashed Belgian linen overshirt with dropped shoulders and a relaxed boxy fit. The perfect layering piece for any season.',
    descDE: 'Steingewaschenes belgisches Leinen-Overshirt mit abfallenden Schultern und lockerer Passform.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'], colors: ['Sand', 'White', 'Slate']
  },
  {
    id: 7, name: 'Structured Blazer', nameDE: 'Strukturierter Blazer', price: 340, category: 'MEN', tag: 'TAILORING',
    img: IMG.men[6], desc: 'Half-canvassed construction in a Japanese wool-blend suiting fabric. Clean peak lapels and a single-button stance.',
    descDE: 'Halb-kanvasierte Konstruktion aus japanischem Woll-Mix-Anzugsstoff.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'], colors: ['Charcoal', 'Navy']
  },
  {
    id: 8, name: 'Cashmere Lounge Pant', nameDE: 'Kaschmir-Loungehose', price: 245, category: 'MEN', tag: 'LOUNGEWEAR',
    img: IMG.men[7], desc: 'Pure Grade-A cashmere lounge trousers with elasticated waistband and tapered leg. Luxury that feels as good as it looks.',
    descDE: 'Reine Klasse-A-Kaschmir-Loungehose mit elastischem Bund und konisch zulaufendem Bein.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'], colors: ['Oat', 'Charcoal', 'Black']
  },

  // WOMEN (ids 9-16)
  {
    id: 9, name: 'Ultra-Soft Cashmere Knit', nameDE: 'Ultra-Weiches Kaschmir-Strick', price: 295, category: 'WOMEN', tag: 'KNITWEAR', badge: 'BESTSELLER',
    img: IMG.women[0], desc: 'Our most-loved piece. Grade-A cashmere in a relaxed crew-neck silhouette that transitions effortlessly from day to evening.',
    descDE: 'Unser beliebtestes Stück. Klasse-A-Kaschmir in entspannter Rundhals-Silhouette.',
    sizes: ['XS', 'S', 'M', 'L'], colors: ['Cream', 'Camel', 'Black']
  },
  {
    id: 10, name: 'Organic Cotton Shirtdress', nameDE: 'Bio-Baumwoll-Hemdblusenkleid', price: 155, category: 'WOMEN', tag: 'DRESSES',
    img: IMG.women[1], desc: 'A timeless shirtdress in GOTS-certified organic cotton poplin. Fitted through the waist with a flattering A-line skirt.',
    descDE: 'Ein zeitloses Hemdblusenkleid aus GOTS-zertifizierter Bio-Baumwoll-Popeline.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'], colors: ['White', 'Navy', 'Stripe']
  },
  {
    id: 11, name: 'Wool-Silk Wrap Coat', nameDE: 'Woll-Seiden-Wickelmantel', price: 520, category: 'WOMEN', tag: 'OUTERWEAR', badge: 'NEW',
    img: IMG.women[2], desc: 'An investment coat in Italian wool-silk blend. Fluid drape, wide lapels, and a self-tie belt for effortless elegance.',
    descDE: 'Ein Investment-Mantel aus italienischem Woll-Seiden-Mix.',
    sizes: ['XS', 'S', 'M', 'L'], colors: ['Camel', 'Charcoal']
  },
  {
    id: 12, name: 'Wide-Leg Linen Trousers', nameDE: 'Weite Leinenhosen', price: 140, category: 'WOMEN', tag: 'TROUSERS',
    img: IMG.women[3], desc: 'High-waisted wide-leg trousers in pre-washed Belgian linen. Relaxed through the hip with a flattering full-length drape.',
    descDE: 'Hochgeschnittene weite Hose aus vorgewaschener belgischer Leinen.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'], colors: ['Oat', 'Olive', 'Black']
  },
  {
    id: 13, name: 'Silk Camisole', nameDE: 'Seiden-Camisole', price: 110, category: 'WOMEN', tag: 'TOPS',
    img: IMG.women[4], desc: 'Pure mulberry silk camisole with adjustable straps. Layer under blazers or wear solo for understated luxury.',
    descDE: 'Reine Maulbeerseide-Camisole mit verstellbaren Trägern.',
    sizes: ['XS', 'S', 'M', 'L'], colors: ['Ivory', 'Black', 'Terracotta']
  },
  {
    id: 14, name: 'High-Rise Straight Jeans', nameDE: 'Hochgeschnittene Straight Jeans', price: 175, category: 'WOMEN', tag: 'DENIM', badge: 'BESTSELLER',
    img: IMG.women[5], desc: 'The perfect fit. High-rise straight-leg jeans in rigid Italian denim that softens and fades beautifully over time.',
    descDE: 'Die perfekte Passform. Hochgeschnittene Straight-Leg-Jeans aus festem italienischem Denim.',
    sizes: ['24', '26', '28', '30', '32'], colors: ['Raw Indigo', 'Black']
  },
  {
    id: 15, name: 'Merino Turtleneck', nameDE: 'Merino-Rollkragenpullover', price: 140, category: 'WOMEN', tag: 'KNITWEAR',
    img: IMG.women[6], desc: 'Superfine merino wool turtleneck in a slim-fit silhouette. Temperature-regulating and endlessly versatile.',
    descDE: 'Superfeine Merino-Wolle-Rollkragen in schlanker Passform.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'], colors: ['Cream', 'Navy', 'Charcoal']
  },
  {
    id: 16, name: 'Organic Cotton Tee', nameDE: 'Bio-Baumwoll-T-Shirt', price: 65, category: 'WOMEN', tag: 'BASICS',
    img: IMG.women[7], desc: 'Essential basics done right. GOTS-certified organic cotton in a relaxed fit with a classic crew neck.',
    descDE: 'Essenzielle Basics richtig gemacht. GOTS-zertifizierte Bio-Baumwolle in entspannter Passform.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'], colors: ['White', 'Black', 'Grey', 'Olive']
  },

  // KIDS (ids 17-24)
  {
    id: 17, name: 'Quilted Puffer Jacket', nameDE: 'Gesteppte Daunenjacke', price: 145, category: 'KIDS', tag: 'OUTERWEAR', badge: 'NEW',
    img: IMG.kids[0], desc: 'Lightweight and warm. Recycled polyester shell with eco-friendly down fill. Water-resistant and easy to pack.',
    descDE: 'Leicht und warm. Recyceltes Polyester mit umweltfreundlicher Daunenfüllung.',
    sizes: ['4Y', '6Y', '8Y', '10Y', '12Y'], colors: ['Navy', 'Black', 'Olive']
  },
  {
    id: 18, name: 'Organic Hoodie', nameDE: 'Bio-Hoodie', price: 55, category: 'KIDS', tag: 'TOPS',
    img: IMG.kids[1], desc: 'Soft brushed organic cotton fleece in a classic pullover hoodie. Built to last through all their adventures.',
    descDE: 'Weiche gebürstete Bio-Baumwolle in klassischem Pullover-Hoodie.',
    sizes: ['4Y', '6Y', '8Y', '10Y', '12Y'], colors: ['Grey', 'Navy', 'Cream']
  },
  {
    id: 19, name: 'Stretch Denim Jeans', nameDE: 'Stretch-Jeans', price: 70, category: 'KIDS', tag: 'DENIM', badge: 'BESTSELLER',
    img: IMG.kids[2], desc: 'Durable stretch denim with reinforced knees. Adjustable elastic waistband for the perfect fit as they grow.',
    descDE: 'Strapazierfähiges Stretch-Denim mit verstärkten Knien.',
    sizes: ['4Y', '6Y', '8Y', '10Y', '12Y'], colors: ['Indigo', 'Black']
  },
  {
    id: 20, name: 'Cotton Chinos', nameDE: 'Baumwoll-Chinos', price: 60, category: 'KIDS', tag: 'TROUSERS',
    img: IMG.kids[3], desc: 'Classic chinos in soft organic cotton twill. Smart enough for special occasions, comfortable for everyday wear.',
    descDE: 'Klassische Chinos aus weichem Bio-Baumwoll-Twill.',
    sizes: ['4Y', '6Y', '8Y', '10Y', '12Y'], colors: ['Navy', 'Khaki', 'Black']
  },
  {
    id: 21, name: 'Striped Long-Sleeve Tee', nameDE: 'Gestreiftes Langarmshirt', price: 35, category: 'KIDS', tag: 'BASICS',
    img: IMG.kids[4], desc: 'A wardrobe staple in soft organic cotton jersey. Breton stripes and long sleeves for year-round layering.',
    descDE: 'Ein Kleiderschrank-Grundelement aus weichem Bio-Baumwoll-Jersey.',
    sizes: ['4Y', '6Y', '8Y', '10Y', '12Y'], colors: ['Navy/White', 'Red/White']
  },
  {
    id: 22, name: 'Wool Cardigan', nameDE: 'Woll-Cardigan', price: 85, category: 'KIDS', tag: 'KNITWEAR',
    img: IMG.kids[5], desc: 'Soft merino wool cardigan with wooden buttons. Lightweight enough for layering, warm enough for chilly days.',
    descDE: 'Weicher Merino-Woll-Cardigan mit Holzknöpfen.',
    sizes: ['4Y', '6Y', '8Y', '10Y', '12Y'], colors: ['Oat', 'Navy', 'Grey']
  },
  {
    id: 23, name: 'Waterproof Rain Jacket', nameDE: 'Wasserfeste Regenjacke', price: 95, category: 'KIDS', tag: 'OUTERWEAR',
    img: IMG.kids[6], desc: 'Fully seam-sealed rain jacket with breathable membrane. Keeps them dry and comfortable in any weather.',
    descDE: 'Vollständig versiegelte Regenjacke mit atmungsaktiver Membran.',
    sizes: ['4Y', '6Y', '8Y', '10Y', '12Y'], colors: ['Yellow', 'Navy', 'Red']
  },
  {
    id: 24, name: 'Jogger Pants', nameDE: 'Jogginghosen', price: 48, category: 'KIDS', tag: 'LOUNGEWEAR',
    img: IMG.kids[7], desc: 'Soft fleece joggers with tapered legs and elastic cuffs. Perfect for playtime, downtime, and everything in between.',
    descDE: 'Weiche Fleece-Jogger mit konischen Beinen und elastischen Bündchen.',
    sizes: ['4Y', '6Y', '8Y', '10Y', '12Y'], colors: ['Grey', 'Navy', 'Black']
  },
];

// ─────────────────────────────────────────────
// SHOPPING CART
// ─────────────────────────────────────────────
let cart = [];

function loadCart() {
  const saved = localStorage.getItem('ellore_cart');
  cart = saved ? JSON.parse(saved) : [];
  updateCartBadge();
}

function saveCart() {
  localStorage.setItem('ellore_cart', JSON.stringify(cart));
  updateCartBadge();
}

function updateCartBadge() {
  const badge = document.getElementById('cartBadge');
  const count = cart.reduce((sum, item) => sum + item.qty, 0);
  if (badge) {
    badge.textContent = count;
    badge.style.display = count > 0 ? 'flex' : 'none';
  }
}

function addToCart(productId, size = null) {
  const product = PRODUCTS.find(p => p.id === productId);
  if (!product) return;

  const existing = cart.find(item => item.id === productId && item.size === size);
  if (existing) {
    existing.qty++;
  } else {
    cart.push({
      id: product.id,
      name: product.name,
      price: product.price,
      img: product.img,
      size: size,
      qty: 1
    });
  }

  saveCart();
  showToast(`${product.name} added to bag`);

  const drawer = document.getElementById('cartDrawer');
  if (drawer && typeof openCart === 'function') {
    renderCart();
    setTimeout(() => openCart(), 100);
  } else {
    renderCart();
  }
}

function removeFromCart(productId, size = null) {
  cart = cart.filter(item => !(item.id === productId && item.size === size));
  saveCart();
  renderCart();
}

function updateQuantity(productId, size, delta) {
  const item = cart.find(i => i.id === productId && i.size === size);
  if (!item) return;
  item.qty += delta;
  if (item.qty <= 0) {
    removeFromCart(productId, size);
  } else {
    saveCart();
    renderCart();
  }
}

function getCartTotal() {
  return cart.reduce((sum, item) => sum + (item.price * item.qty), 0);
}

function renderCart() {
  const el = document.getElementById('cartItems');
  const totalEl = document.getElementById('cartTotal');
  const subtotalEl = document.getElementById('cartSubtotal');

  if (!el) return;

  if (cart.length === 0) {
    el.innerHTML = '<p class="text-sm text-gray-400 text-center py-8">Your bag is empty</p>';
    if (totalEl) totalEl.textContent = '€0.00';
    if (subtotalEl) subtotalEl.textContent = '€0.00';
    return;
  }

  el.innerHTML = cart.map(item => `
    <div class="flex gap-4 items-start pb-4 border-b border-gray-100">
      <img src="${item.img}" alt="${item.name}" class="w-20 h-24 object-cover bg-gray-100 flex-shrink-0"/>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-bold text-gray-900 leading-tight mb-1">${item.name}</p>
        ${item.size ? `<p class="text-[10px] text-gray-400 uppercase tracking-widest mb-2">${item.size}</p>` : ''}
        <div class="flex items-center gap-3 mt-2">
          <button onclick="updateQuantity(${item.id}, ${item.size ? `'${item.size}'` : 'null'}, -1)" 
            class="w-7 h-7 border border-gray-300 flex items-center justify-center text-xs hover:bg-gray-50 active:scale-95 transition-transform">−</button>
          <span class="text-xs font-bold min-w-[20px] text-center">${item.qty}</span>
          <button onclick="updateQuantity(${item.id}, ${item.size ? `'${item.size}'` : 'null'}, 1)" 
            class="w-7 h-7 border border-gray-300 flex items-center justify-center text-xs hover:bg-gray-50 active:scale-95 transition-transform">+</button>
        </div>
      </div>
      <div class="text-right flex-shrink-0">
        <p class="text-sm font-black text-[#00327d] mb-2">€${(item.price * item.qty).toFixed(2)}</p>
        <button onclick="removeFromCart(${item.id}, ${item.size ? `'${item.size}'` : 'null'})" 
          class="text-[10px] text-gray-400 hover:text-red-500 uppercase tracking-widest">Remove</button>
      </div>
    </div>`).join('');

  const total = getCartTotal();
  if (totalEl) totalEl.textContent = '€' + total.toFixed(2);
  if (subtotalEl) subtotalEl.textContent = '€' + total.toFixed(2);
}

function openCart() {
  document.getElementById('cartDrawer').classList.add('open');
  document.getElementById('cartOverlay').classList.add('open');
  document.body.style.overflow = 'hidden';
}

function closeCart() {
  document.getElementById('cartDrawer').classList.remove('open');
  document.getElementById('cartOverlay').classList.remove('open');
  document.body.style.overflow = '';
}

// ─────────────────────────────────────────────
// LANGUAGE TOGGLE
// ─────────────────────────────────────────────
let currentLang = 'en';

function switchLang(lang) {
  currentLang = lang;
  document.querySelectorAll('.lang-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.lang === lang);
  });
  if (typeof onLangChange === 'function') {
    onLangChange(lang);
  }
}

// ─────────────────────────────────────────────
// TOAST NOTIFICATIONS
// ─────────────────────────────────────────────
function showToast(message) {
  const toast = document.getElementById('toast');
  if (!toast) return;
  toast.textContent = message;
  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 2500);
}

// ─────────────────────────────────────────────
// NAVIGATION & FOOTER (Shared Components)
// ─────────────────────────────────────────────
function renderNav() {
  const navEl = document.getElementById('elloreNav');
  if (!navEl) return;

  navEl.innerHTML = `
    <div class="max-w-[1920px] mx-auto px-12 py-5 flex items-center justify-between relative">
      <a href="index.html" class="text-2xl font-black tracking-tighter uppercase">ELLORE</a>
      <div class="absolute left-1/2 -translate-x-1/2 flex gap-8">
        <a href="men.html" class="text-xs font-bold uppercase tracking-widest text-gray-600 hover:text-[#00327d] transition-colors">Men</a>
        <a href="women.html" class="text-xs font-bold uppercase tracking-widest text-gray-600 hover:text-[#00327d] transition-colors">Women</a>
        <a href="kids.html" class="text-xs font-bold uppercase tracking-widest text-gray-600 hover:text-[#00327d] transition-colors">Kids</a>
        <a href="about.html" class="text-xs font-bold uppercase tracking-widest text-gray-600 hover:text-[#00327d] transition-colors">About</a>
        <a href="contact.html" class="text-xs font-bold uppercase tracking-widest text-gray-600 hover:text-[#00327d] transition-colors">Contact</a>
      </div>
      <div class="flex items-center gap-6">
        <div id="auth-ui-placeholder" class="flex items-center gap-3"></div>
        <div class="flex items-center gap-1 border border-gray-300">
          <button class="lang-btn px-3 py-1.5 text-[10px] font-bold uppercase tracking-widest active" data-lang="en" onclick="switchLang('en')">EN</button>
          <button class="lang-btn px-3 py-1.5 text-[10px] font-bold uppercase tracking-widest" data-lang="de" onclick="switchLang('de')">DE</button>
        </div>
        <a href="search.html" class="text-gray-600 hover:text-[#00327d] transition-colors">
          <span class="material-symbols-outlined" style="font-size:20px">search</span>
        </a>
        <button onclick="openCart()" class="relative text-gray-600 hover:text-[#00327d] transition-colors">
          <span class="material-symbols-outlined" style="font-size:20px">shopping_bag</span>
          <span id="cartBadge" class="absolute -top-2 -right-2 bg-[#00327d] text-white text-[10px] font-bold w-5 h-5 rounded-full flex items-center justify-center" style="display:none">0</span>
        </button>
      </div>
    </div>
  `;

  // Populate auth UI after navigation is rendered
  setTimeout(() => populateAuthUI(), 100);
}

// Populate authentication UI in navigation
async function populateAuthUI() {
  if (typeof Auth === 'undefined') return; // Auth.js not loaded

  const placeholder = document.getElementById('auth-ui-placeholder');
  if (!placeholder) return;

  try {
    const session = await Auth.currentSession();

    if (session) {
      const user = Auth.getCurrentUser();
      const userName = user.name || user.email.split('@')[0];
      placeholder.innerHTML = `
        <span class="text-[10px] text-gray-600 uppercase tracking-widest font-medium">
          Welcome, <strong class="text-[#00327d]">${userName}</strong>
        </span>
        <a href="account.html" class="text-[10px] font-bold uppercase tracking-widest text-[#00327d] hover:underline">Account</a>
        <button onclick="handleLogout()" class="text-[10px] font-bold uppercase tracking-widest text-gray-400 hover:text-gray-900">Logout</button>
      `;
    } else {
      placeholder.innerHTML = `
        <a href="login.html" class="text-[10px] font-bold uppercase tracking-widest text-gray-600 hover:text-[#00327d]">Login</a>
        <a href="signup.html" class="px-5 py-2 text-[10px] font-bold uppercase tracking-widest text-white" style="background:linear-gradient(135deg,#00327d 0%,#0047ab 100%);">Sign Up</a>
      `;
    }
  } catch (error) {
    // Auth not available, show login/signup
    placeholder.innerHTML = `
      <a href="login.html" class="text-[10px] font-bold uppercase tracking-widest text-gray-600 hover:text-[#00327d]">Login</a>
      <a href="signup.html" class="px-5 py-2 text-[10px] font-bold uppercase tracking-widest text-white" style="background:linear-gradient(135deg,#00327d 0%,#0047ab 100%);">Sign Up</a>
    `;
  }
}

function handleLogout() {
  if (confirm('Are you sure you want to logout?')) {
    Auth.signOut();
    window.location.reload();
  }
}

function renderFooter() {
  const footerEl = document.getElementById('elloreFooter');
  if (!footerEl) return;

  footerEl.innerHTML = `
    <div class="max-w-[1920px] mx-auto px-12 py-16">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-12 mb-12">
        <div>
          <h3 class="text-xl font-black tracking-tighter uppercase mb-6">ELLORE</h3>
          <p class="text-xs text-gray-600 leading-relaxed">Modern minimalism meets timeless design. Crafted for those who value quality and sustainability.</p>
        </div>
        <div>
          <h4 class="text-xs font-bold uppercase tracking-widest mb-4">Shop</h4>
          <ul class="space-y-2">
            <li><a href="men.html" class="text-xs text-gray-600 hover:text-[#00327d] transition-colors">Men</a></li>
            <li><a href="women.html" class="text-xs text-gray-600 hover:text-[#00327d] transition-colors">Women</a></li>
            <li><a href="kids.html" class="text-xs text-gray-600 hover:text-[#00327d] transition-colors">Kids</a></li>
          </ul>
        </div>
        <div>
          <h4 class="text-xs font-bold uppercase tracking-widest mb-4">Customer Care</h4>
          <ul class="space-y-2">
            <li><a href="contact.html" class="text-xs text-gray-600 hover:text-[#00327d] transition-colors">Contact Us</a></li>
            <li><a href="shipping.html" class="text-xs text-gray-600 hover:text-[#00327d] transition-colors">Shipping & Returns</a></li>
            <li><a href="legal.html" class="text-xs text-gray-600 hover:text-[#00327d] transition-colors">Terms & Conditions</a></li>
            <li><a href="privacy.html" class="text-xs text-gray-600 hover:text-[#00327d] transition-colors">Privacy Policy</a></li>
          </ul>
        </div>
        <div>
          <h4 class="text-xs font-bold uppercase tracking-widest mb-4">Connect</h4>
          <ul class="space-y-2">
            <li><a href="about.html" class="text-xs text-gray-600 hover:text-[#00327d] transition-colors">Our Story</a></li>
            <li><a href="newsletter.html" class="text-xs text-gray-600 hover:text-[#00327d] transition-colors">Newsletter</a></li>
          </ul>
        </div>
      </div>
      <div class="border-t border-gray-300 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
        <p class="text-[10px] text-gray-400 uppercase tracking-widest">© 2024 ELLORE. All rights reserved.</p>
        <div class="flex gap-4">
          <span class="text-[10px] text-gray-400 uppercase tracking-widest">Made with care in Europe</span>
        </div>
      </div>
    </div>
  `;
}

function renderCartDrawer() {
  const body = document.body;

  // Cart overlay
  const overlay = document.createElement('div');
  overlay.id = 'cartOverlay';
  overlay.className = 'cart-overlay fixed inset-0 bg-black/40 z-40';
  overlay.onclick = closeCart;
  body.appendChild(overlay);

  // Cart drawer
  const drawer = document.createElement('div');
  drawer.id = 'cartDrawer';
  drawer.className = 'cart-drawer fixed top-0 right-0 h-full w-full md:w-[480px] bg-white z-50 flex flex-col';
  drawer.innerHTML = `
    <div class="p-8 border-b border-gray-100 flex justify-between items-center flex-shrink-0">
      <h2 class="text-xl font-black uppercase tracking-tighter">Your Bag</h2>
      <button onclick="closeCart()" class="text-gray-400 hover:text-gray-900 transition-colors">
        <span class="material-symbols-outlined" style="font-size:24px">close</span>
      </button>
    </div>
    <div class="flex-1 overflow-y-auto p-8">
      <div id="cartItems" class="space-y-4"></div>
    </div>
    <div class="p-8 border-t border-gray-100 flex-shrink-0">
      <div class="flex justify-between items-center mb-6">
        <span class="text-sm font-bold uppercase tracking-widest">Subtotal</span>
        <span class="text-2xl font-black text-[#00327d]" id="cartSubtotal">€0.00</span>
      </div>
      <a href="checkout.html" class="block w-full primary-gradient text-white py-5 text-center text-sm font-black uppercase tracking-widest mb-3 active:scale-95 transition-transform">
        Proceed to Checkout
      </a>
      <button onclick="closeCart()" class="w-full border border-gray-300 text-gray-600 py-4 text-center text-xs font-bold uppercase tracking-widest hover:bg-gray-50 transition-colors">
        Continue Shopping
      </button>
      <p class="text-[10px] text-gray-400 uppercase tracking-widest text-center mt-4">Free shipping on orders over €150</p>
    </div>
  `;
  body.appendChild(drawer);

  // Toast
  const toast = document.createElement('div');
  toast.id = 'toast';
  toast.className = 'toast fixed bottom-8 left-1/2 -translate-x-1/2 bg-[#00327d] text-white px-8 py-4 text-sm font-bold uppercase tracking-widest z-50';
  body.appendChild(toast);
}

// ─────────────────────────────────────────────
// INITIALIZATION
// ─────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  renderNav();
  renderFooter();
  renderCartDrawer();
  loadCart();
  renderCart();
});