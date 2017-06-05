require 'net/https'
require 'JSON'
require 'highline/import'
require 'colorize'

class Main
  attr_reader :rest,
  :baseURL

  def initialize(rest = Restclient.new)
    @rest = rest
  end

  def run
    puts "==============================================".red
    puts "            Confluence Sumary Generator       ".red
    puts "==============================================".red
    baseURL = ask("what is URL: ")
    userName = ask("Please Enter your User Name: ")
    password = ask("Please Enter your Password: ") {|q| q.echo = '*'}
    puts "===============================================".red

    #rest.groups(baseURL,userName,password)
    #rest.content(baseURL,userName,password)
  
  end

end

class Restclient
  attr_reader :uri

# Implement a Auth method
#  def basicauth()
#  end

  def content(baseURL,userName,password)
    uri = URI("#{baseURL}/rest/api/content".strip)

    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https', 
      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      request.basic_auth(userName, password)
      response = http.request request # Net::HTTPResponse object
      #Parse the Json
      json = JSON.parse(response.body)
      #Print out the Title of Pages
      json["results"].each do |results|
      print results["title"] , "||" , results["id"]
      puts
      end 
      puts "=======================================".red
      print "This Instance has ", json["size"] , " Pages"
      puts
      puts "=======================================".red
    end # End Connection

  end

  def groups(baseURL,userName,password)
    uri = URI("#{baseURL}/rest/experimental/group".strip)
      Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https', 
      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      request.basic_auth(userName, password)
      response = http.request request # Net::HTTPResponse object
      #Parse the Json
      json = JSON.parse(response.body)
      #Print out the Title of Pages
      json["results"].each do |results|
      print results["name"]
      puts
      end
      puts "=======================================".red
      print "This Instance has ", json["size"] , " Groups"
      puts
      puts "=======================================".red
    end # End Connection

  end

  # Work in Progress
  def users(baseURL,userName,password)
    uri = URI("#{baseURL}/rest/api/group/confluence-administrators/member".strip)
  end

end

Main.new.run  
