#Nuvi Coding Challenge
##Download multiple zip files, extract out the xml files, and publish the content of each xml file to a redis list called “NEWS_XML”

I used the gems `nokogiri` and `rubyzip` to help with downloading and processing the zip and xml files. I also used the `redis ruby client` to simplify creating and saving data to a redis data structure.
