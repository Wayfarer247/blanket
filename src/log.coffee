'use strict'

winston = require 'winston'

level = process.env.WINSTON or 'error'

log = new (winston.Logger)({
  transports: [
    new winston.transports.Console
      level: level
      colorize: yes
      json: no
      prettyPrint: yes
      timestamp: yes
      label: process.pid
  ]
})

module.exports = log
