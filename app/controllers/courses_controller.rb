class CoursesController < ApplicationController
  def index
    agent = Mechanize.new
    initial_url = "https://eventdots.jp"
    initial_text = "initial"
    search_url_text = {initial_text => initial_url}
    search_text = "機械学習"
    crawl_urls_texts = {}
    search_url,search_text = Course.change_search_url(initial_text,search_url_text,search_text)
    crawl_urls_texts.store(search_text,search_url)
    already_crawled_urls_texts = {}
    while crawl_urls_texts.present?
      crawl_url_text = crawl_urls_texts.shift
      unless already_crawled_urls_texts.has_value?(crawl_url_text[1])
        obtained_urls_texts = Course.get_all_links(crawl_url_text,initial_url,search_text)
        # crawl_urls_texts = Course.join_lists(crawl_urls_texts, obtained_urls_texts)
        # hash = Hash[*crawl_url_text]
        already_crawled_urls_texts = already_crawled_urls_texts.merge(obtained_urls_texts)
      end
    end
    Course.record_already_crawled_urls(already_crawled_urls_texts)
    @outputs = Course.search(:date_cont => '日時：').result
    binding.pry
  end
end
