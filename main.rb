require 'rubygems'
require 'open-uri'
require 'zip'
require 'nokogiri'
require 'redis'
require 'fileutils'
require 'net/http'

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

##### Try One ########
# input = open("http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/1481953941683.zip").body
# Zip::InputStream.open(StringIO.new(input)) do |io|
#   while entry = io.get_next_entry
#     puts entry.name
#     parse_zip_content io.read
#   end
# end

##### Try Two ########
# url = "http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/1481953941683.zip"
# uri = URI.parse(url)
# req = Net::HTTP::Get.new(uri.path)
# filename = './test.zip'
#
# # download the zip
# File.open(filename,"wb") do |file|
#   Net::HTTP.start(uri.host, uri.port) do |http|
#     http.get(uri.path) do |str|
#       file.write str
#     end
#   end
# end

##### Try Three ########
# uri = URI('http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/1481953941683.zip')
# Net::HTTP.start(uri.host, uri.port) do |http|
#   request = Net::HTTP::Get.new uri
#   response = http.request request # Net::HTTPResponse object
#   p response
# end
#
#   http.request request do |response|
#     open '1481953941683.zip', 'w' do |io|
#       response.read_body do |chunk|
#         io.write chunk
#       end
#     end
#   end
# end
# url = 'http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/1481953941683.zip'
# zipfilename = open(url)

##### Try To Read new ZipFile ########
# Zip::ZipFile.open(zipfilename) do |zip|
#   # zip.each { |entry| p entry.get_input_stream.read } # show contents
#   zip.each { |entry| p entry.name } # show the name of the files inside
# end


#Create temporary folder for xml files
Dir.mkdir "xml_files" unless File.exists?("xml_files")

##### Try Four - Where I would really like to use it ########
# zip_files.each do |zip_file|
#   url = "http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/" + zip_file
#   zipfilename = open(url)
  # Zip::File.open(zipfilename.path) do |xml_file|


  ##### Here I have just downloaded one of the zip files myself to implement the rest of the code ########
  Zip::File.open("#{Dir.pwd}/1481966378542.zip") do |xml_file|
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
# end

#Delete temporary folder for xml files
FileUtils.rm_rf('xml_files')
