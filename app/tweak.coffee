###
  tweak.js 0.0.0

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
###

###
  All of the modules to the source code are seperated into the following files
  The order of the merging is detirmined in the brunch-config.coffee file
 
  lib/common.coffee - commonly used functions throughout framework
  lib/helpers.coffee - helpers for the framework
  lib/events.coffee - TweakJS event system
  lib/component.coffee - TweakJS component
  lib/store.coffee - data storage functionality, where collections and models main functionality sits.
  lib/collection.coffee - TweakJS collection
  lib/components.coffee - TweakJS components wrapper
  lib/controller.coffee - TweakJS controller
  lib/model.coffee - TweakJS model
  lib/view.coffee - TweakJS view
  lib/router.coffee - TweakJS router
  lib/sync.coffee - TweakJS sync -  Wrapper for coverting component model into storable data and vice versa.
                                    TweakJS storage plugins are required for making the interactions between the storage and the model.
                                    This will allow for mass ways to communicate to storage facilities.
                                    As the model is the data holder this should be the only thing that needs to sync; to sync between model and storage a sID (the identifier) needs to be set to the model.
###

###
  There isnt any requirements to TweakJS other than a JavaScript file and module loader.
  I recomend using RequireJS for the moment in time, because that is what i have been testing and working with.
  A list of compatible module loaders will be added.
###

### Initialise tweak object to the window###
if typeof exports isnt 'undefined' then tweak = window.tweak = exports
else tweak = window.tweak = {}
