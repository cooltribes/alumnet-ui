@AlumNet.module 'AdminApp.CategoriesList', (CategoriesList, @AlumNet, Backbone, Marionette, $, _) ->
	class CategoriesList.Controller
		categoriesList: ->
			categories = AlumNet.request('categories:entities', {})
			layoutView = new CategoriesList.Layout
			categoriesTable = new CategoriesList.CategoriesTable
				collection: categories

			AlumNet.mainRegion.show(layoutView)
			layoutView.table.show(categoriesTable)
			AlumNet.execute('render:admin:categories:submenu', undefined, 0)

		create: ->
			layoutView = new CategoriesList.Layout
			category = new AlumNet.Entities.Category
			createForm = new CategoriesList.CreateForm
        model: category

			AlumNet.mainRegion.show(layoutView)
			layoutView.table.show(createForm)
			AlumNet.execute('render:admin:categories:submenu', undefined, 1)