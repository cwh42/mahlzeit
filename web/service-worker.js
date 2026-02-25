const CACHE = 'mahlzeit-v2.1';
const PRECACHE_RESOURCES = [
  '/',
  'index.html',
  'mahlzeit.js',
  'assets/mahlzeit.css',
  'assets/1F35D.svg',
  'assets/bootstrap.bundle.min.js',
  'assets/bootstrap.min.css',
  'assets/jquery-4.0.0.min.js',
  'assets/xdate.js'
];

const addResourcesToCache = async (resources) => {
  const cache = await caches.open(CACHE);
  await cache.addAll(resources);
};

self.addEventListener("install", (event) => {
  console.log('The service worker is being installed.');
  event.waitUntil(
    (async () => {
      await addResourcesToCache(PRECACHE_RESOURCES);
      await self.skipWaiting();
    })(),
  );
});

const putInCache = async (request, response) => {
  const cache = await caches.open(CACHE);
  await cache.put(request, response);
};

const networkFetch = async (request) => {
  try {
    const responseFromNetwork = await fetch(request);
    if (responseFromNetwork && responseFromNetwork.ok) {
      // response may be used only once
      // we need to save clone to put one copy in cache
      // and serve second one
      putInCache(request, responseFromNetwork.clone());
    }
    return responseFromNetwork;
  } catch (error) {
    throw error;
  }
};

const cacheFirst = async (request) => {
  // First try to get the resource from the cache
  const responseFromCache = await caches.match(request);
  if (responseFromCache) {
    return responseFromCache;
  }

  // Next try to get the resource from the network
  return networkFetch(request);
};

const networkFirst = async (request) => {
  try {
    return await networkFetch(request);
  } catch (error) {
    const responseFromCache = await caches.match(request);
    if (responseFromCache) {
      return responseFromCache;
    }
    throw error;
  }
};

const deleteCache = async (key) => {
  await caches.delete(key);
};

const deleteOldCaches = async () => {
  const cacheKeepList = [CACHE];
  const keyList = await caches.keys();
  const cachesToDelete = keyList.filter((key) => !cacheKeepList.includes(key));
  await Promise.all(cachesToDelete.map(deleteCache));
};

self.addEventListener("activate", (event) => {
  event.waitUntil((async () => {
    await deleteOldCaches();
    await self.clients.claim();
  })());
});

self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }

  const url = new URL(event.request.url);
  const isSameOrigin = url.origin === self.location.origin;
  const isMenuJson = isSameOrigin && url.pathname.endsWith('/mahlzeit_v2.json');

  if (isMenuJson) {
    event.respondWith(fetch(event.request, { cache: 'no-store' }));
    return;
  }

  // Use network-first for app shell and data so deployments are reflected immediately.
  if (isSameOrigin) {
    event.respondWith(networkFirst(event.request));
    return;
  }

  event.respondWith(cacheFirst(event.request));
});
