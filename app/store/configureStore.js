import {createStore, applyMiddleware} from 'redux';
import thunk from 'redux-thunk';
import reducers from '../reducers';

const createStoreWithMiddleware = applyMiddleware(thunk)(createStore);

export default function configureStore(initialState = {}) {
  const store = createStoreWithMiddleware(reducers, initialState);

  return store;
}
