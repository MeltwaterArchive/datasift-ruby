require './auth'

class DynamicListApi < DataSiftExample
  def initialize
    super
    run
  end

  def run
    begin

      puts 'Creating a dynamic list'
      list = @datasift.dynamic_list.create('text', 'My dynamic list')
      puts list

      id = list[:id]
      items = ["keyword1", "keyword2"]

      puts 'Adding items to the dynamic list'
      puts @datasift.dynamic_list.add(id, items)

      puts 'Deleting'
      puts @datasift.dynamic_list.delete id
    rescue DataSiftError => dse
      puts dse.message
    end
  end
end

DynamicListApi.new