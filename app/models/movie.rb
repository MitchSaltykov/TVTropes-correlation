class Movie < ActiveRecord::Base
  scope :by_name, :order => :name
  has_many :movie_tropes, :dependent => :destroy
  has_many :tropes, :through => :movie_tropes, :autosave => true

  validates_presence_of :name, :url
  validates_uniqueness_of :url

  EMPTY_PAGE_TEXT = 'Click the edit button to start this new page.'

  def correlation(other)
    minimum_trope_count = [tropes.size, other.tropes.size].min
    minimum_trope_count == 0 ? 0 : (tropes & other.tropes).size.to_f / minimum_trope_count
  end

  def self.create_from_url(url)
    movie = Movie.new
    movie.url = url

    begin
      page = Nokogiri::HTML(open(url))
      name = page.search('.pagetitle span').first.content
      movie.name = name
      wikitext = page.search('#wikitext')

      if wikitext && wikitext.children.first.text.strip == EMPTY_PAGE_TEXT
        empty_page = true
      else
        trope_urls = page.css('div#wikitext ul > li > a.twikilink').map { |link| link['href'] }.uniq
        tropes = trope_urls.map do |trope_url|
          trope = Trope.find_or_initialize_by_url(trope_url)
          trope.name = trope_url.split('/').last.underscore.titleize

          trope
        end
        movie.tropes = tropes.sort_by(&:name)
        movie.save
      end
    rescue => e
      movie.errors[:base] << e.message
    end

    [movie, empty_page]
  end

end
