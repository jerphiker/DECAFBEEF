SYM_SIZE = 4

class SymbolTable
	@@next_addr = 0
	def initialize
		@syms = {}
	end

	def get(sym)
		@syms[sym]
	end

	def has?(sym)
		@syms.has_key?(sym)
	end

	def add(sym)
		@syms[sym] = @@next_addr
		@@next_addr += 4
	end
end
