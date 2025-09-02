// web/engine/stockfish.worker.js

// Guardamos el postMessage "real" al padre para que el motor no lo pise
const parentPost = self.postMessage.bind(self);

// Señalizamos dónde está el .wasm (mismo directorio que stockfish.js)
self.Module = {
  locateFile: (path) => `engine/${path}`,
};

let engineOnMessage = null;
let ready = false;

// Reemplazamos postMessage para capturar TODO lo que el motor envíe al padre
function hookEngineOutput() {
  self.postMessage = function (msg) {
    // Stockfish suele enviar cadenas; las envolvemos para Dart:
    if (typeof msg === 'string') {
      // reenviamos cada línea
      parentPost({ type: 'line', payload: msg });

      // detectamos "uciok" para marcar ready
      if (!ready && msg.indexOf('uciok') >= 0) {
        ready = true;
        parentPost({ type: 'ready' });
      }
    } else {
      // por si la build enviara objetos, los pasamos igualmente
      parentPost({ type: 'line', payload: msg });
    }
  };
}

// Escuchamos los mensajes que vienen de DART → wrapper
self.addEventListener('message', function (e) {
  const data = e.data || {};
  const type = data.type;
  const payload = data.payload;

  // 1) Cargar el motor
  if (type === 'load' && payload && payload.url) {
    try {
      // Cargamos el script del motor
      importScripts(payload.url);

      // Guardamos el handler del motor (el engine suele asignar self.onmessage)
      engineOnMessage = self.onmessage;

      // Hook de salida (lo ponemos DESPUÉS de importScripts)
      hookEngineOutput();

      // Ahora nosotros gestionamos los mensajes de la app:
      self.onmessage = function (evt) {
        const d = evt.data || {};
        if (d.type === 'cmd' && typeof d.payload === 'string') {
          // Reenviamos el comando al motor como cadena:
          // El motor espera { data: '...' }
          engineOnMessage && engineOnMessage({ data: d.payload });
        }
      };

      // Lanzamos el handshake UCI
      engineOnMessage && engineOnMessage({ data: 'uci' });
      // (Opcional) también puedes probar 'isready' más tarde desde Dart

    } catch (err) {
      parentPost({ type: 'line', payload: `wrapper load error: ${err}` });
    }
    return;
  }

  // 2) Comandos normales (si llegaran aquí antes del load, se ignoran)
  if (type === 'cmd' && typeof payload === 'string') {
    engineOnMessage && engineOnMessage({ data: payload });
    return;
  }
});
