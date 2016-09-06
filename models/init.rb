require_relative 'driver'
require_relative 'order'

DataMapper.finalize

DataMapper.auto_upgrade!