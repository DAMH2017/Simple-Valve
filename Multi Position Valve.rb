include UNI



# Send command time out [ms].
$timeOut = 1000
$cmdCharTerm = 0x0D
$maxPosition = 8


#########################################################################
# User written helper function.
#
# Returns true if the given character is a number character.
#########################################################################
def isNumber(ch)
	if (ch >= ?0.ord && ch <= ?9.ord)
		return true
	end
	return false
end




#########################################################################
# Sub-device class expected by framework.
#
# Sub-device represents functional part of the chromatography hardware.
# Valve implementation.
#########################################################################
class Valve < ValveSubDeviceWrapper
	# Constructor. Call base and do nothing. Make your initialization in the Init function instead.
	def initialize
		super
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# Initialize Valve sub-device. 
	# Set sub-device name, specify method items, specify monitor items, ...
	# Returns nothing.
	#########################################################################	
	def Init
		Trace(">>> Valve.Init\n")
	end
	
end # class Valve





#########################################################################
# Device class expected by framework.
#
# Basic class for access to the chromatography hardware.
# Maintains a set of sub-devices.
# Device represents whole box while sub-device represents particular 
# functional part of chromatography hardware.
# The class name has to be set to "Device" because the device instance
# is created from the C++ code and the "Device" name is expected.
#########################################################################
class Device < DeviceWrapper
	# Constructor. Call base and do nothing. Make your initialization in the Init function instead.
	def initialize
		super
	end
	
	
	
	#########################################################################
	# Method expected by framework.
	#
	# Initialize configuration data object of the device and nothing else
	# (set device name, add all sub-devices, setup configuration, set pipe
	# configurations for communication, #  ...).
	# Returns nothing.
	#########################################################################	
	def InitConfiguration
    	Configuration().AddChoiceList("ValvePositions","Valve Positions","2 Positions")
    	Configuration().AddChoiceListItem("ValvePositions","2 Positions")
    	Configuration().AddChoiceListItem("ValvePositions","4 Positions")
    	Configuration().AddChoiceListItem("ValvePositions","6 Positions")
    	Configuration().AddChoiceListItem("ValvePositions","8 Positions")
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# Initialize device. Configuration object is already initialized and filled with previously stored values.
	# (set device name, add all sub-devices, setup configuration, set pipe
	# configurations for communication, #  ...).
	# Returns nothing.
	#########################################################################	
	def Init
		Trace(">>> Device.Init\n")
		
		$maxPosition=Configuration().GetString("ValvePositions")[/\d+/].to_i
		
		Method().AddChoiceList("InitPosition","Valve Positions","Keep Current")
		Method().AddChoiceListItem("InitPosition","Keep Current")
		for i in 1..$maxPosition do
			Method().AddChoiceListItem("InitPosition","Position "+i.to_s)
		end
		
		Method().AddCheckBox("RestoreOnFinish","Restore position after finished",false)
		Method().AddCheckBox("RestoreOnClose","Restore position on close",false)
		
		Monitor().AddInt("CurrValvePos","Current Position",1)
		Monitor().AddButton("NextPos","Next Position","Next","CmdNextValvePosition")
		# Device name.
		SetName("My Upchurch valve")
		
		# Set sub-device name.
		@m_Valve=Valve.new
		AddSubDevice(@m_Valve)
		@m_Valve.SetName("My Valve")
		@m_Valve.SetValveType(2,1,$maxPosition)
		
		Trace("Max valve positions: "+$maxPosition.to_s)
 	end
	

	#########################################################################
	# Method expected by framework.
	#
	# Sets communication parameters.
	# Returns nothing.
	#########################################################################	
	def InitCommunication()
		# Set number of pipe configurations for communication. In our case one - serial communication.
		
	end
	
	#########################################################################
	# Method expected by framework
	#
	# Here you should check leading and ending sequence of characters, 
	# check sum, etc. If any error occurred, use ReportError function.
	#	dataArraySent - sent buffer (can be nil, so it has to be checked 
	#						before use if it isn't nil), array of bytes 
	#						(values are in the range <0, 255>).
	#	dataArrayReceived - received buffer, array of bytes 
	#						(values are in the range <0, 255>).
	# Returns true if frame is found otherwise false.		
	#########################################################################	
	def FindFrame(dataArraySent, dataArrayReceived)
	
		
		return false
	end
	
	#########################################################################
	# Method expected by framework
	#
	# Return true if received frame (dataArrayReceived) is answer to command
	# sent previously in dataArraySent.
	#	dataArraySent - sent buffer, array of bytes 
	#						(values are in the range <0, 255>).
	#	dataArrayReceived - received buffer, array of bytes 
	#						(values are in the range <0, 255>).
	# Return true if in the received buffer is answer to the command 
	# from the sent buffer. 
	#########################################################################		
	def IsItAnswer(dataArraySent, dataArrayReceived)
		return true
	end
	
	#########################################################################
	# Method expected by framework
	#
	# Returns serial number string from HW (to comply with CFR21) when 
	# succeessful otherwise false or nil. If not supported return false or nil.
	#########################################################################	
	def CmdGetSN
		# Serial number not supported in the hw.
		return false
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when instrument opens
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdOpenInstrument
		Trace(">>> CmdOpenInstrument\n")
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when sequence starts
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdStartSequence
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when sequence resumes
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdResumeSequence
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when run starts
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdStartRun
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when injection performed
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdPerformInjection
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when injection bypassed
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdByPassInjection
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# Starts method in HW.
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdStartAcquisition
		Trace("****************** CmdStartAcquisition **************************\n")
		Monitor().SetRunning(true)
		Monitor().Synchronize()
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when acquisition restarts
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdRestartAcquisition
		# Nothing to send.
		return true
	end	

	#########################################################################
	# Method expected by framework.
	#
	# Stops running method in hardware. 
	# Returns true when successful otherwise false.	
	#########################################################################
	def CmdStopAcquisition
		Trace("****************** CmdStopAcquisition **************************\n")
	  	nPosition=Method().GetString("InitPosition")[/\d+/].to_i
		if(Method().GetInt("RestoreOnFinish")!=0)
			if(CmdChangeValveState(@m_Valve,nPosition)==false)
				return false
			end
		end
		return true
	end	
	
	#########################################################################
	# Method expected by framework.
	#
	# Aborts running method or current operation. Sets initial state.
	# Returns true when successful otherwise false.	
	#########################################################################
	def CmdAbortRunError
		return CmdStopAcquisition()
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# Aborts running method or current operation (request from user). Sets initial state.
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdAbortRunUser
		return CmdStopAcquisition()
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# Aborts running method or current operation (shutdown). Sets initial state.
	# Returns true when successful otherwise false.	
	#########################################################################
	def CmdShutDown
		return CmdStopAcquisition()
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when run stops
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdStopRun
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when sequence stops
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdStopSequence
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when closing instrument
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdCloseInstrument
		Trace(">>> CmdCloseInstrument\n")
		nPosition=Method().GetString("InitPosition")[/\d+/].to_i
		if(Method().GetInt("RestoreOnClose")!=0)
			if(CmdChangeValveState(@m_Valve,nPosition)==false)
				return false
			end
		end
		return true
	end	

	#########################################################################
	# Method expected by framework.
	#
	# Tests whether hardware device is present on the other end of the communication line.
	# Send some simple command with fast response and check, whether it has made it
	# through pipe and back successfully.
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdTestConnect
		Trace(">>> CmdTestConnect\n")
		# Reading of valve position
		return true
	end	

	#########################################################################
	# Method expected by framework.
	#
	# Send method to hardware.
	# Returns true when successful otherwise false.	
	#########################################################################
	def CmdSendMethod
		nPosition=Method().GetString("InitPosition")[/\d+/].to_i
		CmdChangeValveState(@m_Valve,nPosition)
		return true		
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# Loads method from hardware.
	# Returns true when successful otherwise false.	
	#########################################################################
	def CmdLoadMethod(method)
		return true		
	end
		
	#########################################################################
	# Method expected by framework.
	#
	# Duration of thermostat method.
	# Returns complete (from start of acquisition) length (in minutes) 
	# 	of the current method in sub-device (can use GetRunLengthTime()).
	# Returns METHOD_FINISHED when hardware instrument is not to be waited for or 
	# 	method is not implemented.
	# Returns METHOD_IN_PROCESS when hardware instrument currently processes 
	# 	the method and sub-device cannot tell how long it will take.
	#########################################################################
	def GetMethodLength
		return METHOD_FINISHED
	end	
	
	#########################################################################
	# Method expected by framework.
	#
	# Periodically called function which should update state 
	# of the sub-device and monitor.
	# Returns true when successful otherwise false.	
	#########################################################################
	def CmdTimer
		if(IsDemo())
			return true
		end
		if((currPosition=CmdGetValveState(@m_Valve))==false)
			return false
		end
		Monitor().SetInt("CurrValvePos",currPosition)
		Monitor().Synchronize()
	    return true
	end
	
	#########################################################################
	# Method expected by framework
	#
	# gets called when user presses autodetect button in configuration dialog box
	# return true or  false
	#########################################################################
	def CmdAutoDetect
		return CmdTestConnect()
	end
	
	#########################################################################
	# Method expected by framework
	#
	# Processes unrequested data sent by hardware. Unrequested data is not 
	# supported for now please use default implementation from examples.
	#	dataArrayReceived - received buffer, array of bytes 
	#						(values are in the range <0, 255>).
	# Returns true if frame was processed otherwise false.
	#########################################################################
	def ParseReceivedFrame(dataArrayReceived)
		# Passes received frame to appropriate sub-device's ParseReceivedFrame function.
	end	

	
	#########################################################################
	# Method expected by framework.
	# 
	# Reading of current valve position from hardware.
	# Returns valve position when successful otherwise false.
	#########################################################################
	def CmdGetValveState(valve)
		#send command 00q, get answer 00qp10000000+$cmdCharTerm
		#check that answer contains 00qp
		#check that answer second part length==9, last char is $cmdCharTerm, first to near last not contains characters other than 0 and 1
		#get the index of "1", add +1 to it, this is the valve position
		if( IsDemo())
			return 1
		end
		cmd=CommandWrapper.new(self)
		cmd.AppendANSIString("00q")
		cmd.AppendANSIString($cmdCharTerm)
		if(cmd.SendCommand($timeOut)==false)
			return false
		end
		if(cmd.ParseANSIString("00qp")==false)
			return false
		end
		if((valveString=cmd.ParseANSIString)==false)
			retutn false
		end
		if(valveString.length!=9 || valveString[8].ord!=$cmdCharTerm || valveString[0..7].index(/[^01]/)!=nil)
			return false
		end
		valvePosition=valveString[0..7].index("1")+1
		return valvePosition
	end

	#########################################################################
	# Method expected by framework.
	#
	# Send request to change current valve position.
	#########################################################################
	def CmdChangeValveState(valve,nPosition)
		#send command g+nPosition (e.g: g3 where 3 is the nPosition)
		#when send the number, radix is 10 to use numbers from [0..9], place is 1
		#receive answer (g+number) (not known), parse the ("g") then the number (-1)
		if(IsDemo())
			return true
		end
		cmd=CommandWrapper.new(self)
		cmd.AppendANSIChar('g')
		cmd.AppendANSIInt(nPosition.to_i,10,1)
		if(cmd.SendCommand($timeOut)==false)
			return false
		end
		cmd.ParseANSIString("g")
		cmd.ParseANSIInt(-1)
		Monitor().Synchronize()
		return true
	end		
		
	#########################################################################
	# Method expected by framework.
	#
	# Send request to go to next valve position.
	#########################################################################
	def CmdNextValvePosition
		#get the current valve position
		#change valve position using (CmdChangeValveState) but check if we reached the max then return to 1
		#example: if current valve position is 6 and the valve max positions is 6, then next value is 1
		if(IsDemo())
			p=Monitor().GetInt("CurrValvePos")
			if(p<$maxPosition)
				p+=1
			else
				p=1
			end
			Monitor().SetInt("CurrValvePos",p)
			Monitor().Synchronize()
			return true
		end
		if((currValvePosition=CmdGetValveState(@m_Valve))==false)
			return false
		end
		if(currValvePosition==$maxPosition)
			currValvePosition=1
		else
			currValvePosition+=1
		end
		if ((CmdChangeValveState(@m_Valve,currValvePosition))==false)
			return false
		end
		Monitor().Synchronize()
		return true
	end
		
	#########################################################################
	# Required by Framework
	#
	# Gets called when chromatogram is acquired, chromatogram might not exist at the time.
	#########################################################################
	def NotifyChromatogramFileName(chromatogramFileName)
	end
	
	
	#########################################################################
	# Required by Framework
	#
	# Validates valve value.
	# Validation function returns true when validation is successful otherwise
	# it returns message which will be shown in the Message box.
	#########################################################################
	def CheckValveValue(valve,value)
		return true
	end
	
	#########################################################################
	# Required by Framework
	#
	# Validates whole method. Use method parameter and NOT object returned by Method(). 
	# There is no need to validate again attributes validated somewhere else.
	# Validation function returns true when validation is successful otherwise
	# it returns message which will be shown in the Message box.
	#########################################################################
	def CheckMethod(situation,method)
		return true
	end
	
	#########################################################################
	# User written method.
	#
	# Returns translated string with specified ID
	#########################################################################
	

end # class Device
