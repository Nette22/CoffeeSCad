define (require)->
  backbone_dropbox = require './backbone.dropbox'
  vent = require 'modules/core/vent'
  
  Project = require 'modules/core/projects/project'
  
  
  class DropBoxLibrary extends Backbone.Collection
    """
    a library contains multiple projects, stored on dropbox
    """  
    model: Project
    #sync: backbone_dropbox.sync
    path: ""
    defaults:
      recentProjects: []
    
    constructor:(options)->
      super options
      #@bind("reset", @onReset)
    
    comparator: (project)->
      date = new Date(project.get('lastModificationDate'))
      return date.getTime()
      
    onReset:()->
      console.log "DropBoxLibrary reset" 
      console.log @
      console.log "_____________"
  
  class DropBoxConnector extends Backbone.Model
    defaults:
      name: "dropBoxConnector"
      storeType: "dropBox"
    
    constructor:(options)->
      super options
      @store = new backbone_dropbox()
      @isLogginRequired = true
      @loggedIn = true
      @vent = vent
      @vent.on("dropBoxConnector:login", @login)
      @vent.on("dropBoxConnector:logout", @logout)
      
      #experimental
      @lib = new DropBoxLibrary
        sync: @store.sync
      @lib.sync = @store.sync
      
    login:=>
      console.log "login requested"
      try
        onLoginSucceeded=()=>
          console.log "dropbox logged in"
          localStorage.setItem("dropboxCon-auth",true)
          @loggedIn = true
          @vent.trigger("dropBoxConnector:loggedIn")
        onLoginFailed=(error)=>
          console.log "dropbox loggin failed"
          throw error
          
        loginPromise = @store.authentificate()
        $.when(loginPromise).done(onLoginSucceeded)
                            .fail(onLoginFailed)
        #@lib.fetch()
      catch error
        @vent.trigger("dropBoxConnector:loginFailed")
        
    logout:=>
      try
        onLogoutSucceeded=()=>
          console.log "dropbox logged out"
          localStorage.removeItem("dropboxCon-auth")
          @loggedIn = false
          @vent.trigger("dropBoxConnector:loggedOut")
        onLoginFailed=(error)=>
          console.log "dropbox logout failed"
          throw error
          
        logoutPromise = @store.signOut()
        $.when(logoutPromise).done(onLogoutSucceeded)
                            .fail(onLogoutFailed)
      
      catch error
        @vent.trigger("dropBoxConnector:logoutFailed")
    
    authCheck:()->
      getURLParameter=(paramName)->
        searchString = window.location.search.substring(1)
        i = undefined
        val = undefined
        params = searchString.split("&")
        i = 0
        while i < params.length
          val = params[i].split("=")
          return unescape(val[1])  if val[0] is paramName
          i++
        null
      urlAuthOk = getURLParameter("_dropboxjs_scope")
      console.log "dropboxConnector got redirect param #{urlAuthOk}"
      
      authOk = localStorage.getItem("dropboxCon-auth")
      console.log "dropboxConnector got localstorage Param #{authOk}"

      if urlAuthOk?
        @login()
        if (!window.location.origin)
          window.location.origin = window.location.protocol+"//"+window.location.host
        bla=()->
          window.history.replaceState('', '', '/')
        #setTimeout bla, 2
        window.history.replaceState('', '', '/')
      else
        if authOk?
          @login()
      
    createProject:(options)=>
      project = @lib.create(options)
      project.createFile
        name: project.get("name")
      project.createFile
        name: "config"
        
    saveProject:(project)=>
      @lib.add(project)
      
      project.sync=@store.sync
      project.pathRoot=project.get("name") 
      
      #fakeCollection = new Backbone.Collection()
      #fakeCollection.sync = @store.sync
      #fakeCollection.path = project.get("name") 
      #fakeCollection.add(project)
      
      project.pfiles.sync = @store.sync
      project.pfiles.path = project.get("name") 
      for index, file of project.pfiles.models
        file.sync = @store.sync 
        file.pathRoot= project.get("name")
        file.save()
      
      #project.save()
      @vent.trigger("project:saved")
    
    loadProject:(projectName)=>
      console.log "dropbox loading project #{projectName}"
      project = new Project()
      project.pfiles.sync = @store.sync
      project.pfiles.path = project.get("name") 
      project.pfiles.fetch().done(()->console.log "got results back")
      #project =@lib.get(projectName)
      console.log "loaded:"
      console.log project
      return project
    
    getProjectsName:(callback)=>
      #hack
      @store.client.readdir "/", (error, entries) ->
        if error
          console.log ("error")
        else
          console.log entries
          callback(entries)
       
  return DropBoxConnector