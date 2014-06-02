ARGV.each do|project|
  puts "Argument: #{project}"
end

project='jarvis'
local_store='W:\\' + project + '\\'
remote_store='/www.seagoj.com/web/content/' + project +'/'
archive=remote_store+'archive/'

def archive(remote_store)
  require 'net/ftp'
  ftp=Net::FTP.new
  ftp.connect('ftp.seagoj.com',21)
  ftp.login('seagoj','Onthesigs1845')
  ftp.chdir(remote_store)
  remote_list = ftp.nlst(remote_store)
  archive = remote_store+'archive/'
  
  ftp.mkdir(archive)
  
  remote_list.each do |remote_file|
    if(remote_file.index('archive')== nil)
      ftp.rename(remote_file, archive + File.basename(remote_file))
      puts File.basename(remote_file)+' moved successfully.'
    else
      puts 'Skipping archive directory.'
    end
  end
  ftp.close
end
def upload(local_store, remote_store)
  require 'net/ftp'
  ftp=Net::FTP.new
  ftp.connect('ftp.seagoj.com',21)
  ftp.login('seagoj','Onthesigs1845')
  ftp.chdir(remote_store)
  Dir.chdir(local_store)
  local_list = Dir.entries(local_store)
  remote_list = ftp.nlst(remote_store)

  exclude = ['.','..','nbproject','.git','.gitmodules']
  local_list.each do |local_file|
    if(exclude.include?(local_file))
      puts 'EXCLUDED: '+local_file
    else
      if(File.directory?(local_file))
        puts 'CREATING: '+remote_store+local_file
        ftp.mkdir(remote_store+local_file)
        upload(local_store+local_file, remote_store+local_file)
      else
        puts 'UPLOADING: '+local_file+' to '+remote_store+local_file
        ftp.put(local_file, remote_store+local_file)
      end
    end
  end
  ftp.close
end
def delete(path)
  require 'net/ftp'
  ftp=Net::FTP.new
  ftp.connect('ftp.seagoj.com',21)
  ftp.login('seagoj','Onthesigs1845')
  ftp.chdir(path)
  remote_list = ftp.nlst(path)

  remote_list.each do |remote_file|
    puts remote_file
    begin
      ftp.delete(remote_file)
      puts remote_file+' deleted'
    rescue Exception => e
      #puts e
      begin
        ftp.rmdir(remote_file)
        puts remote_file+' deleted'
      rescue
        #puts e
        puts 'RECURSE with '+remote_file
        delete remote_file
      end
    end
  end

=begin
  remote_list.each do |remote_file|
    puts 'Checking if '+remote_file+' is a directory'
    begin
      ftp.chdir(remote_file+'/..')
      # puts ftp.pwd
      puts remote_file+' is a directory'
      delete remote_file
      # ftp.chdir('..')
    rescue Exception => e
      puts e
      puts remote_file+' is not a directory'
      ftp.delete(remote_file)
      puts remote_file+' deleted.'
    end
  end
  ftp.rmdir(path)
=end

  ftp.close
end
def push(local_store)
  require 'grit'
  include Grit
  repo = Repo.new("git@github.com:seagoj/jarvis.git")

  puts repo.commits
end


#delete archive
#archive remote_store
upload local_store, remote_store
#push local_store

# puts ftp.sendcmd('ls')

puts "EOF"