import scrapy
import re


class WikiMoviesSpider(scrapy.Spider):
    name = "wiki_movies"
    allowed_domains = ["ru.wikipedia.org"]
    start_urls = ["https://ru.wikipedia.org/wiki/Категория:Фильмы_по_алфавиту"]

    def parse(self, response):
        for href in response.css('#mw-pages .mw-category-group a::attr(href)').getall(): 
          yield response.follow(href, callback=self.parse_movie)
        next_page = response.xpath("//div[@id='mw-pages']//a[normalize-space()='Следующая страница']/@href").get()
        if next_page: 
          yield response.follow(next_page, callback=self.parse)
    
    def pick(self, info: dict, keys: list[str]):
      for k in keys:
          if k in info and info[k]:
              return info[k]
      return None
    
    def parse_movie(self, response):
      title = response.xpath("string(//h1[@id='firstHeading'])").get()
      title = title.strip() if title else None

      info = {}
      for row in response.css("table.infobox tr"):
          key = row.css("th::text").get()
          val = row.css("td").xpath("string(.)").get()
          if key and val:
              info[key.strip()] = " ".join(val.split())

      director = self.pick(info, ["Режиссёр", "Режиссёры"])
      country  = self.pick(info, ["Страна", "Страны"])
      year     = self.pick(info, ["Год"])  # сначала просто так

      # жанр: пробуем несколько вариантов (на разных страницах может отличаться)
      genre = self.pick(info, ["Жанр", "Жанры", "Жанр фильма", "Жанр(ы)"])

      # если жанра нет в инфобоксе, сделаем fallback: поиск по тексту "Жанр" в строках
      if genre is None:
          genre = response.xpath(
              "string(//table[contains(@class,'infobox')]//tr[th[contains(., 'Жанр')]]/td)"
          ).get()
          genre = " ".join(genre.split()) if genre else None

      yield {
          "title": title,
          "genre": genre,
          "director": director,
          "country": country,
          "year": year,
          "url": response.url,
      }

      def extract_year(text: str | None):
          if not text:
              return None
          m = re.search(r"(18|19|20)\d{2}", text)
          return m.group(0) if m else None
          
      def clean_text(s: str | None):
        if not s:
            return None
        s = re.sub(r"\[\d+\]", "", s)   # убирает [1], [2]...
        return " ".join(s.split())

      raw_year = self.pick(info, ["Год", "Дата выхода", "Премьера"])
      year = extract_year(raw_year)

      director = clean_text(self.pick(info, ["Режиссёр", "Режиссёры"]))
      country  = clean_text(self.pick(info, ["Страна", "Страны"]))
      genre    = clean_text(genre)
          
    

