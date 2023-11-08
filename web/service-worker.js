var CACHE = 'mahlzeit-v1';

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
      'mahlzeit.json',
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

const cacheFirst = async (request) => {
  // First try to get the resource from the cache
  const responseFromCache = await caches.match(request);
  if (responseFromCache) {
    return responseFromCache;
  }

  // Next try to get the resource from the network
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

self.addEventListener("fetch", (event) => {
  console.log('The service worker is serving the asset.');
  event.respondWith(
    cacheFirst(event.request)
  );
});
