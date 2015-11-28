import { combineReducers } from 'redux';
import server from './server';

const rootReducer = combineReducers({
  server,
});

export default rootReducer;
