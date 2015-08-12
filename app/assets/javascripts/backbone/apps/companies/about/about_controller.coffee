@AlumNet.module 'CompaniesApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  class About.Controller
    about: (id)->
      company = new AlumNet.Entities.Company { id: id }
      company.fetch
        success: ->
          #Se llaman el header y menu de las compañias
          layout = AlumNet.request("company:layout", company, 0)
          header = AlumNet.request("company:header", company)

          #Se crean las vistas de las regiones
          details = new About.DetailsView
            model: company
          services = new About.ServicesView
            model: company
            collection: company.servicesCollection()
          contacts = new About.ContactsView
            model: company
            collection: company.contactsCollection()
          branches = new About.BranchesView

          #Vista principal del about
          body = new About.Layout

          #Se asigna las vistas a las regiones correspondientes
          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          layout.body.show(body)

          body.details.show(details)
          body.services.show(services)
          body.contacts.show(contacts)
          body.branches.show(branches)

          #Llamada al submenu de la compañia
          AlumNet.execute('render:companies:submenu',undefined, 1)

        error: (model, response, options)->
          AlumNet.trigger('show:error', response.status)
