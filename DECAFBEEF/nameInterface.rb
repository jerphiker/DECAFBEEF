

class NameInterface

	def initialize(name, parent, symTab)
		@name = name
		@parent = parent
		@symTab = symTab
	end

	def addChild(name, symTab)
		return NameInterface.new(name, self, symTab)
	end

	def getVar(var)
		if symTab.has?(var)
			puts " Found:" + @name + " address:" + symTab.get(var).to_s
			return symTab.get(var)
		else 
			unless  @parent == nil
				print "Not in:" + @name + " Checking parent:"
				return @parent.getVar(var)
			end
		end
		puts " End of chain -- variable not found"
	end

	def getSymTab
		return @symTab
	end
	
end
