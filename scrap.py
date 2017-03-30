import requests

def join_lists(crawl_urls, obtained_urls):
    for obtained_url in obtained_urls:
        if obtained_url in crawl_urls:
            continue
        else:
            crawl_urls.append(obtained_url)
    return crawl_urls


def get_link(text):
    href_number = text.find("href=")
    if href_number == -1:
        return None, 0
    start_number = text.index('"',href_number)
    end_number = text.find('"',start_number+1)
    url = text[start_number + 1:end_number]
    return url, end_number


def get_all_links(initial_url):
    page = requests.get(initial_url)
    text = page.text
    total_url = []
    while True:
        (url,end_position) = get_link(text)
        if url == None:
            return total_url
        total_url.append(url)
        text = text[end_position:]

crawl_urls = ["https://diveintocode-crawling-sample.herokuapp.com/"]
already_crawled_urls = []
while crawl_urls:
    crawl_url = crawl_urls.pop()
    if not crawl_url in already_crawled_urls:
        obtained_urls = get_all_links(crawl_url)
        join_lists(crawl_urls, obtained_urls)
        already_crawled_urls.append(crawl_url)
        print( crawl_urls)
