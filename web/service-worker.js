var CACHE = 'mahlzeit-v1.2';

const addResourcesToCache = async (resources) => {
  const cache = await caches.open(CACHE);
  await cache.addAll(resources);
};

self.addEventListener("install", (event) => {
  console.log('The service worker is being installed.');
  event.waitUntil(
    addResourcesToCache([
      '/',
      'index.html',
      'mahlzeit.js',
      'assets/1F35D.svg',
      'assets/bootstrap.bundle.min.js',
      'assets/jquery-3.6.3.min.js',
      'assets/xdate.min.js'
    ]),
  );
});

const putInCache = async (request, response) => {
  const cache = await caches.open(CACHE);
  await cache.put(request, response);
};

const networkFetch = async (request) => {
  try {
    const responseFromNetwork = await fetch(request);
    // response may be used only once
    // we need to save clone to put one copy in cache
    // and serve second one
    putInCache(request, responseFromNetwork.clone());
    return responseFromNetwork;
  } catch (error) {
    return new Response("Network error happened", {
      status: 408,
      headers: { "Content-Type": "text/plain" },
    });
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
  event.waitUntil(deleteOldCaches());
});

self.addEventListener("fetch", (event) => {
  console.log('The service worker is serving the asset.');
  response = cacheFirst(event.request);
  url = new URL(event.request.url);

  if ( url.pathname.endsWith('mahlzeit.json') ) {
    response = networkFetch(request);
  }
  event.respondWith(response);
});
