// Chatbot Service Worker — cache-busting for Angular class list refresh
// Intercepts classSummaries/dtls/rules/bpls requests and serves fresh data on demand

var bustNext = false;

self.addEventListener('message', function(event) {
  if (event.data && event.data.type === 'bust-cache') {
    bustNext = true;
    // Also proactively clear any cached responses for class list endpoints
    caches.keys().then(function(names) {
      names.forEach(function(name) {
        caches.open(name).then(function(cache) {
          cache.keys().then(function(requests) {
            requests.forEach(function(req) {
              if (req.url.indexOf('classSummaries') !== -1 ||
                  req.url.indexOf('/dtls') !== -1 ||
                  req.url.indexOf('/rules') !== -1 ||
                  req.url.indexOf('/bpls') !== -1 ||
                  req.url.indexOf('/productions') !== -1) {
                cache.delete(req);
              }
            });
          });
        });
      });
    });
  }
});

self.addEventListener('fetch', function(event) {
  var url = event.request.url;
  var isClassList = url.indexOf('classSummaries') !== -1 ||
                    url.indexOf('/dtls') !== -1 ||
                    url.indexOf('/rules') !== -1 ||
                    url.indexOf('/bpls') !== -1 ||
                    url.indexOf('/productions') !== -1;

  if (isClassList && bustNext) {
    bustNext = false;
    // Fetch from network, bypassing all caches
    event.respondWith(
      fetch(event.request.url, {
        method: event.request.method,
        headers: event.request.headers,
        cache: 'no-store'
      })
    );
    return;
  }

  // All other requests pass through normally
});
