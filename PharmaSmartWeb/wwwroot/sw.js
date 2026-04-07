// ============================================================
// PharmaSmart ERP - Service Worker (Offline-First Strategy)
// ============================================================
const CACHE_NAME = 'pharmasmart-v1';
const STATIC_ASSETS = [
    '/Sales/Create',
    '/css/site.css',
    '/js/site.js',
    '/lib/sweetalert2.js',
    '/js/offline-db.js',
    '/offline.html'
];

// تثبيت SW وتخزين الملفات الأساسية
self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME).then(cache => {
            return cache.addAll(STATIC_ASSETS).catch(() => {});
        })
    );
    self.skipWaiting();
});

// تفعيل وحذف الكاشات القديمة
self.addEventListener('activate', event => {
    event.waitUntil(
        caches.keys().then(keys =>
            Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
        )
    );
    self.clients.claim();
});

// اعتراض الطلبات: Network First مع fallback للـ Cache
self.addEventListener('fetch', event => {
    // تجاهل طلبات POST (المزامنة ستُدار من JS)
    if (event.request.method !== 'GET') return;

    // تجاهل مسارات API الديناميكية
    const url = new URL(event.request.url);
    if (url.pathname.startsWith('/api/') || 
        url.pathname.includes('SyncOfflineSale') ||
        url.pathname.includes('__browserLink')) return;

    event.respondWith(
        fetch(event.request)
            .then(response => {
                // تحديث الكاش بالنسخة الجديدة
                if (response.ok) {
                    const cloned = response.clone();
                    caches.open(CACHE_NAME).then(cache => cache.put(event.request, cloned));
                }
                return response;
            })
            .catch(() => {
                // عند انقطاع الإنترنت، استخدم الكاش
                return caches.match(event.request).then(cached => {
                    if (cached) return cached;
                    // إذا لم يكن في الكاش وانقطع النت، أعد صفحة Offline
                    if (event.request.headers.get('accept')?.includes('text/html')) {
                        return caches.match('/offline.html');
                    }
                });
            })
    );
});

// استقبال رسائل من الصفحة (طلب مزامنة يدوي)
self.addEventListener('message', event => {
    if (event.data === 'SKIP_WAITING') self.skipWaiting();
});
