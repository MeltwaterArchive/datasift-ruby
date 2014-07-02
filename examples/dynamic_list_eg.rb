require './auth'

class DynamicListApi < DataSiftExample
  def initialize
    super
    run
  end

  def run
    begin

      ##
      # Text Dynamic Lists
      puts "\nCreating a Dynamic List containing text items"
      puts 'Creating a dynamic list: /list/create'
      list = @datasift.dynamic_list.create('text', 'My dynamic list')
      puts list

      id = list[:data][:id]
      items = ['keyword1', 'keyword2']

      puts "\nGet a list of your Dynamic Lists: /list/get"
      puts @datasift.dynamic_list.get

      puts "Adding items to the dynamic list: #{items}: /list/add"
      puts @datasift.dynamic_list.add(id, items)

      csdl = "interaction.content list_any \"#{id}\""
      puts "\nCompile the following CSDL using a Dynamic List:"
      puts csdl
      puts @datasift.compile csdl

      remove_items = ['keyword1']
      puts "\nRemoving item #{remove_items} from the dynamic list: /list/remove"
      puts @datasift.dynamic_list.remove(id, remove_items)

      puts "\nCheck #{remove_items} has been removed from the list: /list/exists"
      puts @datasift.dynamic_list.exists(id, remove_items)

      remaining_item = ['keyword2']
      puts "\nCheck #{remaining_item} still exists in the list: /list/exists"
      puts @datasift.dynamic_list.exists(id, remaining_item)

      puts "\nDeleting the list: /list/delete"
      puts @datasift.dynamic_list.delete id

      ##
      # Integer Dynamic Lists
      puts "\n --- \n\nCreating a Dynamic List containing integers"
      puts 'Creating a dynamic list: /list/create'
      list = @datasift.dynamic_list.create('integer', 'My dynamic integer list')
      puts list

      id = list[:data][:id]
      items = [11111, 22222, 33333, 44444]

      puts "\nAdding integers to the dynamic list: #{items}: /list/add"
      puts @datasift.dynamic_list.add(id, items)

      csdl = "interaction.author.id list_in \"#{id}\""
      puts "\nCompile the following CSDL using a Dynamic List:"
      puts csdl
      puts @datasift.compile csdl

      puts "\nDeleting the list: /list/delete"
      puts @datasift.dynamic_list.delete id

    rescue DataSiftError => dse
      puts dse.message
    end
  end
end

DynamicListApi.new
