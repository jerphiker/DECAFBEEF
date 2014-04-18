

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
			return symTab.get(var)
		else 
			unless  @parent == nil
				return @parent.getVar(var)
			end
		end
	end
	
end
