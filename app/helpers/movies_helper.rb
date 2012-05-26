module MoviesHelper
  def common_trope_links(common_tropes)
    raw common_tropes.map { |trope| link_to trope.name, trope }.join(', ')
  end
end
