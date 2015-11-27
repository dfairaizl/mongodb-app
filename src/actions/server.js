import {ipcRenderer} from 'electron';

export const SERVER_STARTED = 'SERVER_STARTED';
export const SERVER_STOPPED = 'SERVER_STOPPED';

export const START_SERVER = 'START_SERVER';
export const STOP_SERVER = 'STOP_SERVER';

export function serverStarted(status) {
  return {
    type: SERVER_STARTED,
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
