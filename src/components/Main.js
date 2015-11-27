import React, {Component, PropTypes} from 'react';

const propTypes = {
  startServer: PropTypes.func.isRequired,
};

export default class Main extends Component {
  componentDidMount() {
    this.props.startServer();
  }
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

Main.propTypes = propTypes;
