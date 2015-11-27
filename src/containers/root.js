import React, {Component, PropTypes} from 'react';

const propTypes = {
  prop: PropTypes.object.isRequired,
};

export default class Root extends Component {
  render() {
    return (
      <main>
        <button className="settings" />
        <button className="help" />
      </main>
    );
  }
}

Root.propTypes = propTypes;
