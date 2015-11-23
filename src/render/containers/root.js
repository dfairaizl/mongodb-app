import React, {Component, PropTypes} from 'react';

const propTypes = {
  prop: PropTypes.object.isRequired,
};

export default class Root extends Component {
  render() {
    return (
      <div>Hello World</div>
    );
  }
}

Root.propTypes = propTypes;
