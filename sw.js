const C='cb1';
self.addEventListener('install',e=>e.waitUntil(caches.open(C).then(c=>c.addAll(['./','index.html','manifest.json','icon-192.png']))));
self.addEventListener('fetch',e=>{if(e.request.method!='GET'||!e.request.url.startsWith(location.origin))return;e.respondWith(fetch(e.request).catch(()=>caches.match(e.request)))});
