#
# Common code to beautify the main Vagrantfile

module OS
    def OS.windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def OS.mac?
        (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    def OS.unix?
        !OS.windows?
    end

    def OS.linux?
        OS.unix? and not OS.mac?
    end
end

module SharedFolder
	def SharedFolder.path
		if OS.mac?
			"/Users/sky/Dropbox/_COMMVAULT/products\ v2/Commvault-GO-Labs/1A_Packages/"
		elsif OS.windows?
			"E:\\Dropbox\\_COMMVAULT\\products v2\\Commvault-GO-Labs\\1A_Packages"
		end
	end
end