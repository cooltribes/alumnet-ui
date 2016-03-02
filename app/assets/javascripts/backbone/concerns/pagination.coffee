# This is to handle the collection from response. If the collection has the key
# with the information about pagination then it asign the data to the collection.
# Armando

Backbone.Collection.prototype.parse = (response)->
  if response.pagination?
    this.nextPage = response.pagination.next_page
    this.prevPage = response.pagination.prev_page
    this.currentPage = response.pagination.current_page
    this.totalPages = response.pagination.total_pages
    this.totaCount = response.pagination.total_count
    return response.data
  else
    return response