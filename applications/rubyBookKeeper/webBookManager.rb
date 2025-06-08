# BIM_web.rb

require 'date'
require 'sqlite3'
require 'webrick'
require 'erb'

class BookInfoManager
  def initialize(db_file = "book_info.sqlite3")
    @db_file = db_file
    @db = SQLite3::Database.new(@db_file)
    @db.results_as_hash = true
    encSQL = 'PRAGMA encoding = "UTF-8";'
    ctSQL = <<~SQL
      CREATE TABLE IF NOT EXISTS BOOK_INFO (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        TITLE VARCHAR(50),
        AUTHOR VARCHAR(50),
        PAGES INTEGER,
        PUBLISH_DATE DATE
      );
    SQL
    @db.execute encSQL
    @db.execute ctSQL
    
    @config = {
      Port: 8080,
      DocumentRoot: '.'
    }
    @server = WEBrick::HTTPServer.new(@config)
    trap(:INT) do
      @server.shutdown
    end

    setupRoutes
  end

  def setupRoutes
    @server.mount_proc '/' do |req, res|
      db = SQLite3::Database.new('book_info.sqlite3')
      db.results_as_hash = true
      @books = []
      db.execute('SELECT * FROM BOOK_INFO') do |row|
        @books << {
          id: row['ID'],
          title: row['TITLE'].dup.force_encoding('UTF-8'),
          author: row['AUTHOR'].dup.force_encoding('UTF-8'),
          pages: row['PAGES'],
          pubDate: row['PUBLISH_DATE']
        }
      end
      db.close
      res.body = ERB.new(File.read('list.erb')).result(binding)
    end

    @server.mount_proc '/books' do |req, res|
      db = SQLite3::Database.new('book_info.sqlite3')
      db.execute(
        'INSERT INTO BOOK_INFO (TITLE, AUTHOR, PAGES, PUBLISH_DATE) VALUES (?, ?, ?, ?)',
        [
          req.query['title'].dup.force_encoding('UTF-8'),
          req.query['author'].dup.force_encoding('UTF-8'),
          req.query['pages'],
          req.query['pub_date']
        ]
      )
      db.close
      res.set_redirect(WEBrick::HTTPStatus::TemporaryRedirect, '/')
    end

    @server.mount_proc '/books/delete' do |req, res|
      db = SQLite3::Database.new('book_info.sqlite3')
      db.execute('DELETE FROM BOOK_INFO WHERE ID = ?',
        [req.query['id'].force_encoding("UTF-8").to_i])
      db.close
      res.set_redirect(WEBrick::HTTPStatus::TemporaryRedirect, '/')
    end
    
    @server.mount_proc '/books/edit' do |req, res|
      id = req.query["id"]
      title = ""
      author = ""
      pages = 0
      pub_date = ""
      db = SQLite3::Database.new('book_info.sqlite3')
      sql = "SELECT * FROM BOOK_INFO WHERE ID = ?"
      db.execute(sql, [id.to_i]) do |row|
        #row[n], n = 0: id, 1: title, 2: author, 3: pages, 4: publishDate
        title = row[1].dup.force_encoding('UTF-8')
        author = row[2].dup.force_encoding('UTF-8')
        pages = row[3]
        pub_date = row[4]
      end
      db.close
      res.body = ERB.new(File.read('edit.erb')).result(binding)
    end

    @server.mount_proc "/books/update" do |req, res|
      db = SQLite3::Database.new('book_info.sqlite3')
      db.execute(
        "UPDATE BOOK_INFO SET TITLE = ?, AUTHOR = ?, PAGES = ?, PUBLISH_DATE = ? WHERE ID = ?",
        [
          req.query["title"].dup.force_encoding('UTF-8'),
          req.query["author"].dup.force_encoding('UTF-8'),
          req.query["pages"].to_i,
          req.query["pub_date"],
          req.query["id"].to_i
        ]
      )
      db.close
      res.set_redirect(WEBrick::HTTPStatus::TemporaryRedirect, '/')
    end

  end

  def start
    @server.start
  end
end


bim = BookInfoManager.new
bim.start
