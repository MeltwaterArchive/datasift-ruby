require './auth'

class DynamicListReplaceApi < DataSiftExample
  def initialize
    super
    run
  end

  def run
    begin

      puts "\nCreating a dynamic list: /list/create"
      list = @datasift.dynamic_list.create('text', 'My dynamic list')
      puts list

      id = list[:data][:id]

      puts "\nStart a new replace list: /list/replace/start"
      replace = @datasift.dynamic_list_replace.start id
      puts replace

      puts "\nAbort the list replace: /list/replace/abort"
      puts @datasift.dynamic_list_replace.abort replace[:data][:id]

      puts "\nStart a new replace list (again): /list/replace/start"
      replace = @datasift.dynamic_list_replace.start id
      puts replace

      items = ['keyword1', 'keyword2']
      puts "\nAdd items #{items} to replacement list: /list/replace/add"
      puts @datasift.dynamic_list_replace.add(replace[:data][:id], items)

      puts "\nCommit the replacement list: /list/replace/commit"
      puts @datasift.dynamic_list_replace.commit replace[:data][:id]

      puts "\nCleanup: Delete the list: /list/delete"
      puts @datasift.dynamic_list.delete id

    rescue DataSiftError => dse
      puts dse.message
    end
  end
end

DynamicListReplaceApi.new
