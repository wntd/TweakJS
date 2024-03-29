###
  A collection is where data can be stored, a default collection is an array based system. The model is a extension to the default collection; but based on an object.
  @todo Update pluck to use new same functionality

  @include tweak.Common.Empty
  @include tweak.Common.Events
  @include tweak.Common.Collections
  @include tweak.Common.Arrays
###
class tweak.Collection extends tweak.Store
  # @property [String] The type of storage, ie 'collection' or 'model'
  storeType: "collection"

  tweak.Extend(@, tweak.Common.Arrays)

  ###
    Removes empty keys
  ###
  clean: ->
    result = []
    for key, item of @data
      result[result.length] = item
    @data = result
  
  ###
    Construct the initial state of the collection
  ###
  construct: -> @reset()
  
  ###
    Pop the top data element in the collection
    @param [Object] options Options to detirmine extra functionality
    @option options [Boolean] store Decide whether to store the change to the history. Default: true
    @option options [Boolean] quiet Decide whether to trigger collection events. Default: false

    @event #{@name}:#{@storeType}:removed:#{key} Triggers an event based on what property has been removed
    @event #{@name}:#{@storeType}:changed Triggers a generic event that the collection has been updated
    @return [*] Returns the data that was removed
  ###
  pop: (options = {}) ->
    result = @data[@length-1]
    @remove result, options
    result
  
  ###
    Add a new property to the end of the collection
    @param [*] data Data to add to the end of the collection
    @param [Object] options Options to detirmine extra functionality
    @option options [Boolean] store Decide whether to store the change to the history. Default: true
    @option options [Boolean] quiet Decide whether to trigger collection changed events. Default: false

    @event #{@name}:#{@storeType}:changed:#{key} Triggers an event and passes in changed property
    @event #{@name}:#{@storeType}:changed Triggers a generic event that the collection has been updated
  ###
  add: (data, options = {}) -> @set "#{@length}", data, options
  
  ###
    Inserts a new property into a certain position
    @param [*] data Data to insert into the collection
    @param [Number] position The position to insert the property at into the collection

    @param [Object] options Options to detirmine extra functionality
    @option options [Boolean] store Decide whether to store the change to the history. Default: true
    @option options [Boolean] quiet Decide whether to trigger collection changed events. Default: false

    @event #{@name}:#{@storeType}:changed:#{key} Triggers an event and passes in changed property
    @event #{@name}:#{@storeType}:changed Triggers a generic event that the collection has been updated
  ###
  place: (data, position, options = {}) ->
    options.data = options.data or {}
    quiet = @options.quiet
    store = if options.store? then true else false
    result = []
    for prop in @data
      if position is _i then break
      result.push @data[_i]
    result.push data
    for data in @datas
      if _j < position then continue
      result.push @data[_j]
    @data = result
    if store then @store()
    if not quiet
      @trigger "#{@name}:#{@storeType}:changed"
      @trigger "#{@name}:#{@storeType}:changed:#{position}"
    return
  
  ###
    Looks through the collection for where the data matches.
    @param [*] property The property data to find a match against.
    @return [Array] Returns an array of the positions of the data.
  ###
  pluck: (property) ->
    result = []
    for key, prop of @data
      if prop is property then result.push key
    result

  ###
    Remove a single property or many properties.
    @param [String, Array<String>] properties Array of property names to remove from collection, or single String of the name of the property to remove
    @param [Object] options Options to detirmine extra functionality
    @option options [Boolean] store Decide whether to store the change to the history. Default: true
    @option options [Boolean] quiet Decide whether to trigger collection events. Default: false

    @event #{@name}:#{@storeType}:removed:#{key} Triggers an event based on what property has been removed
    @event #{@name}:#{@storeType}:changed Triggers a generic event that the collection has been updated
  ###
  remove: (properties, options = {}) ->
    store = if options.store? then true else false
    quiet = options.quiet
    if typeof properties is 'string' then properties = [properties]
    for property in properties
      delete @data[property]
      @trigger "#{@name}:#{@storeType}:removed:#{property}"
    
    @clean()
    if store then @store()
    if not quiet then @trigger "#{@name}:#{@storeType}:changed"
    return

  ###
    Get an element at position of a given number
    @param [Integer] position Position of property to return
    @return [*] Returns data of property by given position
  ###
  at: (position) -> @data[Number(position)]

  ###
    Reset the collection back to defaults
  ###
  reset: ->
    @data = []
    @history = []