require 'net/https'
require 'JSON'
require 'highline/import'
require 'colorize'
require 'open-uri'    

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
    rest.content(baseURL,userName,password)
    rest.spaces(baseURL,userName,password)
    rest.groups(baseURL,userName,password)  
    rest.audit_logs(baseURL,userName,password)
  end

end

class Restclient
  attr_reader :uri

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
      puts "===============================================".blue
      puts "           Page Title List and Page ID".blue
      puts "===============================================".blue
      json["results"].each do |results|
         print results["title"] , " || " , results["id"]
         puts
      end 
      puts "===============================================".red
      print "This Instance has ", json["size"] , " Pages"
      puts
      puts "===============================================".red
    end # End Connection

  end

  def spaces(baseURL,userName,password)
    uri = URI("#{baseURL}/rest/api/space".strip)

    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https', 
      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      request.basic_auth(userName, password)
      response = http.request request # Net::HTTPResponse object
      #Parse the Json
      json = JSON.parse(response.body)
      #Print out the Title of Spaces
      puts "===============================================".blue
      puts "           Space Name, key and type".blue
      puts "===============================================".blue
      json["results"].each do |results|
         print results["name"] , " || ", results["key"], " || " , results["type"]
         puts
      end 
      puts "===============================================".red
      print "This Instance has ", json["size"] , " Spaces in Total"
      puts
      puts "===============================================".red
    end # End Connection

  end

  def groups(baseURL,userName,password)
    groups_arr = Array.new
    uri = URI("#{baseURL}/rest/api/group".strip)
    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https', 
      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      request.basic_auth(userName, password)
      response = http.request request # Net::HTTPResponse object
      #Parse the Json
      json = JSON.parse(response.body)
      #Print out the groups
      puts "===============================================".blue
      puts "                List of Groups".blue
      puts "===============================================".blue
      json["results"].each do |results|
        groups_arr.push results["name"]
        print results["name"]
        puts
      end
      puts "===============================================".red
      print "This Instance has ", json["size"] , " Groups"
      puts
      puts "===============================================".red
    end # End Connection
    puts "===============================================".blue
    puts "                List of Users".blue
    puts "===============================================".blue
    groups_arr.each do |gp|
      users(gp,baseURL,userName,password)
    end
  end

  def users(groupName,baseURL,userName,password)
    uri = URI("#{baseURL}/rest/api/group/#{groupName}/member".strip)

    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https', 
      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      request.basic_auth(userName, password)
      response = http.request request # Net::HTTPResponse object
      #Parse the Json
      json = JSON.parse(response.body)
      #Print out the List of Users
      puts "===============================================".blue
      print " List of Users in users in group " , groupName
      puts
      puts "===============================================".blue
      json["results"].each do |results|
        print results["username"]
        puts
      end 
      puts "===============================================".red
      print "Group ", groupName, " has ", json["size"] , " Users"
      puts
      puts "===============================================".red
    end # End Connection
  end

  def audit_logs(baseURL,userName,password)
    uri = URI("#{baseURL}/rest/api/audit/".strip)

    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https', 
      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      request.basic_auth(userName, password)
      response = http.request request # Net::HTTPResponse object
      #Parse the Json
      json = JSON.parse(response.body)
      #Print out the Audit
      puts "===============================================".blue
      puts "                 Audit Logs".blue
      puts "===============================================".blue
      json["results"].each do |results|
          puts results["author"].blue
          puts results["remoteAddress"].blue
          puts
      end 

    end # End Connection
    
  end

end

Main.new.run  
