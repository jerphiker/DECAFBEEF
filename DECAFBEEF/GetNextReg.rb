

class GetNextReg

	@@workRegs = ["R9", "R10", "R11"]
	@@workRegInd = 0
	@@allocRegs = ["R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8"]
	@@allocRegInd = 0
	@@virtRegInd = 0
	@@freeRegs = []
	@@freeVirtRegs = []

	def initialize
		# do nothing		
	end

	def getNext
		if @@freeRegs.length > 0
			tempReg = @@freeRegs[0]
			@@freeRegs.delete(tempReg)
			return tempReg
		elsif @@freeVirtRegs.length > 0
			tempReg = @@freeVirtRegs[0]
			@@freeVirtRegs.delete(tempReg)
			return tempReg
		else
			if @@workRegInd < @@workRegs.length
				tempReg = @@workRegs[@@workRegInd]
				@@workRegInd += 1
				return tempReg
			elsif @@allocRegInd < @@allocRegs.length
				tempReg = @@allocRegs[@@allocRegInd]
				@@allocRegInd += 1
				return tempReg
			else
				tempReg = "V" + @@virtRegInd.to_s
				@@virtRegInd += 1
				return tempReg
			end
		end
	end

	def free(reg)
		if reg[0] == "V"
			@@freeVirtRegs << reg
		else
			@@freeRegs << reg
		end
	end

end
