require 'rubygems'
require 'open-uri'
require 'zip'
require 'nokogiri'
require 'redis'
require 'fileutils'

redis = Redis.new
#Access all zip files extensions from URL
base_url = "http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/"
doc = Nokogiri::HTML(open(base_url))
links = doc.css('a').map { |link| link['href'] }
#Create array to store zip file extensions
zip_files = []
#Select only the links that end in .zip
links.each do |m|
  if m.end_with? ".zip"
   zip_files << m
  end
end

#Create temporary folder for xml files
Dir.mkdir "xml_files" unless File.exists?("xml_files")

#Open each zip file extension and extract the xml files to save to redis
zip_files.each do |zip_file|
  url = "http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/" + zip_file
  zipfilename = open(url)
  Zip::File.open(zipfilename.path) do |xml_file|
    # Handle entries one by one
    xml_file.each do |entry|
      name = entry.name
      # Extract to file/directory/xml_files/xml_file_name
      puts "Extracting " + name
      entry.extract("xml_files/#{name}")
      #Use the xml file extension to check for duplicates
      check = redis.sismember("NEWS_XML_CHECK", name)
      #if xml file extension is not in control set, add xml to control set and document to list
      if check == false
        doc = File.open("xml_files/#{name}") { |f| Nokogiri::XML(f) }
        redis.sadd("NEWS_XML_CHECK", name)
        redis.rpush("NEWS_XML", doc)
      end
    end
  end
end

#Delete temporary folder for xml files
FileUtils.rm_rf('xml_files')
