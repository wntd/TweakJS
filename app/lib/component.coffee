### 
  ----- COMPONENT -----
  TweakJS has its own unique twist to the MVC concept. 

  The future of MVC doesnt always lie in web apps; the architecture to TweakJS allows for intergration of components anywhere on a website
  For example you can plug "Web Components" into your static site; like sliders, accordians.
  The flexibity is endless; allowing MVC to be used from small web components to full scale one page web apps. 
  
  TweakJS wraps its Models, Views, Templates, and Controllers into a component module.
  The component module acts inteliigently to build up your application with simple config files. 
  Each component its built through a config object; this allows for powerfull configuration with tonnes of flexibity.

  Each component can have sub components which are accessible in both directions; although it is recommended to keep functionality seperate
  it sometimes comes in handy to have access to other parts of the application.

  Each component can extend another component, which will then inheret the models, views, templates, and controllers directly from that component. 
  If you however want to extend a component yet using a different Model you can simply overrite that model, or extend the functionality to the components model.
  
  The config objects are extremely handy for making components reusable, with easy accessable configuration settings.

###

class tweak.Component   
  constructor: (relation, name) ->   
    # Build relation if window and build its default properties
    # The relation is it direct caller
    relation = @relation = if relation is window then {} else relation
    relation.relation ?= {}
    # Get parent component
    @parent = if relation instanceof tweak.Components then relation.relation else relation
    # Set name of component
    @name = name or ""

    @config = @buildConfig() or {}

    # The config file can prevent automatic build and start of componets      
    if not @config.preventStart
      # Start the construcion of the component
      @start()


  tweak.Extend(@, ['require', 'findModule', 'trigger', 'on', 'off', 'clone', 'same', 'combine', 'splitComponents', 'relToAbs', 'buildModule', 'init'], tweak.Common)
  ### 
    Description:
      Builds the config component
      It inteligently iherits modules, and configuartion settings from its extending components
  ###
  buildConfig: ->  
    configs = []    
    paths = @paths = []
    # Gets all configs, by configs extension path
    config = @name
    while config
      requested = @require "#{config}/config"
      # Store all the paths
      paths.push config
      # Push a clone of the config file to remove reference
      configs.push @clone(requested)
      config = requested.extends

    # Combine all the config files into one
    # The values of the config files from lower down the chain have piortiy
    result = configs[configs.length-1]
    for i in [configs.length-2..0]
      result = @combine(result, configs[i])

    # Set initial values in config if they do not exist
    result.model ?= {}
    result.view ?= {}
    result.controller ?= {}
    result.components ?= []
    result.events ?= {}
    result

  ### 
    Description:
      This initiates the construction and initialisation of the component. 
  ###
  start: ->
    @construct()
    @init()
    @models.init()
    for item in @models.data
      item.init()
    @components.init()
    @controllers.init()    
    for item in @controllers.data
      item.init()
    if @router?
      @router.init()

  ###
    Shortcut function to adding view
  ###
  addViews: (params...) -> @buildModule("view", tweak.View, params...)

  ###
    Shortcut function to adding Model
  ###
  addModels: (params...) -> @buildModule("model", tweak.Model, params...)

  ###
    Shortcut function to adding controller
  ###
  addControllers: (params...) -> @buildModule("controller", tweak.Controller, params...)

  ###
    Shortcut function to adding components
  ###
  addComponents: (params...) -> @buildModule("components", tweak.Components, params...)

  ###
    Shortcut function to adding router
  ###
  addRouter: (params...) -> @buildModule("router", tweak.Router, params...)

  ###
    Constructs the component and its modules
  ###
  construct: ->
    # Router is optional as it is perfomance heavy
    # So it needs to be explicility defind in the config for the component that it should be used
    if @config.router 
      @addRouter()

    # Add modules to the component
    @addModels()
    @addViews() 
    @addComponents()
    @addControllers()
    
    # Add references to the the main collections and modules
    refs = ["models", "views", "controllers", "components", "router"]
    for module in refs
      prop = @[module]
      for item in refs
        if module is item then continue
        if prop? then prop[item] = @[item]

    # Construct the modules after they have been added
    @models.construct()
    @views.construct()
    @components.construct()
    @controllers.construct()
    if @router?        
      @router.construct()
    
    true
    

  ###
    Renders itself and its subcomponents
    It has a built in component:ready event trigger; this allows you to perform your logic once things are defiantly ready
  ###
  render: ->
    @on("#{@name}:views:rendered", =>
      @on("#{@name}:components:ready", => @trigger("#{@name}:ready", @name))        
      @components.render()
    )     
    @views.render()

  ###
    Renders itself and its subcomponents
    It has a built in component:ready event trigger; this allows you to perform your logic once things are defiantly ready
  ###
  rerender: ->
    @on("#{@name}:views:rendered", =>
      @on("#{@name}:components:ready", => @trigger("#{@name}:ready", @name))
      @components.rerender() 
    )     
    @views.rerender()    
  
  ### 
    Parameters:   co:Object
    Description:  Destroy this component. It will clear the view if it exists; and removes it from collection if it is part of one
  ###
  destroy: (options = {}) ->
    @views.clear()
    components = @relation.components
    if components? then components.remove @name, options
    return