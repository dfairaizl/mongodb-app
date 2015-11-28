import {ipcRenderer} from 'electron';
import * as ServerTypes from '../constants/ServerTypes';

export function serverStarted(status) {
  return {
    type: ServerTypes.SERVER_STARTED,
    status: status,
  };
}

export function startServer() {
  console.log('renderer - starting server');
  return dispatch => {
    return ipcRenderer.send('start-server', (status) => {
      dispatch(serverStarted(status));
    });
  };
}
