#Nuvi Coding Challenge

Download multiple zip files, extract out the xml files, and publish the content of each xml file to a redis list called “NEWS_XML”.

###Installation

You must have redis installed to run this app. You can download redis [here](https://redis.io/download).

You can fork or clone the repository and then run `bundle install`.

To download and extract zip files from a different site change `base_url` in `main.rb` to be destination url.

### Explanation

I used the gems `nokogiri` and `rubyzip` to help with downloading and processing the zip and xml files. I also used the `redis` gem, a redis ruby client, to simplify creating and saving data to a redis data structure. I created a redis set with a key `"NEWS_XML_CHECK"` to prevent duplicate entries and a redis list with a key `"NEWS_XML"` to actually save the xml document.

By Valorie Dodge
