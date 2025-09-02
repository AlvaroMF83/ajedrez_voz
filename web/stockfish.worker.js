/* Web Worker que envuelve stockfish.js/wasm (UCI por mensajes) */
self.onmessage = (e) => {
  const { type, payload } = e.data || {};
  if (type === 'load') {
    importScripts(payload.url); // p.ej. engine/stockfish.js
    self.engine = self.STOCKFISH ? self.STOCKFISH() : self.stockfish();
    self.engine.onmessage = (line) => {
      const msg = typeof line === 'string' ? line : (line?.data || '');
      self.postMessage({ type: 'line', payload: msg });
    };
    self.postMessage({ type: 'ready' });
    return;
  }
  if (type === 'cmd' && self.engine) {
    self.engine.postMessage(payload); // UCI
  }
};