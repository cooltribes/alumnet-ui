# Extending Underscore
# ---
# This file contains all new functions for undescore, we can create and add
# new utility functions for use in the entire app.

# these are called mixins (new features) for Underscore.js
# go to for more info about extending underscore http://underscorejs.org/#mixin

# NRamirez

_.mixin
  capitalize: (string)->
    string.charAt(0).toUpperCase() + string.substring(1).toLowerCase()
  

