import './main.css';
import uuid from './uniqueId';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const app = Elm.Main.init({
  node: document.getElementById('root')
});

console.log(app.ports);

// app.ports.askForUniqueId.subscribe(() => {
//   console.log('Elm is asking for a unique ID.');

//   const id = uuid();

//   console.log('Sending id: ' + id);
//   app.ports.uniqueId.send(id);
// });

registerServiceWorker();
