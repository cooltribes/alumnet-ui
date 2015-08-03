@AlumNet.module 'CompaniesApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  class About.Controller
    showAbout: ->

      

      #Se llaman el header y menu de las compañias
      layout = AlumNet.request("company:layout",0)
      header = AlumNet.request("company:header")

      #Se crean las vistas de las regiones
      details = new About.details
      contact_web = new About.contact_web      
      branches = new About.branches

      #Vista principal del about
      body = new About.View

      #Se asigna las vistas a las regiones correspondientes
      AlumNet.mainRegion.show(layout)
      layout.header.show(header)
      layout.body.show(body)

      body.details.show(details)
      body.contact_web.show(contact_web)
      body.branches.show(branches)

      #Llamada al submenu de la compañia
      AlumNet.execute('render:company:submenu',undefined, 1)