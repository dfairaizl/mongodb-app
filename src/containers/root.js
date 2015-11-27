import React, {Component, PropTypes} from 'react';

const propTypes = {
  prop: PropTypes.object.isRequired,
};

export default class Root extends Component {
  render() {
    return (
      <main>
        <div className="logo" ref="logo" />
        <div className="controls">
          <button className="settings" />
          <button className="help" />
        </div>
      </main>
    );
  }
}

Root.propTypes = propTypes;
