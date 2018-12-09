import './main.css';
import uuid from './uniqueId';
import { Elm } from './Main.elm';
import { unregister } from './registerServiceWorker';

const app = Elm.Main.init({
  node: document.getElementById('root')
});

app.ports.askForUniqueId.subscribe(() => {
  const id = uuid();

  app.ports.uniqueId.send(id);
});

unregister();
