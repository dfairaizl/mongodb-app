import { START_SERVER, STOP_SERVER } from '../actions/server';

export default function counter(state = {}, action) {
  switch (action.type) {
  case START_SERVER:
    return Object.assign({}, state, {
      status: 'running',
    });
  case STOP_SERVER:
    return Object.assign({}, state, {
      status: 'stopped',
    });
  default:
    return state;
  }
}
