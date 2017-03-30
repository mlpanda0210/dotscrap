class Course < ApplicationRecord

  def self.dotscrap
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
  end



  def self.join_lists(crawl_urls_texts, obtained_urls_texts)
    for obtained_url_text in obtained_urls_texts do
      if crawl_urls_texts.values.include?(obtained_url_text[1])
        next
      else
        hash = Hash[*obtained_url_text]
        crawl_urls_texts = crawl_urls_texts.merge(hash)
      end
    end

    return crawl_urls_texts
  end

  def get_link(text)
    href_number = text.index("href=")
    if href_number == nil
      return None, 0
    end
    start_number = text.index('"',href_number)
    end_number = text.index('"',start_number+1)
    url = text[start_number + 1,end_number]
    return url, end_number
  end

  def self.change_search_url(initial_text,search_url_text,search_text)
    agent = Mechanize.new
    url = search_url_text[initial_text]
    page= agent.get(url)
    form = page.form
    page.form.fields[0].value = search_text
    next_page = form.click_button
    next_mlinks = next_page.links
    for next_mlink in next_mlinks do
      if next_mlink.href.include?("&sort=created_desc")
        url = next_mlink.href
        text = next_mlink.text
      end
    end
    return url,text
  end

  def self.get_all_links(crawl_url_text,initial_url,search_text)
    total_urls = {}
    agent = Mechanize.new
    page= agent.get(crawl_url_text[1])
    mlinks = page.links
    for mlink in mlinks do
      url = mlink.href
      text = mlink.text.strip.gsub(" ", "").chomp
      unless url == nil
          if url.include?(initial_url)
            unless url.include?("/ics/")
              if url.include?("/event/")
                total_urls[text] = url
              end
            end
        end
      end
    end
    return total_urls
  end

  def self.record_already_crawled_urls(urls)
    Course.delete_all
    for url in urls do
      course = Course.new
      course.topic = url[0].strip.gsub(" ", "").chomp
      course.url = url[1]
      event_date, event_place, event_description = Course.analysis_url(url[1])
      course.date = event_date
      course.address =  event_place
      course.place = event_description
      course.save
    end
  end

  def self.analysis_url(url)
    doc = Nokogiri::HTML(open(url),nil,"utf-8")
    event = doc.at_css('//meta[name="description"]/@content').value.split(' ')
    event_date = event[0]
    event_place = event[1]
    event_description = event[2]
    return event_date, event_place, event_description
  end
end
